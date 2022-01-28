package xtar::main;

use 5.32.0; use warnings; use strict;
use feature 'signatures';
no warnings 'experimental::signatures';
use constant true  => 1;
use constant false => 0;

use Carp;
use Data::Dumper;
use Cwd 'getcwd';
use File::Which;
use File::Spec::Functions qw( rel2abs splitpath );
use Getopt::Long qw(:config gnu_getopt no_ignore_case);

$Carp::Verbose = 1;

use xtar::xtar;
use xtar::Colors;
use xtar::Utils;

###############################################################################
# Main

sub main       :prototype();
sub find_tar   :prototype($);
sub show_usage :prototype(;$);

sub main :prototype() ()
{
    my (%options, $TAR);
    my $default_tar = 'tar';

    GetOptions(
        'h|help'    => \$options{help},
        'version'   => \$options{version},
        'b|bsdtar'  => \$options{bsdtar},
        'C|clobber' => \$options{clobber},
        'c|combine' => \$options{combine},
        'd|debug'   => \$options{Debug},
        'f|force'   => \$options{force},
        'g|gtar'    => \$options{gtar},
        'o|out=s'   => \$options{odir},
        'q|quiet'   => \$options{quiet},
        'Q|shutup'  => \$options{shutup},
        'T|tar=s'   => \$options{tar},
        'v|verbose' => \$options{verbose},
        'O|out-topdir=s' => \$options{out_top},
    ) or show_usage 1;

    show_usage if $options{help};
    say 'xtar version 1.0.1 (perl)' and exit 0 if $options{version};

    unless (@ARGV) {
        print STDERR "Error: No input files.\n\n";
        show_usage 1;
    }

    if    (defined $options{tar}) { $TAR = find_tar($options{tar}) }
    elsif ($options{bsdtar})      { $TAR = find_tar('bsdtar') }
    elsif ($options{gtar})        { $TAR = find_tar('gtar') }
    else                          { $TAR = find_tar($default_tar) }

    if ($options{clobber})    { $options{combine} = true }

    if    ($options{Debug})   { $options{verbose} = true;  $options{quiet} = false; }
    elsif ($options{shutup})  { $options{verbose} = false; $options{quiet} = true; }
    elsif ($options{verbose}) { $options{quiet}   = false }
    elsif ($options{quiet})   { $options{verbose} = false }
    else                      { $options{verbose} = $options{quiet} = false }

###############################################################################

    my $xtar = xtar::xtar->new(
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
        NumArchives => scalar(@ARGV),
    );
    undef %options;

    my $counter = 1;
    my $spacing = ($xtar->Options->{verbose}) ? "\n\n" : "\n";

    # while (@ARGV) {
    #     my $file = shift @ARGV;
    foreach my $file (@ARGV) {
        if    ( $xtar->Options->{shutup} ) {}
        elsif ( $xtar->Options->{quiet} )  { say "Extracting $file" }
        else {
            print $spacing if ( $counter++ > 1 );
            sayC( 'YELLOW', "----- Processing file '$file' -----" );
        }

        $xtar->init_archive($file);
        $xtar->extract();
    }
}

#-----------------------------------------------------------------------------
###############################################################################
#-----------------------------------------------------------------------------

sub find_tar :prototype($) ($binary)
{
    return (which $binary) ? $binary : 'tar';
}

sub show_usage :prototype(;$) ($status=0)
{
    my $THIS = Basename $0;
    if ( $status == 0 ) {
        print "Usage: ${THIS} [options] archive(s)\n\n";
        print << 'EOF';
Extract an archive safely to a unique directory, ensuring no irritating
single sub-directories or lots of loose files are created. See the manual for
more detailed information.

OPTIONS
 -h, --help      Show this usage information.
 --version       Show version.
 -v, --verbose   Verbose mode. Display progress information if possible.
 -d, --debug     Enable very verbose output. Implies -v.
 -q, --quiet     Disable most output.
 -Q, --shutup    Really say nothing unless everything breaks.
 -T, --tar=ARG   Explicity specify the tar binary to use.
 -b, --bsdtar    Use bsdtar over 'tar' if it exists, otherwise fall back to tar.
 -g, --gtar      Use gtar if it exists, otherwise fall back to tar.
 -f, --force     If completely unable to identify a type, try to extract through
                 trial and error using all commands available (safe but slow).
 -o, --out=DIR   Explicitly specify output directory. If it already exists,
                 time_t will be appended to it. When used with multiple
                 archives it will function as a top directory with each archive
                 extracted to sub-directories, unless -c is supplied, whereupon
                 all archives are combined into it.
 -O, --out-topdir
                 Out topdir

 -c, --combine   Combine multiple archives. When -o is not supplied, a directory
                 name is generated from the name of the first supplied archive.
                 *** NOT IMPLEMENTED ***

EOF
    }
    else {
        err("Usage: ${THIS} [options] archive(s)");
    }

    exit $status;
}
