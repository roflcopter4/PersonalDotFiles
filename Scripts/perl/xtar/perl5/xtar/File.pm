package xtar::File;

use Moose;
use MooseX::LazyRequire;

use constant true  => 1;
use constant false => 0;
use constant MAXKIND => 4;

use Carp qw( carp croak cluck confess );
use Scalar::Util qw( looks_like_number );
use File::Spec::Functions qw( rel2abs );
use File::Copy qw( mv );
use File::Basename;
use File::Which;
use String::ShellQuote;
use Try::Tiny;

use Data::Dumper;

use xtar::Colors;
use xtar::Utils;

use 5.32.0; use warnings; use strict;
use utf8;
# use open qw(:std :utf8);
no feature 'indirect';
use feature 'signatures';
no warnings 'experimental::signatures';

our ($found_file_unpack, $found_file_libmagic);
try {
    require File::Unpack and File::Unpack->import();
    $xtar::File::found_file_unpack = true;
}
catch {
    $xtar::File::found_file_unpack = false;
};

try {
    require File::LibMagic and File::LibMagic->import();
    $xtar::File::found_file_libmagic = true;
} catch {
    $xtar::File::found_file_libmagic = false;
};

##############################################################################

sub analysis               :prototype($);
sub extention_analysis     :prototype($);
sub _check_short_tar       :prototype($);
sub mimetype_analysis      :prototype($);
sub find_mimetype          :prototype($\$);
sub finalize_analysis      :prototype($);
sub _normalize_type        :prototype($);
sub determine_decompressor :prototype($$);

##############################################################################

has 'Options'     => ( is => 'ro', isa => 'HashRef' );
has 'ID_Failure'  => ( is => 'rw', isa => 'Bool' );

has 'basepath'    => ( is => 'ro', isa => 'Str' );
has 'filename'    => ( is => 'rw', isa => 'Str' );
has 'fullpath'    => ( is => 'rw', isa => 'Str' );
has 'bname'       => ( is => 'rw', isa => 'Str' );
has 'quotedname'  => ( is => 'rw', isa => 'Str' );

has 'extention'   => ( is => 'rw', isa => 'Str' );
has 'ext_type'    => ( is => 'rw', isa => 'Str' );
has 'ext_tar'     => ( is => 'rw', isa => 'Bool' );
has 'ext_cmd'     => ( is => 'rw', isa => 'HashRef' );

has 'mime_raw'    => ( is => 'rw', isa => 'Str' );
has 'mime_type'   => ( is => 'rw', isa => 'Str' );
has 'mime_tar'    => ( is => 'rw', isa => 'Bool' );
has 'mime_cmd'    => ( is => 'rw', isa => 'HashRef' );

has 'likely_type' => ( is => 'rw', isa => 'Str' );
has 'likely_tar'  => ( is => 'rw', isa => 'Bool' );
has 'likely_cmd'  => ( is => 'rw', isa => 'HashRef' );

has 'notfirst'    => ( is => 'ro', isa => 'Bool' );

###############################################################################

sub find_mimetype :prototype($\$);

###############################################################################


