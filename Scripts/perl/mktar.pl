#!/usr/bin/perl
use warnings; use strict; use v5.26;
use feature 'signatures';
no warnings qw( experimental );
use Cwd qw( getcwd realpath );
use Carp;
use File::Basename;
use File::Copy;
use File::Find;
use File::Which;
use File::Temp qw( tempfile tempdir cleanup );
use Getopt::Long qw(:config gnu_getopt no_ignore_case);

our ( $TopDir, $BaseDir );
our $TimeStamp = time;
our $CWD       = getcwd;
our $TmpDir    = tempdir CLEANUP => 1;

###############################################################################

sub show_usage {
    my $status;
    $status = shift or $status = 0;
    my $THIS = basename $0;
    say "USAGE: $THIS [OPTIONS] FILE(S)...\n";
    print << 'EOF';
 -h, --help       Show this help and exit
 -V, --version    Show version info and exit
 -t, --type       Specify archive type (see list below) - defaults to xz
 -T, --tar        Specify tar binary to use
 -l, --level      Specify the compression 'level' to pass to the program
 -o, --output     Specify the basename of the output file (without extension)
 -b, --bsdtar     Shorthand for --tar=bsdtar
 -g, --gtar       Shorthand for --tar=gtar

Types recognized: xz, bzip2, gzip, Z, 7zip, zpaq, tzpaq, zip.
Most types have a few alternate spellings that are acceptable.
Zpaq archives are the only one not created as a tar.(type) archive because the
zpaq program refuses to take stdin. Use tzpaq to force creatoion of a tarball.
EOF
    exit $status;
}

sub get_odir {
    if ( -w $CWD ) {
        return realpath $CWD;
    }
    else {
        warn 'Current directory is not writable. Placing archive in your home '
           . "directory.\n";
        return ENV {'HOME'};
    }
}

###############################################################################
# Setup and option handing

my $UseCores = `nproc --all` or confess 'Failed to set UseCores!';
$UseCores =~ s/\n//;
my $v7z  = '-bso0 -bsp0';

# Some sensible defaults
my $type = 'xz';
my $lev9 = 9;
my $lev5 = 5;

my ( $help, $version, $output, $level, $TAR, $gtar, $bsdtar );

GetOptions(
    'h|help'     => \$help,
    'V|version'  => \$version,
    't|type=s',  => \$type,
    'T|tar=s'    => \$TAR,
    'l|level=i'  => \$level,
    'o|output=s' => \$output,
    'b|bsdtar'   => \$bsdtar,
    'g|gtar'     => \$gtar
) or show_usage(1);

if ( defined($level) ) {
    if ( $level <= 9 ) { $lev9 = $level }
    if ( $level <= 5 ) { $lev5 = $level }
}

if ($version) { say "mktar.pl version 0.0.1" and exit 0 }
if ($help)    { show_usage(0) }

if    ($bsdtar) { $TAR = 'bsdtar' }
elsif ($gtar)   { $TAR = 'gtar' }

unless (@ARGV) { die "FATAL ERROR: No input files!\n" }

###############################################################################
# Check validity of archive type

my ( $basetype, @CMD );

given ($type) {
    when (/^(?:xz)$/) {
        $basetype = 'xz';
        @CMD = ( 'xz', "-T${UseCores}", "-${lev9}", '>' );
    }
    when (/^(?:gz|gzip)$/) {
        $basetype = 'gz';
        @CMD = ( 'gzip', "-${lev9}", '-c', '>' );
    }
    when (/^(?:bz|bz2|bzip|bzip2)$/) {
        $basetype = 'bz2';
        @CMD = ( 'bzip2', "-${lev9}", '-c', '>' );
    }
    when (/^(?:z|Z)$/) {
        $basetype = 'Z';
        @CMD      = qw( compress -c > );
    }
    when (/^(?:zip)$/) {
        $basetype = 'zip';
        @CMD = ( 'zip', "-${lev9}", '>' );
    }
    when (/^(?:7z|7zip)$/) {
        $basetype = '7z';
        @CMD      = (
            '7z', 'a', $v7z, qw( -ms=on -md=512m -mfb=256 -m0=lzma2 ),
            "-mmt=${UseCores}", "-mx=${lev9}", -'si'
        );
    }
    when (/^(?:zpaq|zq|zp)$/)   { $basetype = 'zpaq'; }
    when (/^(?:tzpaq|tzq|tzp)$/) { $basetype = 'tzpaq'; }
    default { warn "Filetype '$type' not recognized.\n" and show_usage(2); }
}

