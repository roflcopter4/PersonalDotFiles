package xtar::OutPath;

use Moo;
use MooX::Types::MooseLike::Base qw{Int Str Object HashRef Bool};

use constant true  => 1;
use constant false => 0;
use Carp;
use File::Spec::Functions qw( rel2abs catdir );

use lib rel2abs('..');
use xtar::Utils;

# BEGIN { eval $xtar::Utils::moo; }
use 5.28.0; use warnings; use strict;
use feature 'signatures';
no warnings 'experimental::signatures';

###############################################################################

sub init            :prototype($$);
sub analyze_output  :prototype($$);
sub get_odir        :prototype($);
sub __get_odir      :prototype($);
sub handle_conflict :prototype($$);
sub glob_all        :prototype();
sub descend         :prototype($);

###############################################################################

has 'CWD'         => ( is => 'ro', isa => Str );
has 'Options'     => ( is => 'ro', isa => HashRef );
has 'NumArchives' => ( is => 'ro', isa => Int );
has 'notfirst'    => ( is => 'rw', isa => Bool );

has 'tmpdir'      => ( is => 'rw', isa => Str );
has 'bottom'      => ( is => 'rw', isa => Str );
has 'top_dir'     => ( is => 'rw', isa => Str );
has 'odir'        => ( is => 'rw', isa => Str );
has 'out_top'     => ( is => 'rw', isa => Str );
has 'top_exist'   => ( is => 'rw', isa => Str );

has 'file'        => ( is => 'rw', isa => Object );

###############################################################################


sub init :prototype($$) ($self, $archive)
{
    $self->file( $archive );
    my $msg = "output directory is not writable. Aborting.";

    # if ( $self->Options->{out_top} ) {
    #         my $top = rel2abs($self->Options->{out_top})
    # }
    if ( $self->Options->{odir} or $self->Options->{out_top} ) {
        unless ( $self->notfirst  ) {
            my $top = ($self->Options->{out_top})
                ? rel2abs($self->Options->{out_top})
                : rel2abs($self->Options->{odir});
            my $tmp = $top;
            while () {
                if    ( not -e $tmp ) { $tmp = Dirname($tmp) }
                elsif ( not -w $tmp ) { croak "Given $msg"  }
                else                  { last }
            }

            $self->top_exist( $tmp );
            $self->top_dir( $top );
        }
    }
    else {
        unless ( -w $self->CWD ) { croak "Current $msg" }
        $self->top_exist( $self->CWD );
        $self->top_dir( $self->CWD );
    }

    $self->notfirst( true );
}


###############################################################################


sub analyze_output :prototype($$) ($self, $tmpdir)
{
    my ( $bottom, $lonefile ) = descend($tmpdir);
    chdir $self->CWD;
    $self->bottom( $bottom );
    $self->tmpdir( $tmpdir );

    $self->get_odir();

    return $lonefile;
}


sub get_odir :prototype($) ($self)
{
    if ($self->Options->{combine}
        or (    $self->Options->{odir}
            and $self->NumArchives == 1
            and not -e $self->Options->{odir}
            and not $self->Options->{top_dir} ))
    {
        $self->odir( $self->top_dir );
    }
    else {
        $self->odir( $self->__get_odir() );
    }
}


sub __get_odir :prototype($) ($self)
{
    my $oname;

    if ( $self->tmpdir eq $self->bottom ) {
        $oname = $self->file->bname;
    }
    else {
        $oname = Basename($self->bottom);
    }

    my $odir = catdir( $self->top_dir, $oname );
    if ( -e $odir ) {
        $odir = handle_conflict( $self->top_dir, $oname );
    }

    return $odir;
}


###############################################################################


sub handle_conflict :prototype($$) ($path, $name)
{
    my $TimeStamp = time;
    my $new_name  = "${path}/${name}-${TimeStamp}";

    my $i = 1;
    while ( -e $new_name ) {
        $new_name = "${path}/${name}-${TimeStamp}-${i}";
        ++$i;
    }

    return $new_name;
}


sub glob_all :prototype() ()
{
    my @files = glob('* .*');
    my @filter;

    foreach my $cur (@files) {
        next if ( $cur eq '.' or $cur eq '..' );
        push @filter, $cur;
    }

    return @filter;
}


sub descend :prototype($) ($dir)
{
    chdir $dir;
    my @files = glob_all();
    my $bottom;
    my $lonefile = '';

    if ( @files == 1) {
        if ( -d $files[0] ) {
            my $lonedir = rel2abs($files[0]);
            ( $bottom, $lonefile ) = descend($lonedir);
        }
        else {
            $bottom   = $dir;
            $lonefile = rel2abs($files[0]);
        }
    }
    elsif ( @files == 0 ) {
        croak "No files in output directory!";
    }
    else {
        $bottom = $dir;
    }

    return ( $bottom, $lonefile );
}


###############################################################################

__PACKAGE__->meta->make_immutable;
