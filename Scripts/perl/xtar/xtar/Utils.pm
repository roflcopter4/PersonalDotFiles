package xtar::Utils;
use 5.28.0; use warnings; use strict;
use feature 'signatures';
no warnings 'experimental::signatures';

use Carp qw( confess );
use Exporter 'import';
use File::Spec::Functions qw( splitpath );

our $moo = <<'EOF';
# use Moose;
# use MooseX::LazyRequire
# use MooseX::Has::Sugar;
# use MooseX::Types;

# use Mouse;

use Moo;
# use MooX::Types::MooseLike::Base qw{Int Str Object HashRef Bool};
# use MooX::Types::MooseLike::Base qw/:all/;
# use MooX::late;
EOF

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