my ( $OutDir, $OutName );
if ( defined($output) ) {
    if ( $output =~ m|^/| ) {
        $OutDir  = dirname $output;
        $OutName = basename $output;
    }
    elsif ( $output =~ m|/| ) {
        $OutDir  = dirname( realpath($output) );
        $OutName = basename $output;
    }
    else {
        $OutDir  = get_odir;
        $OutName = $output;
    }
}
else {
    $OutDir  = get_odir;
    $OutName = $TimeStamp;
}

unless ( defined($TAR) and which($TAR) ) {
    if   ( which('bsdtar') ) { $TAR = 'bsdtar'; }
    else                     { $TAR = 'tar'; }
}

my $CP;
system('cp  --help >/dev/null 2>&1');
if ( $? == 0 ) { 
    $CP = 'cp';
}
else {
    system('gcp --help >/dev/null 2>&1');
    if ( $? == 0 ) {
        $CP = 'gcp';
    }
    else {
        die "ERROR: This script requires GNU cp.\n";
    }
}

###############################################################################
# Set everything up

if ( @ARGV == 1 and -d $ARGV[0] ) {
    $TopDir = basename $ARGV[0];
    $OutName = $TopDir;
}
else {
    $TopDir = $OutName;
}

if    ( $basetype eq 'zpaq' )  { $OutName .= '.zpaq'; }
elsif ( $basetype eq 'tzpaq' ) { $OutName .= '.tar.zpaq'; }
else                           { $OutName .= ".tar.${basetype}" }

my $TDirFull  = "${TmpDir}/${TopDir}";
my $ONameFull = "${OutDir}/${OutName}";

mkdir $TDirFull or croak 'Failed to make temporary directory.';

while (@ARGV) {
    my $arg = shift;
    system "$CP -rla $arg $TDirFull 2>/dev/null";
    system "$CP -rna $arg $TDirFull 2>/dev/null";
}

chdir $TmpDir or confess 'Failed to cd to the temporary directory!';

###############################################################################
# Now for the command. What a mess.

# zpaq is "special".
if ( $basetype eq 'zpaq' ) {
    say    "zpaq a $ONameFull $TopDir -m$lev5 -t$UseCores";
    system "zpaq a '$ONameFull' '$TopDir' -m$lev5 -t$UseCores >/dev/null";
}
elsif ( $basetype eq 'tzpaq' ) {
    my ( $FH, $tmpnam ) = tempfile(SUFFIX => ".tar", TMPDIR => 1);

    say    "$TAR -cf $tmpnam $TopDir";
    system "$TAR -cf '$tmpnam' '$TopDir' 2>/dev/null";

    say    "zpaq a $ONameFull $tmpnam -m$lev5 -t$UseCores";
    system "zpaq a '$ONameFull' '$tmpnam' -m$lev5 -t$UseCores >/dev/null";

    unlink $tmpnam or cluck("ERROR: Failed to unlink file '$tmpnam'.");
}
# Normal programs
else {
    say    "$TAR -cf - $TopDir | @CMD $ONameFull";
    system "$TAR -cf - '$TopDir' 2>/dev/null | @CMD '$ONameFull'";
}

# Get rid of the temporary directory.
chdir $CWD;
cleanup;