#!/usr/bin/env perl
use strict; use warnings; use v5.26;
use Carp;

if ( @ARGV == 0 or @ARGV > 1 or $ARGV[0] =~ /-{1,2}(?:h|help)/ ) {
    my $this = $0 =~ s|.*/(.*)|$1|r;
    say "Usage: $this [ARCHIVE]";
    exit scalar(@ARGV);
}

my $file = $ARGV[0];
unless ( -e $file and not -d $file ) {
    die "File '$file' either doesn't exist or is a directory.";
}

###############################################################################

sub get_array {
    my $cmd = shift or croak("No command supplied!\n");
    my $output = `$cmd`;
    chomp $output;
    return split( /\n/, $output );
}

###############################################################################

my ( @array, @filter, $rex, $num1, $num2 );

$rex = qr'.*?\s+(\d+)\s+(\d+).+? (?:files|file)(?:$|,.+)';

@array  = get_array("7z l $file");
@filter = grep ( /$rex/n, @array );

if ( @filter ) {
    $filter[0] =~ /$rex/;
    ( $num1, $num2 ) = ( int($1), int($2) );
}
else {
    # Some archives won't cooperate properly and have to be 'tested' rather
    # than 'listed', a much more expensive operation.
    warn "Failed to list archive, falling back to a test.\n";

    @array  = get_array("7z t $file");

    @filter = grep ( /(Size:|Compressed:)/, @array );
    croak('Failed to parse output.') if ( @filter != 2 ); 

    $num1 = $filter[0] =~ s/.*?(\d+).*/$1/r;
    $num2 = $filter[1] =~ s/.*?(\d+).*/$1/r;
    ( $num1, $num2 ) = ( int($num1), int($num2) );
}

die "I can't divide by zero!\n" if ( $num1 == 0 );

my $len = length( int($num1 / 1000) );
my $ans = ($num2 / $num1) * 100;

printf "Actual size:        %*d kB\n", $len, ($num1 / 1000);
printf "Compressed size:    %*d kB\n", $len, ($num2 / 1000);
print  "Compression ratio:  $ans %\n";
