#!/usr/bin/env perl
use 5.28.0; use warnings; use strict;
use feature 'signatures';
no warnings 'experimental::signatures';
use constant true  => 1;
use constant false => 0;

use Carp;
use Cwd 'getcwd';
use File::Which;
use File::Spec::Functions qw( rel2abs splitpath );
use Getopt::Long qw(:config gnu_getopt no_ignore_case);

# BEGIN {
#     # my $lib_location = ( splitpath(readlink rel2abs("$0")) )[1];
#     # if (-e $lib_location) {
#     #     $lib_location =~ s|/$||;
#     # } else {
#     $lib_location = rel2abs('.');
#     # }
#     eval 'use lib "$lib_location";';
#     # my $lib_location = (splitpath(rel2abs("$0")))[1];
#     # { local $/ = '/'; chomp $lib_location; }
#     # say "lib_location == '$lib_location'";
# 
#     # eval 'use lib "$lib_location"'; 
#     # eval 'use xtar;';
#     # eval 'use xtar::Colors;';
#     # eval 'use xtar::Utils;';
# 
#     # eval 'use lib "$ENV{HOME}/personaldotfiles/Scripts/perl/xtar";';
#     # eval 'use xtar;';
#     # eval 'use xtar::Colors;';
#     # eval 'use xtar::Utils;';
# }

use lib "/home/bml/personaldotfiles/Scripts/perl/xtar";
use xtar;
use xtar::Colors;
use xtar::Utils;

###############################################################################
# Main

sub find_tar   :prototype($);
sub show_usage :prototype(;$);

my (%options, $TAR);
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
) or show_usage 1;

show_usage if $options{help};
say STDERR 'xtar version 4.1.0 (perl)' and exit 0 if $options{version};

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
    NumArchives => scalar(@ARGV),
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

sub find_tar :prototype($) ($binary)
{
    return (which $binary) ? $binary : 'tar';
}

sub show_usage :prototype(;$) ($status=0)
{
    my $THIS = Basename $0;
    if ( $status == 0 ) {
        print STDERR "Usage: ${THIS} [options] archive(s)\n\n";
        print STDERR << 'EOF';
Extract an archive safely to a unique directory, ensuring no irritating
single sub-directories or lots of loose files are created. See the manual for
more detailed information.

OPTIONS
 -h, --help      Show this usage information.
 -V, --version   Show version.
 -v, --verbose   Verbose mode. Display progress information if possible.
 -d, --debug     Enable very verbose output. Implies -v.
 -q, --quiet     Disable most output.
 -Q, --shutup    Really say nothing unless everything breaks.
 -o, --out=DIR   Explicitly specify output directory. If it already exists,
                 time_t will be appended to it. When used with multiple
                 archives it will function as a top directory with each archive
                 extracted to sub-directories, unless -c is supplied, whereupon
                 all archives are combined into it.
 -T, --tar=ARG   Explicity specify the tar binary to use.
 -b, --bsdtar    Use bsdtar over 'tar' if it exists, otherwise fall back to tar.
 -g, --gtar      Use gtar if it exists, otherwise fall back to tar.
 -f, --force     If completely unable to identify a type, try to extract through
                 trial and error using all commands available (safe but slow).

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
