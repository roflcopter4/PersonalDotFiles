#!/usr/bin/env perl
use warnings; use strict; use v5.26;
use feature 'signatures';
no warnings 'experimental';
use Cwd qw( getcwd realpath );
use Carp;
use boolean;
use File::Basename;
use File::Which;
use File::Copy qw( mv );
use File::Path qw( make_path );
use File::Temp qw( tempdir cleanup );
use Getopt::Long qw(:config gnu_getopt no_ignore_case);
use Data::Dumper 'Dumper';

###############################################################################
# A few globals.

our $CWD       = getcwd();
our $TimeStamp = time;
our $v7z       = '-bso0 -bsp0';
our ( $TAR, $IsTar, $Force, $Num, $odir_given, $Verbose );
our ( %File, %Out, $RunNo );

###############################################################################

sub show_usage($status) {
    my $THIS = basename $0;
    print "Usage: ${THIS} [options] archive(s)...\n\n";
    print << 'EOF';
Extract an archive safely to a unique directory, ensuring no irritating
single sub-directories or lots of loose files are created. See the manual for
more detailed information.

OPTIONS
 -h --help      Show this usage information.
 -V --version   Show version.
 -v --verbose   Verbose mode. Display progress information if possible.
 -o --top [DIR] Explicitly specify output directory. If it already exists,
                time_t will be appended to it. When used with multiple
                archives it will function as a top directory with each archive
                extracted to sub-directories, unless -c is supplied, whereupon
                all archives are combined into it.
 -c --combine   Combine multiple archives. When -o is not supplied, a directory
                name is generated from the name of the first supplied archive.
                *** NOT IMPLEMENTED ***
 --tar [ARG]    Explicity specify the tar binary to use.
 -b             Use bsdtar over 'tar' if it exists, otherwise fall back to tar.
 -g             Use gtar if it exists, otherwise fall back to tar.
 -f --force     Force: try to extract an unknown archive by trial and error.
EOF
    exit $status;
}

###############################################################################
# Utility

sub find_tar($test) {
    if   ( which($test) ) { return $test }
    else                  { return 'tar' }
}

sub handle_conflict ( $path, $name ) {
    my $i        = 1;
    my $new_name = "${path}/${name}-${TimeStamp}";

    unless ( defined $Out{'dir'} and $new_name eq $Out{'dir'} ) {
        while ( -e $new_name ) {
            $new_name = "${path}/${name}-${TimeStamp}-${i}";
            ++$i;
        }
    }

    return $new_name;
}

sub betterglob {
    my @files = glob('* .*');
    my @filter;

    foreach my $cur (@files) {
        next if ( $cur eq '.' or $cur eq '..' );
        push @filter, $cur;
    }

    return @filter;
}

sub get_tempdir {
    my @archive_info  = stat $File{'fullpath'};
    my @dest_info     = stat '/tmp';

    # Try to put the tmpdir in /tmp, but only if it's on the same filesystem.
    if ( $archive_info[0] == $dest_info[0] ) {
        return tempdir( CLEANUP => 1 );
    }

    @dest_info = stat $CWD;
    # If /tmp is on a different filesystem try to put the tmpdir in the current
    # if it's writeable. We're extracting a file here, it ought to be.
    if ( $archive_info[0] == $dest_info[0] and -w $CWD ) {
        return tempdir( CLEANUP => 1, DIR => $CWD );
    }

    # If the current directory isn't writable, try putting the tmpdir in the
    # user's home directory, but again only if it's on the same filesystem.
    @dest_info = stat( $ENV{'HOME'} );
    if ( $archive_info[0] == $dest_info[0] ) {
        return tempdir( CLEANUP => 1, DIR => $ENV{'HOME'} );
    }

    # If all else fails there's little recourse but to put the thing in /tmp.
    # Or crash the program. I prefer that choice, honestly.
    die << 'EOF';
/tmp is on a different filesystem and the current directory is not writeable.
Cannot continue without making a temporary directory on the same filesystem as
the archive. Aborting command.
EOF
}

###############################################################################
# Analysis

