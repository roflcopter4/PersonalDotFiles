#!/usr/bin/env perl
use warnings; use strict; use v5.22;
#no warnings 'experimental';
use Cwd qw( getcwd realpath );
use Carp;
use boolean;
use File::Basename;
use File::Which;
use File::Temp qw( tempfile tempdir cleanup );
use Getopt::Long qw(:config gnu_getopt no_ignore_case);
use Unix::Processors;

###############################################################################

our ( $TopDir, $BaseDir, $Verbose );
our $TimeStamp = time;
our $CWD       = getcwd;
our $TmpDir    = get_tempdir();

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
 -N, --notar      Don't tar the files first. SUITABLE FOR ZIP OR 7ZIP ONLY.

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

sub get_tempdir {
    my @CWD_info  = stat $CWD;
    my @dest_info = stat '/tmp';

    if ( $CWD_info[0] == $dest_info[0] ) {
        return tempdir( CLEANUP => 1 );
    }

    if ( -w $CWD ) {
        return tempdir( CLEANUP => 1, DIR => $CWD );
    }

    @dest_info = stat( $ENV{'HOME'} );
    if ( $CWD_info[0] == $dest_info[0] ) {
        return tempdir( CLEANUP => 1, DIR => $ENV{'HOME'} );
    }

    return tempdir( CLEANUP => 1 );
}

###############################################################################
# Setup and option handing

my $UseCores;
{
    my $procs = new Unix::Processors;
    $UseCores = $procs->max_online;
}

my $v7z  = '-bso0 -bsp0';

# Some sensible defaults
my $type = 'xz';
my $lev9 = 9;
my $lev5 = 5;

my ( $help, $version, $output, $level, $TAR, $gtar, $bsdtar, $notar );

GetOptions(
    'h|help'     => \$help,
    'V|version'  => \$version,
    'v|verbose'  => \$Verbose,
    't|type=s',  => \$type,
    'T|tar=s'    => \$TAR,
    'l|level=i'  => \$level,
    'o|output=s' => \$output,
    'b|bsdtar'   => \$bsdtar,
    'g|gtar'     => \$gtar,
    'N|notar'    => \$notar
) or show_usage(1);

if ( defined($level) ) {
    if ( $level <= 9 ) { $lev9 = $level }
    if ( $level <= 5 ) { $lev5 = $level }
}

if ($version) { say "mktar version 3.0 (perl)" and exit 0 }
if ($help)    { show_usage(0) }

if    ($bsdtar) { $TAR = 'bsdtar' }
elsif ($gtar)   { $TAR = 'gtar' }

unless (@ARGV) { die "Error: No input files\n" }

if ( not defined $output and @ARGV > 1 and not -e $ARGV[0] ) {
    $output = shift;
    unless (@ARGV) { die "Error: No input files\n" }
}

###############################################################################
# Check validity of archive type

my ( $basetype, @CMD, $tmp );

for ($type) {
    if (/^(xz)$/n) {
        $basetype = 'xz';
        @CMD = ( 'xz', "-T${UseCores}", "-${lev9}", '>' );
    }
    elsif (/^(gz|gzip)$/n) {
        $basetype = 'gz';
        @CMD = ( 'gzip', "-${lev9}", '-c', '>' );
    }
    elsif (/^(bz|bz2|bzip|bzip2)$/n) {
        $basetype = 'bz2';
        @CMD = ( 'bzip2', "-${lev9}", '-c', '>' );
    }
    elsif (/^(z|Z)$/n) {
        $basetype = 'Z';
        @CMD      = qw( compress -c > );
    }
    elsif (/^(zip)$/n) {
        $basetype = 'zip';
        $tmp = ( $notar ) ? '-r' : '>';
        @CMD = ( "zip -${lev9}", $tmp );
        #$notar = 1;
    }
    elsif (/^(7z|7zip)$/n) {
        $basetype = '7z';
        $tmp      = ( $notar ) ? '' : '-si';
        @CMD      = ( '7z', 'a', $v7z, qw( -ms=on -md=512m -mfb=256 -m0=lzma2 ),
                      "-mmt=${UseCores}", "-mx=${lev9}", $tmp );
    }
    elsif (/^(zpaq|zq|zp)$/n)    { $basetype = 'zpaq' }
    elsif (/^(tzpaq|tzq|tzp)$/n) { $basetype = 'tzpaq' }

    else {
        warn "Filetype '$type' not recognized.\n";
        show_usage(2);
    }
}

if ( $notar and not $type =~ /^(zip|7z)$/ ) {
    die "Error: Only zip, 7zip, and zpaq can make archives without tar.";
}

