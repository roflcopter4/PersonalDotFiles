#!/usr/bin/perl
use warnings;
use strict;
use v5.22;
use Carp;
use File::Which;
use Getopt::Long qw(:config gnu_getopt no_ignore_case require_order);

###############################################################################

sub slurp_file {
    my ( $data, $filename, $style ) = ( shift, shift, shift ) or croak;

    my ( $fp, $found );
    open( $fp, '<', $filename ) or croak $!;
    $found = 0;

    while (<$fp>) {
        if ($style) {
            if ($found) {
                next if ( $found = /^# ##END##/ );
                s/^#//;
            }
            else {
                next if ( $found = /^# ##$style##/i );
                next if ( /^(?:\n)|^(?:#.*\n)/ );
                next if ( /BreakBeforeBraces|SpaceBeforeParens|
                           IndentCaseLabels|IndentWidth/x );
            }
        }
        else {
            next if ( /^(?:\n)|^(?:#.*\n)/ );
        }

        chomp;
        ${$data} .= $_ . ', ';
    }

    close $fp or croak $!;
}

###############################################################################

my $file = $ENV{"HOME"} . "/.clang-format";
my ( $fp, $length, $usetabs, $notabs, $indent, $style );

GetOptions(
    'f|file=s'   => \$file,
    'l|len=i'    => \$length,
    't|tabs'     => \$usetabs,
    'T|notabs'   => \$notabs,
    'i|indent=i' => \$indent,
    's|style=s'  => \$style
) or croak("Error in command line arguments.\n");

my $data = '{';
slurp_file( \$data, $file, $style );
$data =~ s/(.*), $/$1}/;

if ($length) {
    if ( $data =~ m/ColumnLimit/ ) {
        $data =~ s/ColumnLimit: \d*/ColumnLimit: $length/;
    }
    else {
        $data =~ s/}/, ColumnLimit: $length}/;
    }
}

if ( $usetabs or $notabs ) {
    my $val;
    if    ($usetabs) { $val = 'Always' }
    elsif ($notabs)  { $val = 'Never' }

    if ( $data =~ m/UseTab/ ) {
        $data =~ s/UseTab: \w*/UseTab: $val/;
    }
    else {
        $data =~ s/}/, UseTab: $val}/;
    }
}

if ( defined $indent ) {
    if ( $data =~ m/IndentWidth/ ) {
        $data =~ s/IndentWidth: \d*/IndentWidth: $indent/;
    }
    else {
        $data =~ s/}/, IndentWidth: $indent}/;
    }
}

my @clformat = which('clang-format');
exec( $clformat[1], "-style=$data", @ARGV ) or croak $!;
