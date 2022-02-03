#!/usr/bin/env perl
use 5.34.0; use warnings; use strict;
use utf8;
use feature  'signatures';
no  feature  'indirect';
no  warnings qw(experimental::signatures experimental::smartmatch);
use open     qw(:std :utf8);
use Carp;

use String::ShellQuote;
use List::Util;

#########################################################################################

sub split_input :prototype($) ($input)
{
    my @list = map { [split /\t/, $_] } split /\n/, $input;

    # Group numbers in the output with commas (eg 123456 -> 123,456)
    foreach (@list) {
        while ($_->[0] =~ s/^(\d+)(\d{3})/$1,$2/) {}
    }

    return @list;
}


sub main :prototype() ()
{
    my $input = eval '`du -d1 ' . shell_quote(@ARGV) . ' | sort -nr`'
                or die "$!";
    chomp $input;

    my @list    = split_input($input);
    my $longest = List::Util::max(map { length $_->[0] } @list);

    foreach (@list) {
        printf "%*s     %s\n", $longest, @$_;
    }

    return 0;
}

#########################################################################################

exit main();
__END__
