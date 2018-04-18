#!/usr/bin/env perl
use strict; use warnings;
use String::ShellQuote;
use List::Util 'max';

my $input = eval '`du -d1 '.shell_quote(@ARGV).' | sort -nr`' or die "$!";
chomp $input;

my @list = map { [ split(/\t/, $_) ] } split(/\n/, $input);

foreach (@list) {
    1 while $_->[0] =~ s/^(\d+)(\d{3})/$1,$2/;
}

my $longest = max(map { length $_->[0] } @list);

foreach (@list) {
    printf "%*s     %s\n", $longest, @{$_};
}
