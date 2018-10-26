#!/usr/bin/env perl
use strict; use warnings; use v5.24;
use feature 'signatures';
no warnings 'experimental::signatures';
use Carp;
use Clone qw( clone );
use File::Basename;
use File::Slurp;
use Getopt::Long qw(:config gnu_compat bundling no_getopt_compat
    require_order auto_version no_ignore_case);

$main::VERSION = v0.2;
our $DEBUG;
my $progname = basename $0;

sub main        : prototype();
sub run         : prototype(\%\@@);
sub cmdarg      : prototype(\%\@$);
sub filearg     : prototype(\%\@$);
sub handle_fail : prototype(\%$);
sub msg         : prototype($;$$);
sub show_usage  : prototype(;$);

main();

###############################################################################
# MAIN
###############################################################################

sub main : prototype()
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
        'p|pipe|stdin|' => \$options{pipe},
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
            $init = cmdarg %options, @cmd_args, $arg ;
            if ( $init == 2 ) {
                filearg %options, @files, $arg;
            }
        }
        else {
            filearg %options, @files, $arg;
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
            run %options, @cmd, @cmd_args_cpy ;
        }
        else {
            eval qq/push \@cmd_args_cpy, $file_ref/;
            run %options, @cmd, @cmd_args_cpy ;
        }
    }
}

###############################################################################
# Subroutines
###############################################################################

sub cmdarg ( $options, $cmd_args, $arg ) : prototype(\%\@$)
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

sub filearg ( $options, $files, $arg ) : prototype(\%\@$)
{
    if ( $options->{diff} ) {
        if ( $arg eq '--' ) { push @{$files}, [] }
        else                { push @{ $files->[-1] }, $arg }
    }
    else {
        push @{$files}, $arg;
    }
}

sub run ( $options, $cmd, @cmd_args ) : prototype(\%\@@)
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
        handle_fail( %$options, $ret );
    }
}

sub handle_fail ( $options, $ret ) : prototype(\%$)
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

sub msg ( $message, $nl=0, $name=1 ) : prototype($;$$)
{
    print STDERR "\n" if $nl;
    if   ($name) { say STDERR "${progname}: ${message}" }
    else         { say STDERR "${message}" }
}

sub getstdin
{
    my @lines = read_file( \*STDIN );
}

###############################################################################
# USAGE
###############################################################################

sub show_usage($status=0) : prototype(;$)
{
    print << "EOF";
Usage: $progname [options] command [command options] -- fileA fileB ... fileN
OR:    $progname -d [options] command [command options] -- fileA -- fileB ... -- fileN
EOF
    exit $status unless ( $status == 0 );

    print << "EOF";

Applies the given command with arguments to each given file. Stops execution
should any command fail (return non-zero) unless the `-k' flag is given.

Normally, the first non flag argument is taken to be the command and everything
thereafter until `--' is encountered are taken to be arguments which will be
given on each invocation. Even if no arguments are specified, `--' must appear
before the first filename. The command is then applied to all following
arguments. Any of this program's own options must appear before the command.

By quoting the `file' arguments, it is possible to in fact give unique flags for
each file, or possibly multiple files for one invocation.

For example, this command will will run gcc for each of the three files:
    $progname gcc -O2 -Wall -c -- foo.c bar.c baz.r

This will also run gcc 3 times in the order specified; a poor man's make(1).
    $progname gcc -c -Wall -- '-O2 foo.c' 'bar.c -obaz.o' 'foo.o baz.o -o qux'

If desired, the -d flag will activate a second mode of rather dubious
usefullness in which each `file' argument must be separated by `--', allowing
the above to be possible without needing to quote the arguments. It's probably
almost never easier to do it this way, but the feature exists anyway.

The above command in the `-d' mode:
    $progname -d gcc -c -Wall -- -O2 foo.c -- bar.c -obaz.o -- foo.o baz.o -o qux

Finally, with the `-c' flag one may give a shell script to be executed in place
of a program. The script must be the argument to this option, and must therefore
must be carefully quoted (awk style). File arguments will be correctly passed to
the script and accessed through the numbered variables as usual.

OPTIONS:
  -h, --help         Show this help and exit.
  -v, --version      Print version information and exit.
  -D, --debug        Be (much) more verbose.
  -s, --shell        Specify the shell used to launch commands (default: /bin/sh).
  -S, --sep          Output an addtional newline after each invocation
  -k, --keep-going   Don't stop if a command fails.
  -i, --interactive  Prompt the user after a failure whether or not to continue.
  -d, --diff         Activate the mode described above.
  -n, --dry-run      Don't run any commands, just display what would be done.
  -c, --script       Give a shell script to be executed instead of a command.
  -p, --pipe|stdin   Read additional filenames from stdin, like xargs(1).
EOF
    exit $status;
}