sub analyze_file($filename) {
    $File{'ext'}      = $filename =~ s/.*\.(.*)/$1/r;
    $File{'name'}     = basename($filename);
    $File{'fullpath'} = realpath($filename);
    $File{'path'}     = dirname( $File{'fullpath'} );

    if ( $filename =~ /\.tar\..*/ ) {
        $IsTar = true;
        $File{'bname'} = $File{'name'} =~ s/(.*)\.tar\..*/$1/r;
    }
    else {
        $IsTar = check_short_tar($filename);
        $File{'bname'} = $File{'name'} =~ s/(.*)\..*/$1/r;
    }
}

sub check_short_tar($filename) {
    given ($filename) {
        when (/^(tgz)$/n)          { $File{'ext'} = 'gz' }
        when (/^(tbz|tb2|tbz2)$/n) { $File{'ext'} = 'bz2' }
        when (/^(txz)$/n)          { $File{'ext'} = 'xz' }
        when (/^(tZ|taz|taZ)$/n)   { $File{'ext'} = 'Z' }
        when (/^(tlz)$/n)          { $File{'ext'} = 'lzma' }
        default                    { return false }
    }
    return true;
}

sub get_odir {
    if ( defined $odir_given ) {
        if ( $RunNo == 1 ) {
            $Out{'path'} = realpath($odir_given);
            if ( -e $Out{'path'} ) {
                $Out{'path'} = handle_conflict(dirname( $Out{'path'} ),
                                               basename( $Out{'path'} ));
            }
        }

        if ( $Num == 1 ) {
            $Out{'name'} = basename( $Out{'path'} );
            $Out{'path'} = dirname( $Out{'path'} );
        }
        else {
            $Out{'name'} = $File{'bname'};
        }
    }
    else {
        $Out{'path'} = $CWD;
        $Out{'name'} = $File{'bname'};
    }

    $Out{'orig_name'} = $Out{'name'};
    $Out{'dir'} = "$Out{'path'}/$Out{'name'}";

    if ( -e $Out{'dir'} ) {
        $Out{'dir'} = handle_conflict( $Out{'path'}, $Out{'name'} );
    }
}

###############################################################################

sub do_extract {
    make_path( $Out{'dir'} );
    chdir $Out{'dir'};
    say 'mkdir && cd ' . basename( $Out{'dir'} ) if $Verbose;

    my ( $CMD, $TFlags, $EFlags, $Stdout ) = determine_decompressor($File{'ext'});

    if ( $CMD eq 'FAIL' ) {
        return false unless ( $Force and force_extract($File{'fullpath'}) )
    }
    else {
        print "\033[32m";
        if   ($IsTar) { extract_tar($CMD, $TFlags, $Stdout) }
        else          { extract_else($CMD, $EFlags, $Stdout) }
        print "\033[0m\n";
    }

    my @files = betterglob();

    while ( @files == 1 ) {
        my $lonefile = $files[0];

        if (   ( defined $odir_given and $Num == 1 )
            or ( $lonefile eq $Out{'orig_name'} ) )
        {
            $Out{'old_dir'} = $Out{'dir'};
        }
        else {
            if ( -e "$Out{'path'}/$lonefile" ) {
                $Out{'name'} = handle_conflict( $Out{'path'}, $lonefile );
                $Out{'name'} = basename( $Out{'name'} );
            }
            else {
                $Out{'name'} = $lonefile;
            }

            $Out{'old_dir'} = $Out{'dir'};
            $Out{'dir'}     = "$Out{'path'}/$Out{'name'}";
        }

        # Shuffle things around
        my $TmpDir = get_tempdir();
        say qq(mv $Out{'old_dir'}/$lonefile, $TmpDir/$lonefile) if $Verbose;
        mv "$Out{'old_dir'}/$lonefile", "$TmpDir/$lonefile" or croak("$!\n");

        # Clean up
        say qq(rmdir $Out{'old_dir'}) if $Verbose;
        chdir $Out{'path'}    or croak("$!\n");
        rmdir $Out{'old_dir'} or croak("$!\n");

        # Put them back again
        say qq(mv $TmpDir/$lonefile $Out{'dir'}) if $Verbose;
        mv "$TmpDir/$lonefile", $Out{'dir'} or croak("$!\n");
        cleanup();

        chdir $Out{'dir'} or analyze_mess() or croak;
        @files = betterglob();
    }

    my $reldir = $Out{'dir'} =~ s|$CWD/(.*)|$1|r;
    say "\033[0m\033[33m" . "Extracted to '$reldir'" . "\033[0m";
    return true;
}

###############################################################################
# Normal extraction

