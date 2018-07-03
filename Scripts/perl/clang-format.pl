#!/usr/bin/perl
use warnings;
use strict;
use v5.22;
use constant none    => 0;
use constant correct => 1;
use constant other   => 2;
use Carp;
use File::Which;
use Getopt::Long
    qw(:config gnu_compat bundling no_ignore_case require_order pass_through);

###############################################################################

sub slurp_file
{
    my ( $data, $filename, $style ) = ( shift, shift, shift ) or croak;

    open( 'fp', '<', $filename ) or croak "$!";

    my $found_style = none;
    my $sublist     = 0;
    my @skip        = ( qr/(?:^\n)/, qr/^#/ );

    while (<fp>)
    {
        my $line = $_;

        if ( $style ) {
            if ( $found_style == correct ) {
                next unless ( $found_style = $line !~ /^# ##END##/ );
                $line =~ s/^#?(.*)/$1/;
            }
            elsif ( $found_style == other ) {
                if ( /^# ##END##/ ) { $found_style = none }
                next;
            }
            else {
                if ( /# ##(\w+)##/i ) {
                    if    ( $1 eq $style ) { $found_style = correct }
                    elsif ( $1 eq 'END' )  { croak "Shouldn't be possible..." }
                    else                   { $found_style = other }
                }

                next if ( not $sublist and map { $line =~ $_ } @skip );
            }
        }
        else {
            next if ( not $sublist and map { $line =~ $_ } @skip );
        }

        chomp $line;

        if ( $sublist ) {
            # Two '##' on a line marks the end of a sublist block. However, the
            # above code will remove one if the sublist is in a custom block.
            if ( $line =~ /^#{1,2}$/ ) {
                $sublist = 0;
                ${$data} =~ s/(.*),\s*$/$1}, /;
                next;
            }
        }
        elsif ( $line =~ /^  \w/ ) {
            $sublist = 1;
            ${$data} =~ s/(.*),\s*$/$1 {/;
        }

        $line =~ s/^  //;
        $line =~ s/:\s+/: /;

        ${$data} .= $line . ', ';
    }

    close 'fp' or croak "$!";
}

###############################################################################

my $file = $ENV{HOME} . '/.clang-format';
my %opt;

GetOptions(
    'D|debug|dump'       => \$opt{dump},
    'f|file=s'           => \$opt{file},
    'l|w|len|width=i'    => \$opt{length},
    't|tabs'             => \$opt{usetabs},
    'T|notabs'           => \$opt{notabs},
    'i|s|indent|shift=i' => \$opt{indent},
    'S|style=s'          => \$opt{style},
) or die;

my $data = '{';

# This routine does most of the work, including checking for styles
slurp_file( \$data, $file, $opt{style} );

# Add a terminating '}' in place of the trailing comma
$data =~ s/(.*),\s*$/$1}/;

###############################################################################
# Deal with the rest of the options. If the setting already appeared in the
# file, replace its value with the one specified. Otherwise the option is added
# to the end of the list.

# Handle max line length
if ( $opt{length} ) {
    if ( $data =~ m/ColumnLimit/ ) {
        $data =~ s/ColumnLimit: \d*/ColumnLimit: $opt{length}/;
    }
    else {
        $data =~ s/}$/, ColumnLimit: $opt{length}}/;
    }
}

# Handle the use of literal tab characters
if ( $opt{usetabs} or $opt{notabs} ) {
    my $val;
    if    ( $opt{usetabs} ) { $val = 'Always' }
    elsif ( $opt{notabs} )  { $val = 'Never' }

    if ( $data =~ m/UseTab/ ) {
        $data =~ s/UseTab: \w*/UseTab: $val/;
    }
    else {
        $data =~ s/}$/, UseTab: $val}/;
    }
}

# Handle the number of spaces used for indentation
if ( defined $opt{indent} ) {
    if ( $data =~ m/IndentWidth/ ) {
        $data =~ s/IndentWidth: \d*/IndentWidth: $opt{indent}/;
    }
    else {
        $data =~ s/}$/, IndentWidth: $opt{indent}}/;
    }
}

my @clformat = which('clang-format');
my $prog = ( $0 =~ /clang-format/ ? $clformat[1] : $clformat[0] );

if ( $opt{dump} ) {
    say qq/exec( $prog, "-style=$data", @ARGV )\n/;
    exec( $prog, "-style=$data", '--dump-config' ) or croak "$!";
}
else {
    exec( $prog, "-style=$data", @ARGV ) or croak "$!";
}
