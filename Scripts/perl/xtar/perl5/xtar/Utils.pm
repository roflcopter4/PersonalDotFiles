package xtar::Utils;
use 5.32.0; use warnings; use strict;
use utf8;
# use open qw(:std :utf8);
no feature 'indirect';
use feature 'signatures';
no warnings 'experimental::signatures';

use Carp qw( confess );
use Exporter 'import';
use File::Spec::Functions qw( splitpath );

our @EXPORT    = qw( Basename Dirname err );
our @EXPORT_OK = qw( Basename Dirname err );

sub Basename :prototype($) ($path) {
    return ( splitpath($path) )[2];
}

sub Dirname :prototype($) ($path) {
    (undef, my $dir, undef) = splitpath($path);
    $dir =~ s|/$||;
    return $dir;
}

sub err {
    confess "No arguments!" unless @_;
    say STDERR @_;
}