sub extract_tar($CMD, $Flags, $Stdout) {
    if ( $Flags eq 'SPECIAL' ) {
        if    ( $File{'ext'} eq 'tar' )  { extract_double_tar() }
        elsif ( $File{'ext'} eq 'zpaq' ) { extract_zpaq() }
    }
    else {
        print  qq($CMD $Flags "$File{'name'}" | $TAR -xf -);
        system qq($CMD $Flags "$File{'fullpath'}" | $TAR -xf -);
    }
}

sub extract_else($CMD, $Flags, $Stdout) {
    if ( $Flags eq 'SPECIAL' ) { croak }
    else {
        if ($Stdout) {
            print  qq($CMD $Flags "$File{'bname'}" > "$Out{'dir'}");
            system qq($CMD $Flags "$File{'fullpath'}" > "$Out{'dir'}");
        }
        else {
            print  qq($CMD $Flags "$File{'bname'}");
            system qq($CMD $Flags "$File{'fullpath'}");
        }
    }
}

###############################################################################

sub force_extract($archive) {
    print STDERR "Attempting to force extract.\n\n";
    my $index = 1;
    my $color = "\033[01m\033[35m";

    while (true) {
        if ( $index == 0 ) {
            say STDERR $color . "Trying tar" . "\033[0m";
            system qq($TAR -xf "$archive");
            last if ( $? == 0 );
        }
        elsif ( $index == 2 and which('patool') ) {
            say STDERR $color . "Trying patool" . "\033[0m";
            system qq(patool extract "$archive");
            last if ( $? == 0 );
        }
        elsif ( $index == 3 and which('atool') ) {
            say STDERR $color . "Trying patool" . "\033[0m";
            system qq(atool -x "$archive");
            last if ( $? == 0 );
        }
        elsif ( $index == 4 and which('7z') ) {
            say STDERR $color . "Trying 7zip" . "\033[0m";
            system qq(7z $v7z x "$archive");
            last if ( $? == 0 );
        }
        elsif ( $index == 5 and which('zpaq') ) {
            say STDERR $color . "Trying zpaq" . "\033[0m";
            system qq(zpaq x "$archive");
            last if ( $? == 0 );
        }
        elsif ( $index == 6 ) {
            say STDERR "\n\033[1m\033[31mTotal failure. Giving up.\033[0m";
            return false;
        }

        ++$index;
    }

    say STDERR "Success!";
    return true;
}

###############################################################################
# Special cases

sub extract_zpaq {
    my $bak = getcwd;
    my $tmp = get_tempdir();
    chdir $tmp;

    print qq(zpaq x "$File{'fullpath'}" >/dev/null 2>&1\n);
    system qq(zpaq x "$File{'fullpath'}" >/dev/null 2>&1);

    my @files = betterglob();
    print  qq(tar -xf $files[0]);
    system qq(tar -xf $files[0]);
    unlink $files[0];

    mkdir $Out{'dir'};
    @files = betterglob();
    foreach (@files) { mv($_, $Out{'dir'}) }

    chdir $bak;
}

sub extract_double_tar {
    say    qq($TAR -xf '$File{'bname'}' - | $TAR -xf -);
    system qq($TAR -xf "$File{'fullpath'}" - | $TAR -xf -);
}

sub analyze_mess {
    if ( -d $Out{'dir'} ) { croak "$! - No clue what is happening." }

    say STDERR \
        "The output directory is not a directory. It may be another archive.";
    my $tmp = get_tempdir();
    my $bak = getcwd;
    chdir $tmp;

    if ( force_extract( $Out{'dir'} ) ) {
        unlink $Out{'dir'};
        mkdir $Out{'dir'};
        my @files = betterglob();

        foreach ( @files ) {
            mv( $_, $Out{'dir'} );
        }
        
        chdir $bak;
        return true;
    }
    else {
        warn "I have no clue what $Out{'dir'} is.\n";
        chdir $bak;
        return false;
    }
}

###############################################################################

