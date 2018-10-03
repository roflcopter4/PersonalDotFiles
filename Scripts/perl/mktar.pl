#!/usr/bin/env perl
use warnings; use strict; use v5.22;
#no warnings 'experimental';
use constant true  => 1;
use constant false => 0;

use Cwd qw( getcwd );
use Carp;
use DateTime;
# use Path::Class;
use File::Which;
use File::Basename;
# use File::Copy::Recursive qw( fcopy );
use File::Temp qw( tempfile tempdir );
use File::Spec::Functions qw( rel2abs abs2rel catfile );
use Getopt::Long qw(:config gnu_getopt no_ignore_case);

# $File::Copy::Recursive::CopyLink = true;

###############################################################################

our $DEBUG;
our ( $TopDir, $BaseDir, $Verbose );
our $TimeStamp = time;
our $CWD       = getcwd;
our $TmpDir;

###############################################################################


sub show_usage
{
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


sub get_odir
{
    if ( -w $CWD ) {
        return rel2abs($CWD);
    }
    else {
        warn 'Current directory is not writable. Placing archive in your home '
           . "directory.\n";
        return $ENV{HOME};
    }
}


sub get_tempdir
{
    my @target_info = stat $ARGV[0];
    my $C = 1;
    my $dir;
    
    if ( $target_info[0] == [stat '/tmp']->[0] ) {
        $dir = tempdir( CLEANUP => $C );
    }
    elsif ( -w $CWD ) {
        $dir = tempdir( CLEANUP => $C, DIR => $CWD );
    }
    elsif ( $target_info[0] == [stat $ENV{'HOME'}]->[0] ) {
        $dir = tempdir( CLEANUP => $C, DIR => $ENV{'HOME'} );
    }
    else {
        print STDERR <<'EOF';
Fatal error: This script requires there to be a writable directory on the same
filesystem as the targets.
EOF
        exit 1;
    }

    say STDERR "Using $dir as tmpdir." if $DEBUG;
    return $dir;
}


sub sayG
{
    my $str = shift or confess('Invalid usage.');
    say "\033[1;36m" . $str . "\033[0m";
}


sub link_file
{
    my ( $file, $target ) = ( shift, shift ) or confess("Invalid args.");
    $file = rel2abs($file);
    $target = rel2abs($target);
    (
        ( -w $file ) and (
            $Verbose && $DEBUG && say STDERR "link '$file' to '$target'"
            or true
        )
        and link( $file, $target )
    ) or (
        # (
            # $DEBUG && say STDERR "Failed to link '$file' to '$target'. $!"
            # or true
        # )
        true
        and fcopy( $file, $target )
        and (
                $DEBUG && say STDERR 'Successful copy.'
                or true
            )
    ) or (
        say STDERR "Failed to copy '$file' to '$target!'"
    )
}


###############################################################################
# Setup and option handing

my $rc = eval {
    require Unix::Processors;
    Unix::Processors->import();
    1;
};

my $wc = eval {
    require Win32::SystemInfo;
    Win32::SystemInfo->import();
    1;
};

my ( $procs, $UseCores );

if ( $rc ) {
    $procs = new Unix::Processors;
    $UseCores = $procs->max_online;
}
elsif ( which( 'nproc' ) ) {
    $procs = `nproc`;
    chomp $procs;
    $UseCores = int( $procs );
}
elsif ( $wc ) {
    $UseCores = Win32::SystemInfo::ProcessorInfo( 'NumProcessors' );
}
else {
    $UseCores = 4; # Just pick a number I guess.
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
    'N|notar'    => \$notar,
    'd|debug'    => \$DEBUG
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

for ($type)
{
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
    elsif (/^(zpaq|zq|zp)$/n) {
        # if ($notar) { $basetype = 'zpaq' }
        # else        { $basetype = 'tzpaq' }
        $basetype = 'zpaq';
    }
    elsif (/^(tzpaq|tzq|tzp)$/n) {
        $basetype = 'tzpaq';
    }
    else {
        say STDERR "Filetype '$type' not recognized.";
        show_usage(2);
    }
}

if ( $notar and not $type =~ /^(zip|7z|zpaq)$/ ) {
    die "Error: Only zip, 7zip, and zpaq can make archives without tar.";
}


###############################################################################
# Get our names and check whether we have GNU cp(1).

foreach my $file (@ARGV) {
    my @target_info = stat $ARGV[0];
    unless ( -e $file ) {
        say STDERR "Fatal error: File '$file' does not exist.";
        exit 127;
    }

    unless ( $target_info[0] == [stat $file]->[0] ) {
        say STDERR 'Fatal error: This script requires all targets',
            ' to be on the same filesystem.';
        exit 1;
    }
}

my ( $OutDir, $OutName );
if ( defined($output) ) {
    if ( $output =~ m|^/| ) {
        $OutDir  = dirname $output;
        $OutName = basename $output;
    }
    elsif ( $output =~ m|/| ) {
        $OutDir  = dirname( rel2abs($output) );
        $OutName = basename $output;
    }
    else {
        $OutDir  = get_odir;
        $OutName = $output;
    }
}
else {
    my $dt = DateTime->now;
    $OutDir  = get_odir;
    # $OutName = 'archive_' . $dt->dmy . '_' . $dt->hour . $dt->minute;
    my $time = $dt->hms('') =~ s/^(\d{4}).*/$1/r;
    $OutName = 'archive_' . $dt->dmy . '_' . $time;
}

$TAR = 'tar' unless ( defined($TAR) and which($TAR) );

my $CP;
system('cp --help >/dev/null 2>&1');
if ( $? == 0 ) {
    $CP = 'cp';
}
else {
    system('gcp --help >/dev/null 2>&1');
    if ( $? == 0 ) { $CP = 'gcp' }
    else           { die "ERROR: This script requires GNU `cp(1)'.\n" }
}


###############################################################################
# Set everything up

my $single;
if ( @ARGV == 1 ) {
    $TopDir = basename( $ARGV[0] );
    $single = true;
    $OutName = $TopDir unless ( defined($output) );
}
else {
    $TopDir = $OutName;
    $single = false;
}

if    ( $basetype eq 'zpaq' )  { $OutName .= '.zpaq' }
elsif ( $basetype eq 'tzpaq' ) { $OutName .= '.tar.zpaq' }
elsif ( $notar )               { $OutName .= ".${basetype}" }
else                           { $OutName .= ".tar.${basetype}" }

my $TDirFull;
my $ONameFull = "${OutDir}/${OutName}";
my $RelName   = $ONameFull =~ s|$CWD/(.*)|$1|r;

if ( $single and -d $ARGV[0] ) {
    $TDirFull = rel2abs($ARGV[0]);
    chdir dirname($TDirFull);
}
else {
    $TmpDir   = get_tempdir();
    $TDirFull = "${TmpDir}/${TopDir}";

    say "mkdir '$TDirFull'" if $Verbose;;
    mkdir $TDirFull or croak 'Failed to make temporary directory.';

    while (@ARGV) {
        my $arg = shift;
        my $TMP = $TDirFull;

        # if ( -d $arg ) {
        #     my $root = dir($arg);
        # 
        #     $root->traverse_if(
        #         sub {
        #             my ( $child, $cont ) = @_;
        #             my $relto = ($single) ? $root : $root->parent();
        # 
        #             # return unless ( -r $child );
        # 
        #             if ( $child->is_dir ) {
        #                 my $target = catfile( $TMP, $child->relative($relto) );
        #                 unless ( -e $target ) {
        #                     mkdir $target
        #                       or confess "Failed to make directory '$target'.\n$!";
        #                 }
        #             }
        #             else {
        #                 my $target = catfile( $TMP, $child->relative($relto) );
        #                 link_file( $child, $target );
        #             }
        # 
        #             return $cont->();
        #         },
        #         sub {
        #             my ($child) = @_;
        # 
        #             # Process only readable items
        #             return (-r $child);
        #         }
        #     );
            # $root->recurse(
            #     callback => sub {
            #         my $file = shift;
            #         my $relto = ($single) ? $root : $root->parent();
            # 
            #         return unless ( -r $file );
            # 
            #         if ( $file->is_dir ) {
            #             my $target = catfile( $TMP, $file->relative($relto) );
            #             unless ( -e $target ) {
            #                 mkdir $target
            #                   or confess "Failed to make directory '$target'.\n$!";
            #             }
            #         }
            #         else {
            #             my $target = catfile( $TMP, $file->relative($relto) );
            #             link_file( $file, $target );
            #         }
            #     }
            # );
        # }
        # else {
        #     my $target = catfile($TMP, basename($arg));
        #     link_file( $arg, $target );
        # }

        say "$CP -Rla $arg $TDirFull 2>/dev/null" if $Verbose;
        say "$CP -Rna $arg $TDirFull 2>/dev/null" if $Verbose;
        system "$CP -Rla $arg $TDirFull 2>/dev/null";
        system "$CP -Rna $arg $TDirFull 2>/dev/null";
    }

    say "cd '$TmpDir'" if $Verbose;
    chdir $TmpDir or croak 'Failed to cd to the temporary directory!';
}


###############################################################################
# Now for the command. What a mess.

SKIP:

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

# Make triply certain we are able to rid of the temporary directory.
chdir $CWD;
