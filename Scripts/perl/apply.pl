#!/usr/bin/env perl
use strict; use warnings; use v5.24;
use feature 'signatures';
no warnings 'experimental::signatures';
use Carp;
use Clone qw( clone );
use File::Basename;
use Getopt::Long qw(:config gnu_compat bundling no_getopt_compat
                            require_order auto_version no_ignore_case);

$main::VERSION = v0.2;
our $DEBUG;

###############################################################################


sub cmdarg( $cmd_args, $arg, $options )
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
                say STDERR "Allowing spaces!" if $DEBUG;
                $options->{allow_spaces} = 1;
                push @{$cmd_args}, $arg;
            }
            else {
                $init = 2
            }
        }
    }

    return $init;
}


sub filearg( $files, $arg, $options )
{
    if ( $options->{diff} ) {
        if ( $arg eq '--' ) { push @{$files}, [] }
        else                { push @{$files->[-1]}, $arg }
    }
    else {
        push @{$files}, $arg
    }
}


sub handle_fail( $ret, $options )
{
    say STDERR "Command failed with status $ret";
    if ( $options->{stop} ) {
        exit $ret;
    }
    elsif ( $options->{interactive} ) {
        print "Continue?  ";
        unless ( <> =~ /y|yes/i ) { exit $ret }
    }
}


sub run( $options, @cmd )
{
        say qq/\033[0m\033[33m\nsystem( @cmd )\033[0m/ if $DEBUG;
        system( @cmd );
        my $ret = $? >> 8;

        if ( $ret != 0 ) {
            handle_fail( $ret, $options );
        }
}


###############################################################################


my %options = ( keep_going => 1 );

GetOptions(
    'h|help'        => \$options{help},
    'k|keep-going'  => \$options{keep_going},
    's|stop'        => \$options{stop},
    'i|interactive' => \$options{interactive},
    'd|diff'        => \$options{diff},
    'D|debug'       => \$DEBUG
) or ( print STDERR "\n" && show_usage(1) );

if ( $options{help} ) { show_usage() }
if ( @ARGV < 2 ) {
    say STDERR "Error: insufficient paramaters.";
    show_usage(2);
}


my ( @cmd_args, @files );
my $cmd  = shift;
my $init = 1;
$options{allow_spaces} = 0;

if ( $options{diff} ) { push @files, [] }

while (@ARGV) {
    my $arg = shift;

    if ($init) {
        if ( ($init = cmdarg( \@cmd_args, $arg, \%options )) == 2 ) {
            filearg( \@files, $arg, \%options );
        }
    }
    else {
        filearg( \@files, $arg, \%options );
    }
}

###############################################################################

my $file_ref = $options{diff} ? '@{$file}' : '$file';
$options{sub} = grep( /--\?/, @cmd_args );

foreach my $file (@files) {
    if ( $options{sub} ) {
        my @cmd_args_cpy = @{clone( \@cmd_args )};
        eval qq( map { s/--\\?/$file_ref/ } \@cmd_args_cpy );
        run( \%options, $cmd, @cmd_args_cpy );
    }
    else {
        eval qq( run( \\\%options, \$cmd, \@cmd_args, $file_ref ) )
    }
}


###############################################################################


sub show_usage($status=0)
{
    my $THIS = basename($0);
    print << "EOF";
Usage: $THIS [options] command [command options] -- fileA fileB ... fileN
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

$THIS -d cc -c -Wall -- -O2 foo.c -- bar.c -obaz.o -- foo.o baz.o -o qux

Note that this is not make(1); things are done sequentially, not in parallel,
which is in general a limitation but does allow the above example to work - it
would fail if not done left to right!

OPTIONS:
  -h, --help         Show this help and exit.
  -v, --version      Print version information and exit.
  -k, --keep-going   Don't stop if a command fails (default).
  -s, --stop         Do stop if a command fails.
  -i, --interactive  Prompt the user after a failure whether or not to continue.
  -d, --diff         Activate the mode described above.
EOF
    exit $status;
}
