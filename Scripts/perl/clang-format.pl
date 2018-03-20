#!/usr/bin/perl
use warnings; use strict; use 5.26.1;
use diagnostics;
use Getopt::Long qw(:config gnu_getopt no_ignore_case require_order);
use File::Which;


my $file = $ENV{"HOME"} . "/.clang-format";
my $length;
my $usetabs;
my $notabs;
my $indent;

GetOptions ("f|file=s"   => \$file,
            "l|len=i"    => \$length,
            "t|tabs"     => \$usetabs,
            "T|notabs"   => \$notabs,
            "i|indent=i" => \$indent)
    or die("Error in command line arguments.\n");


open('fp', '<', $file) or die $!;
my $data = '{';

foreach (<fp>) {
    next if /^(?:\n)|^(?:#.*\n)/;
    s/\n//;
    $data .= $_ . ', ';
}

$data =~ s/(.*), $/$1}/;
close('fp');


if ($length) {
    if ($data =~ m/ColumnLimit/) {
        $data =~ s/ColumnLimit: \d*/ColumnLimit: $length/;
    } else {
        $data =~ s/}/, ColumnLimit: $length}/;
    }
}

if ($usetabs or $notabs) {
    my $val;
    $val = "Always" if $usetabs;
    $val = "Never" if $notabs;

    if ($data =~ m/UseTab/) {
        $data =~ s/UseTab: \w*/UseTab: $val/;
    } else {
        $data =~ s/}/, UseTab: $val}/;
    }
}

if (defined $indent) {
    if ($data =~ m/IndentWidth/) {
        $data =~ s/IndentWidth: \d*/IndentWidth: $indent/;
    } else {
        $data =~ s/}/, IndentWidth: $indent}/;
    }
}

my @clformat = which('clang-format');
system($clformat[1], "-style=$data", @ARGV)