around BUILDARGS => sub
{
    my $orig  = shift;
    my $class = shift;

    if ( @_ == 3 && !ref( $_[0] ) ) {
        my $filename = $_[0];
        die(qq/File "$filename" doesn't exist./) unless ( -e $filename );
        die("Error: File is a directory.") if ( -d $filename );

        my $fullpath  = rel2abs($filename);
        my $basepath  = Dirname($fullpath);
        my $extention = $filename =~ s/.*\.(.*)/$1/r;
        my $Options   = $_[1];
        my $notfirst  = $_[2];

        return $class->$orig(
            'filename'   => Basename($filename),
            'fullpath'   => $fullpath,
            'basepath'   => $basepath,
            'quotedname' => shell_quote($fullpath),
            'extention'  => $extention,
            'Options'    => $Options,
            'notfirst'   => $notfirst
        );
    }
    else {
        return $class->$orig(@_);
    }
};


sub analysis :prototype($) ($self)
{
    $self->extention_analysis();
    $self->mimetype_analysis();
    $self->finalize_analysis();
    return not $self->ID_Failure;
}


###############################################################################


sub extention_analysis :prototype($) ($self)
{
    my ( $ext_tar, $bname );

    # Some initial naive checks for the filetype based on its extention
    if ( $self->filename =~ /\.tar\..*/ ) {
        $self->ext_tar( true );
        $self->bname( $self->filename =~ s/(.*)\.tar\..*/$1/r );
    }
    else {
        my ( $ext_tar, $extention ) = _check_short_tar($self->extention);
        $self->ext_tar( $ext_tar );
        $self->extention( $extention );
        $self->bname( $self->filename =~ s/(.*)\..*/$1/r );
    }

    $self->ext_type( _normalize_type($self->extention) );
    $self->ext_cmd( $self->determine_decompressor($self->ext_type) );
}


sub _check_short_tar :prototype($) ($extention)
{
    my $ret = '';
    for ($extention) {
        if    (/^(tgz)$/n)          { $ret = 'gz' }
        elsif (/^(tbz|tb2|tbz2)$/n) { $ret = 'bz2' }
        elsif (/^(txz)$/n)          { $ret = 'xz' }
        elsif (/^(tZ|ta[zZ])$/n)    { $ret = 'Z' }
        elsif (/^(tlz)$/n)          { $ret = 'lzma' }
        else                        { return ( false, $extention ) }
    }
    return ( true, $ret );
}


###############################################################################


sub mimetype_analysis :prototype($) ($self)
{
    my ( $app, $mimekind, $dbg_kind ) = (0,0,0);

RETRY:
    $app  = $self->find_mimetype(\$mimekind);

    while ( looks_like_number($app) and $app == 0 and $mimekind <= MAXKIND )
    {
        esayC( 'b', "Mimetype number $dbg_kind failed." ) if $xtar::xtar::DEBUG;
        $dbg_kind = $mimekind;
        $app = $self->find_mimetype(\$mimekind);
    }

    unless ($app) {
        $self->mime_raw('');
        $self->mime_type('');
        $self->mime_tar('');
        return;
    }

    my $orig = $app;
    $app =~ s|.*?/x-(.*)|$1|;

    if ($app =~ /\+/) {
        my @progs = split /\+/, $app;
        foreach (@progs) {
            if   (/tar/) { $self->mime_tar(true) }
            else         { $self->mime_raw($_) }
        }
    }
    elsif ($orig =~ m/application/) {
        if ($orig =~ m/octet|stream/) {
            goto RETRY;
        }
        elsif ($orig =~ m{debian}) {
            $app = 'deb';
            $self->mime_raw($app);
            $self->mime_tar(true);        
        }
        else {
            $app =~ s/.*application.(\S+).*/$1/;
            $self->mime_raw($app);
            $self->mime_tar(false);
        }
    }
    else {
        my @args = split(/ /, $app);
        my $type;
        foreach (@args) {
            last if ( $type = _normalize_type($_) );
        }

        if ( not $type and $xtar::xtar::DEBUG ) {
            carp("Failed to identify mime_raw!");
        }
        $self->mime_raw($type);
        $self->mime_tar(false);
    }

    my $tmp  = lc( $self->mime_raw =~ s/-compressed//ri );
    my $type = _normalize_type($tmp);
    $type = ($type) ? $type : $tmp;

    # If the analysis fails, redo the analysis with several alternative methods
    # until either something works or we run out. The goto is very cludgy.
    if ( not $type and $mimekind < MAXKIND ) {
        goto RETRY;
    }

    $self->mime_type($type);
    $self->mime_cmd( $self->determine_decompressor( $self->mime_type ) );

    if ( $type eq 'zpaq' and $self->extention ne 'zpaq' ) {
        self->move_zpaq();
    }
}


sub find_mimetype :prototype($\$) ($self, $counter)
{
    my ($filename, $qnam) = ($self->fullpath, $self->quotedname);
    my $app;

    if ($$counter < 2) {
        if ( $found_file_unpack == true ) {
            err 'Using File::Unpack' if $xtar::xtar::DEBUG;
            my $unpack = File::Unpack->new();
            my $m      = $unpack->mime( file => $self->fullpath );
            # my $index  = ((${${counter}})++ == 1) ? 0 : 2;
            $app = $m->[0];
        } elsif ( $found_file_libmagic == true ) {
            err 'Using File::LibMagic' if $xtar::xtar::DEBUG;
            my $magic = File::LibMagic->new();
            my $info  = $magic->info_from_filename($self->fullpath);
            $app = $info->{mime_type};
        } else {
            err 'No File::Unpack' if $xtar::xtar::DEBUG;
            $$counter = 2;
        }
    }
    else {
        # Resort to using the `file` command, with a GNU option.
        if ($$counter == 2) {
            err 'Attempting to use GNU file(1)' if $xtar::xtar::DEBUG;
            $app = `file --mime-type $qnam` or ($? <<= 8 && confess("$! - $?"));
            chomp $app;
        }
        # Resort to using `file` with no options. Last gasp.
        elsif ($$counter == 3) {
            err 'Attempting to use generic file(1)' if $xtar::xtar::DEBUG;
            $app = `file $qnam` or confess "$! - $?";
            chomp $app;
        }
        else {
            eprintC( 'bRED', 'Error: ' );
            print STDERR <<'EOF';
No mimetype tools found. If using a *nix system, check whether the `file(1)'
utility is properly installed (it should be). Otherwise, please install the
package `File::Unpack' from cpan or your local package manager if available. I
will attempt to extract using only file extention information. This will fail if
the extention is not accurate or if the file lacks one entirely.
EOF
        }

        ++$$counter;
    }

    return defined($app) ? lc $app : 0;
}


###############################################################################


# If the mimetype analysis produced any results, use them. If it produced
# nothing then we're forced to go by the file suffix. If that also produced
# nothing then either die or resort to random guessing.
sub finalize_analysis :prototype($) ($self)
{
    if ($xtar::xtar::DEBUG) {
        printf qq{mime_type: "%s"\next_type: "%s"\n}, $self->mime_type, $self->ext_type;
    }
    if    ($self->mime_type) { $self->likely_type( $self->mime_type ) }
    elsif ($self->ext_type)  { $self->likely_type( $self->ext_type ) }
    else {
        if ($self->notfirst or $self->Options->{force}) {
            $self->ID_Failure(true);
            esayC('RED', 'Warning: No type identified.') if $self->Options->{force};
            return;
        }
        else {
            esayC 'bRED', <<'EOF';
Error: No type identified at all. If you are sure that this is an archive of
some kind, re-run this program with the -f/--force flag to attempt to extract
it with every known program until something works.
EOF
            exit 127;
        }
    }

    $self->likely_tar($self->ext_tar or $self->mime_tar);
    $self->likely_cmd($self->determine_decompressor($self->likely_type));
}


###############################################################################


sub _normalize_type :prototype($) ($extention)
{
    my $type = '';
    $_ = lc $extention;

    if    (/^(z)$/n)            { $type = 'compress' }
    elsif (/^(gz|bzip)$/n)      { $type = 'gzip' }
    elsif (/^(bz|bz2|bzip2)$/n) { $type = 'bzip2' }
    elsif (/^(xz|lzma)$/n)      { $type = 'xz' }
    elsif (/^(lz)$/n)           { $type = 'lzip' }
    elsif (/^(lz4)$/n)          { $type = 'lz4' }
    elsif (/^(tar)$/n)          { $type = 'tar' }
    elsif (/^(cpio)$/n)         { $type = 'cpio' }
    elsif (/^(7z|7zip|7-zip)/n) { $type = '7zip' }
    elsif (/^(zpaq)$/n)         { $type = 'zpaq' }
    elsif (/^(zip)$/n)          { $type = 'zip' }
    elsif (/^(arc)$/n)          { $type = 'arc' }
    elsif (/^(ace|winace)$/n)   { $type = 'ace' }
    elsif (/^(rar)$/n)          { $type = 'rar' }
    elsif (/^(a)$/n)            { $type = 'archive' }
    elsif (/^(zst)$/n)          { $type = 'zstd' }

    return $type;
}


sub move_zqaq ($self)
{
    mv( $self->fullpath, $self->fullpath . '.zpaq');
    $self->fullpath($self->fullpath . '.zpaq');
    $self->filename(Basename($self->fullpath));
    $self->extention('zpaq');
}


###############################################################################

sub find_cpio_decompressor :prototype();


sub determine_decompressor : prototype($$) ($self, $type)
{
    my ($CMD, $TFlags, $EFlags, $allFlags, $Stdout, $NeedOdir);
    my $V     = $self->Options->{verbose};
    my $Q     = $self->Options->{quiet};
    my $v7z   = ($Q) ? '-bso0 -bsp0' : '';
    my $vzpaq = ($V) ? '' : ' >/dev/null';
    my $tmp   = '';

    $TFlags = $EFlags = $allFlags = '';
    $_      = $type;

    if (/^(z|compress)$/ni and which('uncompress')) {
        $CMD      = 'uncompress';
        $allFlags = '-c';
        $Stdout   = true;
    }
    elsif (/^(gz|z|gzip|compress)$/ni and which('gzip')) {
        $CMD      = 'gzip';
        $allFlags = '-dc';
        $Stdout   = true;
    }
    elsif (/^(bz|bz2|bzip[2]?)$/ni and which('bzip2')) {
        $CMD    = 'bzip2';
        $allFlags = '-dc';
        $Stdout = true;
    }
    elsif (/^(xz|lzma)$/ni and which('xz')) {
        $CMD    = 'xz';
        $allFlags = '-dc';
        $Stdout = true;
    }
    elsif (/^(lz|lzip)$/ni and which('lzip')) {
        $CMD      = 'lzip';
        $allFlags = '-dc';
        $Stdout   = true;
    }
    elsif (/^(lz4)$/ni and which('lz4')) {
        $CMD      = 'lz4';
        $allFlags = '-dc';
        $Stdout   = true;
    }
    elsif (/^(zstd)$/ni and which('zstd')) {
        $CMD      = 'zstd';
        $allFlags = '-dc';
        $Stdout   = true;
    }
    elsif (/^(tar)$/ni) {
        $CMD    = 'TAR';
        $TFlags = '-xf -- -O';
        $EFlags = '-xf';
    }
    elsif (/^(cpio)$/ni and ($tmp = find_cpio_decompressor())) {
        if ($tmp == 1) {
            $CMD    = 'bsdtar';
            $TFlags = '-xf -- -O';
            $EFlags = '-xf';
        } else {
            croak 'Should not be possible?!';
        }
        # Screw cpio
        #elsif ($tmp == 2) {
        #    $CMD = 'cpio';
        #    $TFlags = ''
        #}
    }
    elsif (/^(a|archive)$/ni and which('ar')) {
        $CMD    = 'ar';
        $TFlags = 'NOTAR';
        $EFlags = 'x';
    }
    # elsif (/^(deb)$/ni and which('dpkg')) {
    #     $CMD = 'dpkg';
    #     $TFlags = 'NOTAR';
    #     $EFlags = '--unpack';
    #     $NeedOdir = true;
    # }
    elsif (/^(7z|gz|bz|bz2|xz|lzma|lz|lz4|zip|cpio|rar|z|jar|
              deb|rpm|a|ar|iso|img|0{1,2}[1-9]|
              compress|gzip|bzip2?|7[-]?zip|archive|
              ima # floppy image
             )$/nxi
          and which('7z'))
    {
       $CMD    = '7z';
       $TFlags = "$v7z -so x";
       $EFlags = "$v7z x";
    }
    elsif (/^(zpaq)$/ni and which('zpaq')) {
        $CMD    = 'zpaq';
        $TFlags = 'NOTAR';
        $EFlags = "x -- -to tmp" . $vzpaq;
    }
    elsif (/^(zip)$/ni and which('unzip')) {
        $CMD      = 'unzip';
        $TFlags   = '-p';
        $allFlags = '-q';
    }
    elsif (/^(arc)$/ni and which('arc')) {
        $CMD    = 'arc';
        $TFlags = 'p';
        $EFlags = 'x';
    }
    elsif (/^(ace|winace)$/ni and which('unace')) {
        $CMD      = 'unace';
        $allFlags = 'x';
    }
    elsif (/^(rar)$/ni and which('unrar')) {
        $CMD      = 'unrar';
        $allFlags = 'x';
    }

    return {
        CMD      => $CMD,
        tflags   => $TFlags . ($TFlags and $allFlags ? ' ' : '') . $allFlags,
        eflags   => $EFlags . ($TFlags and $allFlags ? ' ' : '') . $allFlags,
        stdout   => $Stdout,
        needodir => $NeedOdir,
    };
}


sub find_cpio_decompressor :prototype() ()
{
    return which('bsdtar') ? 1 : 0;
}


###############################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
