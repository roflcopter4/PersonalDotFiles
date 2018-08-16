#!/usr/bin/env perl
use strict;
use warnings;
use v5.24;
use feature 'signatures';
no warnings 'experimental::signatures';
use Carp;
use Clone qw( clone );
use File::Basename;
use Getopt::Long qw(:config gnu_compat bundling no_getopt_compat
    require_order auto_version no_ignore_case);

$main::VERSION = v0.2;
our $DEBUG;
my $progname = basename $0;

main(@_);

###############################################################################
# MAIN
###############################################################################

sub main
{
    my %options = ( keep_going => 0 );

    GetOptions(
        'h|help'        => \$options{help},
        'k|keep-going'  => \$options{keep_going},
        'i|interactive' => \$options{interactive},
        'd|diff'        => \$options{diff},
        'n|dry-run'     => \$options{dryrun},
        'c|script=s'    => \$options{script},
        's|shell=s'     => \$options{shell},
        'S|sep'         => \$options{sep},
        'D|debug'       => \$DEBUG,
    ) or ( print STDERR "\n" && show_usage(1) );

    if ( $options{help} ) { show_usage() }
    if ( @ARGV < ( $options{script} ? 1 : 2 ) ) {
        msg("Insufficient paramaters.");
        show_usage(2);
    }

    my ( @cmd_args, @files, @cmd, $init );
    $options{allow_spaces} = 0;

    if ( $options{script} ) {
        my $tmp = $options{script};
        my $sh = ( $options{shell} ) ? $options{shell} : '/bin/sh';

        push @cmd, $sh, '-s', '--', "<<'_APPLY_EOF_'\n${tmp}\n_APPLY_EOF_\n";
        $init = 0;
    }
    else {
        push @cmd, shift @ARGV;
        $init = 1;
    }

    push( @files, [] ) if $options{diff};

    while (@ARGV) {
        my $arg = shift @ARGV;

        if ($init) {
            $init = cmdarg( \@cmd_args, $arg, \%options );
            if ( $init == 2 ) {
                filearg( \@files, $arg, \%options );
            }
        }
        else {
            filearg( \@files, $arg, \%options );
        }
    }

    ###########################################################################
    # Running the commands

    my $file_ref = $options{diff} ? '@{$file}' : '$file';
    $options{sub} = grep( /--\?/, @cmd_args );

    foreach my $file (@files) {
        my @cmd_args_cpy = @{ clone( \@cmd_args ) };

        if ( $options{sub} ) {
            eval qq(map { s/--\\?/$file_ref/ } \@cmd_args_cpy);
            run( \%options, \@cmd, @cmd_args_cpy );
        }
        else {
            eval qq/push \@cmd_args_cpy, $file_ref/;
            run( \%options, \@cmd, @cmd_args_cpy );
        }
    }
}

###############################################################################
# Subroutines
###############################################################################

sub cmdarg ( $cmd_args, $arg, $options )
{
    my $init = 1;

    if ( $options->{diff} ) {
        if ( $arg eq '--' ) { $init = 0 }
        else                { push @{$cmd_args}, $arg }
    }
    else {
        if ( $arg eq '--' ) {
            $init = 0;
        }
        elsif ( $arg =~ /^-{1,2}/ or $options->{allow_spaces} ) {
            push @{$cmd_args}, $arg;
        }
        else {
            if ( grep( /--/, @ARGV ) ) {
                msg("Allowing spaces!") if $DEBUG;
                $options->{allow_spaces} = 1;
                push @{$cmd_args}, $arg;
            }
            else {
                $init = 2;
            }
        }
    }

    return $init;
}

sub filearg ( $files, $arg, $options )
{
    if ( $options->{diff} ) {
        if ( $arg eq '--' ) { push @{$files}, [] }
        else                { push @{ $files->[-1] }, $arg }
    }
    else {
        push @{$files}, $arg;
    }
}

sub run ( $options, $cmd, @cmd_args )
{
    if ( $options->{script} ) {
        if ( $DEBUG or $options->{dryrun} ) {
            my $post = @$cmd[$#$cmd];
            $post .= ' ' if ( $post !~ /\n$/ );

            msg("\033[0;32msystem( \033[1;36m@$cmd[0..($#$cmd-1)] "
              . "\033[0;33m@{cmd_args} \033[0;36m$post\033[0;32m)\033[0m",
                !$options->{dryrun} || $options->{sep}, 0
            );
        }
        else {
            print "\n" if $options->{sep}
        }

        if ( not $options->{dryrun} ) {
            system("@$cmd[0..($#$cmd-1)] @cmd_args $$cmd[$#$cmd]");
        }
    }
    else {
        if ( $DEBUG or $options->{dryrun} ) {
            msg("\033[0;32msystem( \033[1;36m@$cmd "
              . "\033[0;33m@{cmd_args}\033[0;32m )\033[0m",
                !$options->{dryrun} || $options->{sep}, 0
            );
        }
        else {
            print "\n" if $options->{sep}
        }

        if ( not $options->{dryrun} ) {
            system("@$cmd @cmd_args");
        }
    }

    my $ret = $? >> 8;
    if ( $ret != 0 ) {
        handle_fail( $ret, $options );
    }
}

sub handle_fail ( $ret, $options )
{
    msg( "Command failed with status $ret", 1 );

    if ( $options->{interactive} ) {
        msg("Continue?");
        unless ( <> =~ /y|yes/i ) { exit $ret }
    }
    elsif ( not $options->{keep_going} ) {
        msg("Exiting due to previous failures.");
        exit $ret;
    }
}

sub msg ( $message, $nl = 0, $name = 1 )
{
    print STDERR "\n" if $nl;
    if   ($name) { say STDERR "${progname}: ${message}" }
    else         { say STDERR "${message}" }

}

###############################################################################
# USAGE
###############################################################################

sub show_usage($status=0)
{
    print << "EOF";
Usage: $progname [options] command [command options] -- fileA fileB ... fileN
EOF
    exit $status unless ( $status == 0 );

    print << "EOF";

Applies the given command with arguments to each given file. Standard arguments
(that use a `-' as a switch) can be given without fuss, however if the program
requires any bare arguments, or arguments that require options are given with a
space (eg. `-ofoo' rather than `-ofoo', or `--out foo' rather than `--out=foo')
then the files must be placed after `--' in order to disambiguate them from the
command and options. Due to the nature of this program, its own options must
appear before the command.

A special mode can be invoked with the -d flag in which each file may recieve
additional arguments that apply only to it. In this mode options given before
the now compulsory `--' apply to all files. Thereafter, essentially any
commandline may be entered, involving as many or as few options or files as
desired, so long as each is separated by `--'.
For example:

$progname -d cc -c -Wall -- -O2 foo.c -- bar.c -obaz.o -- foo.o baz.o -o qux

Note that this is not make(1); things are done sequentially, not in parallel,
which is in general a limitation but does allow the above example to work - it
would fail if not done left to right!

OPTIONS:
  -h, --help         Show this help and exit.
  -v, --version      Print version information and exit.
  -k, --keep-going   Don't stop if a command fails.
  -i, --interactive  Prompt the user after a failure whether or not to continue.
  -d, --diff         Activate the mode described above.
  -s, --shell        Specify the shell to use with -c (default: /bin/sh).
  -n, --dry-run      Don't run any commands, just display what would be done.
  -D, --debug        Be (much) more verbose.
  -c, --script       Give a shell script to be executed in place of a program.
                     The script must be the argument to this option, and
                     therefore must be carefully quoted (awk style). File
                     arguments will be correctly passed to the script and
                     accessed through the numbered variables as usual.
EOF
    exit $status;
}
