package xtar::Colors;
use warnings; use strict; use v5.24;
use Exporter 'import';
use feature 'signatures';
no warnings 'experimental::signatures';

use constant true  => 1;
use constant false => 0;

our @EXPORT = qw( sayC fsayC esayC );
our @EXPORT_OK = qw( printC fprintC eprintC );

my %color_hash = (
    RED     => 31,
    GREEN   => 32,
    YELLOW  => 33,
    BLUE    => 34,
    MAGENTA => 35,
    CYAN    => 36
);


sub sayC( $color, @strings ) {
    say _get_string( $color, @strings );
}

sub fsayC( $FH, $color, @strings ) {
    say $FH _get_string( $color, @strings );
}

sub esayC( $color, @strings ) {
    say STDERR _get_string( $color, @strings );
}

sub printC( $color, @strings ) {
    print _get_string( $color, @strings );
}

sub fprintC( $FH, $color, @strings ) {
    print $FH _get_string( $color, @strings );
}

sub eprintC( $color, @strings ) {
    print STDERR _get_string( $color, @strings );
}

###############################################################################


sub _get_string( $color, @strings )
{
    my ( $isbold, $esc );

    $color =~ /^(b?)(.*)/i;
    $isbold = $1;
    $color  = "\U$2";
    $color  = ($color) ? $color_hash{$color} : 1;

    $esc = _get_escape( $color, $isbold );

    return $esc . "@strings" . "\033[0m";
}


sub _get_escape( $num, $isbold )
{
    my $bold = ($isbold) ? 1 : 0;

    return "\033[${bold}m" . "\033[${num}m";
}
