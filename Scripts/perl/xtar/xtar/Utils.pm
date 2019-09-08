package xtar::Utils;
use warnings; use strict; use v5.24;
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