sub determine_decompressor($ext) {
    my ( $CMD, $TFlags, $EFlags, $Stdout );
    $TFlags = $EFlags = '';
    $_ = $ext;

    if ( /^(z|Z)$/n and which('uncompress') ) {
        $CMD    = 'uncompress';
        $TFlags = $EFlags = '-c';
        $Stdout = true;
    }
    elsif ( /^(gz|z|Z)$/n and which('gzip') ) {
        $CMD    = 'gzip';
        $TFlags = $EFlags = '-dc';
        $Stdout = true;
    }
    elsif ( /^(bz|bz2)$/n and which('bzip2') ) {
        $CMD    = 'bzip2';
        $TFlags = $EFlags = '-dc';
        $Stdout = true;
    }
    elsif ( /^(xz|lzma|lz)$/n and which('xz') ) {
        $CMD    = 'xz';
        $TFlags = $EFlags = '-dc';
        $Stdout = true;
    }
    elsif ( /^(lz4)$/n and which('lz4') ) {
        $CMD    = 'lz4';
        $TFlags = $EFlags = '-dc';
        $Stdout = true;
    }
    elsif ( /^(tar|cpio)$/n and which('tar') ) {
        $CMD    = $TAR;
        $TFlags = 'SPECIAL';
        $EFlags = '-xf';
    }
    elsif ( /^(7z|gz|bz|bz2|xz|lzma|lz|lz4|zip|cpio|rar|z|Z|jar|
               deb|rpm|a|ar|iso|img|0{1,2}[1-9])$/nx
            and which('7z') )
    {
        $CMD    = '7z';
        $TFlags = "$v7z -so x";
        $EFlags = "$v7z x";
    }
    elsif ( /^(zpaq)$/n and which('zpaq') ) {
        $CMD    = 'zpaq';
        $TFlags = 'SPECIAL';
        $EFlags = 'x';
    }
    elsif ( /^(zip)$/n and which('unzip') ) {
        $CMD    = 'unzip';
        $TFlags = '-p';
    }
    elsif ( /^(arc)$/n and which('arc') ) {
        $CMD    = 'arc';
        $TFlags = 'p';
        $EFlags = 'x';
    }
    elsif ( /^(ace|winace)$/n and which('unace') ) {
        $CMD    = 'unace';
        $TFlags = $EFlags = 'x';
    }
    elsif ( /^(rar)$/n and which('unrar') ) {
        $CMD    = 'unrar';
        $TFlags = $EFlags = 'x';
    }

    else {
        if ($Force) {
            print STDERR << 'EOF';
ERROR: File format unrecognized or no known extraction utilities are installed.
EOF
        }
        else {
            print STDERR << "EOF";
ERROR: File "$File{'name'}"
       Either the format was unrecognized or no known extraction utilities were
       found. Double check whether the required program is installed and is in
       your \$PATH. If unsure, consider attempting to 'force' extract the
       archive with the '-f' flag. If that fails too then this script
       unfortunately cannot extact your file.
EOF
        }

        return 'FAIL';
    }

    return ( $CMD, $TFlags, $EFlags, $Stdout );
}

###############################################################################
# Setup

my ( $help, $version, $bsdtar, $gtar, $combine );
my $prefer_tar = 'bsdtar';

GetOptions(
    'h|help'    => \$help,
    'V|version' => \$version,
    'v|verbose' => \$Verbose,
    'c|combine' => \$combine,
    'b'         => \$bsdtar,
    'g'         => \$gtar,
    'f|force'   => \$Force,
    'tar=s'     => \$prefer_tar,
    'o|top=s'   => \$odir_given
) or show_usage(1);

if     ($help)    { show_usage(0) }
if     ($version) { say "xtar version 3.0 (perl)" and exit 0 }
unless (@ARGV)    { warn "No input files.\n\n" and show_usage(1) }

if    (defined $prefer_tar) { $TAR = find_tar($prefer_tar) }
elsif ($bsdtar)             { $TAR = find_tar('bsdtar') }
elsif ($gtar)               { $TAR = find_tar('gtar') }
else                        { $TAR = 'tar' }

if ($combine) { die "Combine is not implemented yet." }

$Num   = @ARGV;
$RunNo = 1;

###############################################################################

while (@ARGV) {
    my $filename = shift;
    if ( not -e $filename or -d $filename ) {
        say STDERR \
            "File $filename does not exist or is a directory. Skipping...";
        next;
    }

    if ( $RunNo > 1 ) { print "\n\n"; }
    print "\033[1m\033[33m----- Processing $filename -----\033[0m\n";

    analyze_file($filename);
    get_odir();
    do_extract();

    chdir $CWD;
    ++$RunNo;
}
