#!/usr/bin/env perl
use warnings; use strict; use v5.24;
use feature 'signatures';
no warnings 'experimental::signatures';
use constant true  => 1;
use constant false => 0;

use Carp;
use Cwd 'getcwd';
use File::Which;
use File::Spec::Functions qw( rel2abs splitpath );
use Getopt::Long qw(:config gnu_getopt no_ignore_case);
use Try::Tiny;

BEGIN {
    my $lib_location = rel2abs((splitpath(readlink(rel2abs("$0"))))[1]);
    eval 'use lib $lib_location;';
    try {
        require xtar;
        require xtar::Colors;
        require xtar::Utils;
        xtar->import();
        xtar::Colors->import();
        xtar::Utils->import();
    }
}

###############################################################################
# Main

my ( %options, $TAR );

my $default_tar = 'tar';

GetOptions(
    'h|help'      => \$options{help},
    'V|version'   => \$options{version},
    'v|verbose'   => \$options{verbose},
    'c|combine'   => \$options{combine},
    'C|clobber'   => \$options{clobber},
    'b|bsdtar'    => \$options{bsdtar},
    'g|gtar'      => \$options{gtar},
    'T|tar=s'     => \$options{tar},
    'o|outname=s' => \$options{odir},
    'O|outdir=s'  => \$options{out_top},
    'f|force'     => \$options{force},
    'd|debug'     => \$options{Debug},
    'q|quiet'     => \$options{quiet},
    'Q|shutup'    => \$options{shutup}
) or show_usage(1);

if ( $options{help} )    { show_usage(0) }
if ( $options{version} ) { say 'xtar version 4.0.0 (perl)' and exit 0 }

unless (@ARGV) {
    print STDERR "Error: No input files.\n\n";
    show_usage(1);
}

if    ( defined $options{tar} ) { $TAR = find_tar( $options{tar} ) }
elsif ( $options{bsdtar} )      { $TAR = find_tar('bsdtar') }
elsif ( $options{gtar} )        { $TAR = find_tar('gtar') }
else                            { $TAR = find_tar( $default_tar ) }

if ( $options{clobber} )    { $options{combine} = true }

if    ( $options{Debug} )   { $options{verbose} = true;  $options{quiet} = false; }
elsif ( $options{shutup} )  { $options{verbose} = false; $options{quiet} = true; }
elsif ( $options{verbose} ) { $options{quiet}   = false }
elsif ( $options{quiet} )   { $options{verbose} = false }
else                        { $options{verbose} = $options{quiet} = false }

sub find_tar($binary) {
    return (which $binary) ? $binary : 'tar';
    # if   ( which($binary) ) { return $binary }
    # else                    { return 'tar' }
}


###############################################################################


my $xtar = xtar->new(
    Options => {
        TAR     => $TAR,
        odir    => $options{odir},
        out_top => $options{out_top},
        verbose => $options{verbose},
        combine => $options{combine},
        clobber => $options{clobber},
        force   => $options{force},
        Debug   => $options{Debug},
        quiet   => $options{quiet},
        shutup  => $options{shutup}
    },
    CWD         => rel2abs(getcwd()),
    NumArchives => scalar(@ARGV)
);
undef %options;

$xtar->init_outpath();

my $counter = 1;
my $spacing = ($xtar->Options->{verbose}) ? "\n\n" : "\n";

while (@ARGV) {
    my $file = shift;

    if    ( $xtar->Options->{shutup} ) {}
    elsif ( $xtar->Options->{quiet} )  { say "Extracting $file" }
    else {
        print $spacing if ( $counter++ > 1 );
        sayC( 'YELLOW', "----- Processing file '$file' -----" );
    }

    $xtar->init_archive($file);
    $xtar->extract();
}


#-----------------------------------------------------------------------------
###############################################################################
#-----------------------------------------------------------------------------


sub show_usage($status) {
    my $THIS = Basename $0;
    if ( $status == 0 ) {
        print "Usage: ${THIS} [options] archive(s)\n\n";
        print << 'EOF';
Extract an archive safely to a unique directory, ensuring no irritating
single sub-directories or lots of loose files are created. See the manual for
more detailed information.

OPTIONS
 -h --help      Show this usage information.
 -V --version   Show version.
 -v --verbose   Verbose mode. Display progress information if possible.
 -d --debug     Enable very verbose output. Implies -v.
 -q --quiet     Disable most output.
 -Q --shutup    Really say nothing unless everything breaks.
 -o --out [DIR] Explicitly specify output directory. If it already exists,
                time_t will be appended to it. When used with multiple
                archives it will function as a top directory with each archive
                extracted to sub-directories, unless -c is supplied, whereupon
                all archives are combined into it.
 -c --combine   Combine multiple archives. When -o is not supplied, a directory
                name is generated from the name of the first supplied archive.
                *** NOT IMPLEMENTED ***
 -T --tar [ARG] Explicity specify the tar binary to use.
 -b --bsdtar    Use bsdtar over 'tar' if it exists, otherwise fall back to tar.
 -g --gtar      Use gtar if it exists, otherwise fall back to tar.
 -f --force     If completely unable to identify a type, try to extract through
                trial and error using all commands available (safe but slow).
EOF
    }
    else {
        err("Usage: ${THIS} [options] archive(s)");
    }

    exit $status;
}