###############################################################################
# Get our names and check whether we have GNU cp(1).

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
    #if   ( which('bsdtar') ) { $TAR = 'bsdtar' }
    #else                     { $TAR = 'tar' }
    $TAR = 'tar';
}

my $CP;
system('cp  --help >/dev/null 2>&1');
if ( $? == 0 ) { $CP = 'cp' }
else {
    system('gcp --help >/dev/null 2>&1');
    if ( $? == 0 ) { $CP = 'gcp' }
    else           { die "ERROR: This script requires GNU cp.\n" }
}

###############################################################################
# Set everything up

my $single;
if ( @ARGV == 1 ) {
    $TopDir = basename( $ARGV[0] );
    $single = true;
    if ( not defined($output) and -d $ARGV[0] ) {
        $OutName = $TopDir;
    }
}
else {
    $TopDir = $OutName;
    $single = false;
}

if    ( $basetype eq 'zpaq' )  { $OutName .= '.zpaq' }
elsif ( $basetype eq 'tzpaq' ) { $OutName .= '.tar.zpaq' }
elsif ( $notar )               { $OutName .= ".${basetype}" }
else                           { $OutName .= ".tar.${basetype}" }

my $TDirFull  = "${TmpDir}/${TopDir}";
my $ONameFull = "${OutDir}/${OutName}";
my $RelName = $ONameFull =~ s|$CWD/(.*)|$1|r;

say "mkdir '$TDirFull'" if $Verbose;;
mkdir $TDirFull or croak 'Failed to make temporary directory.';

while (@ARGV) {
    my $arg = shift;
    # if ( $single ) {
    #     print <<~ "EOF" if $Verbose;
    #         $CP -rla $arg $TmpDir 2>/dev/null
    #         $CP -rna $arg $TmpDir 2>/dev/null
    #         EOF
    #     system "$CP -rla $arg $TmpDir 2>/dev/null";
    #     system "$CP -rna $arg $TmpDir 2>/dev/null";
    # }
    # else {
    #     print <<~ "EOF" if $Verbose;
    #         $CP -rla $arg $TDirFull 2>/dev/null
    #         $CP -rna $arg $TDirFull 2>/dev/null
    #         EOF
    #     system "$CP -rla $arg $TDirFull 2>/dev/null";
    #     system "$CP -rna $arg $TDirFull 2>/dev/null";
    # }
    if ( $single ) {
        say "$CP -rla $arg $TmpDir 2>/dev/null" if $Verbose;
        say "$CP -rna $arg $TmpDir 2>/dev/null" if $Verbose;
        system "$CP -rla $arg $TmpDir 2>/dev/null";
        system "$CP -rna $arg $TmpDir 2>/dev/null";
    }
    else {
        say "$CP -rla $arg $TDirFull 2>/dev/null" if $Verbose;
        say "$CP -rna $arg $TDirFull 2>/dev/null" if $Verbose;
        system "$CP -rla $arg $TDirFull 2>/dev/null";
        system "$CP -rna $arg $TDirFull 2>/dev/null";
    }
}

say "cd '$TmpDir'" if $Verbose;
chdir $TmpDir or croak 'Failed to cd to the temporary directory!';

###############################################################################

sub sayG {
    my $str = shift or croak();
    say "\033[1m\033[32m" . $str . "\033[0m";
}

###############################################################################
# Now for the command. What a mess.

# zpaq is "special".
if ( $basetype eq 'zpaq' ) {
    sayG   "zpaq a $RelName $TopDir -m$lev5 -t$UseCores >/dev/null 2>&1";
    system "zpaq a '$ONameFull' '$TopDir' -m$lev5 -t$UseCores >/dev/null 2>&1";
}
elsif ( $basetype eq 'tzpaq' ) {
    my ( $FH, $tmpnam ) = tempfile(SUFFIX => ".tar", TMPDIR => 1);

    sayG   "$TAR -cf $tmpnam $TopDir";
    system "$TAR -cf '$tmpnam' '$TopDir' 2>/dev/null";

    sayG   "zpaq a $RelName $tmpnam -m$lev5 -t$UseCores";
    system "zpaq a '$ONameFull' '$tmpnam' -m$lev5 -t$UseCores >/dev/null 2>&1";

    unlink $tmpnam or cluck("ERROR: Failed to unlink file '$tmpnam'.");
}
# Any other commands that can make an archive without tar.
elsif ( $notar ) {
    sayG   "@CMD $RelName $TopDir";
    system "@CMD '$ONameFull' '$TopDir' >/dev/null";
}
# Normal programs.
else {
    sayG   "$TAR -cf - $TopDir | @CMD $RelName";
    system "$TAR -cf - '$TopDir' 2>/dev/null | @CMD '$ONameFull'";
}

# Get rid of the temporary directory.
chdir $CWD;
cleanup;
