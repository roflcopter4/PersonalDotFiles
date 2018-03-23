#!/usr/bin/perl
use strict; use warnings; use v5.22;
use feature qw( signatures );
no warnings qw( experimental::signatures );
use Carp;
use File::Which;
use File::Temp qw( tempfile cleanup );

###############################################################################

sub usage {
    my $status = shift or confess 'Invalid usage of usage!';
    my $THIS = $0;
    $THIS =~ s|.*/(.*)|$1|;
    print << "EOF";
Usage: $THIS -[extension] PROG <prog params> -\n
'-' is optional and indicates where in the program's paramater list the
temporary file should appear. If not given, the file is placed at the end.
Likewise if no extension is given then the temporary file will have none.
EOF
    exit $status;
}

sub get_cmd($program) {
    defined($program) or croak "No program identified in commandline!\n";
    my $cmd = which($program) or croak "Command '$program' not found.\n";
    return $cmd;
}

sub get_tmp($type) {
    if ( defined($type) ) {
        return tempfile SUFFIX => ".$type", TMPDIR => 1, CLEANUP => 1;
    }
    else {
        return tempfile TMPDIR => 1, CLEANUP => 1;
    }
}

###############################################################################

if ( @ARGV == 0 ) {
    carp "No arguments!";
    usage(1);
}
my ( $type, $program, $position, @args );

my $iter = 0;
while (@ARGV) {
    my $param = shift;

    if ( $iter == 0 ) {
        if    ( $param =~ /^-(?:-help|h)/ ) { usage(0); }
        elsif ( $param =~ /^-(.*)/ )        { $type = $1; }
        else                                { $program = $param; }
    }
    elsif ( not defined($program) and $iter == 1 ) {
        $program = $param;
    }
    elsif ( not defined($type) and $param =~ /^-\.(.*)/ ) {
        $type     = $1;
        $position = $iter - 1;
        push @args, '';
    }
    elsif ( not defined($position) and $param eq '-' ) {
        $position = $iter - 2;
        push @args, '';
    }
    else {
        push @args, $param;
    }

    ++$iter;
}

###############################################################################
# Now some processing

$program = get_cmd($program);    # Dies if program doesn't exist.
my ( $FH, $tmpname ) = get_tmp($type);

if ( defined($position) ) {
    $args[$position] = $tmpname;
}
else {
    push @args, $tmpname;
}

# Dump stdin to the file.
while (<>) {
    print $FH $_;
}

# Run the command, wait a bit for programs like firefox that automatically
# fork and separate themselves to open the file, then delete the file and exit.
system( $program, @args );
sleep 1;
unlink $tmpname or cluck("Couldn't delete temporary file '$tmpname'.");
