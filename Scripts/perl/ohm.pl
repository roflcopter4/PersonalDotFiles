#!/usr/bin/env perl
use 5.26.0; use warnings; use strict;
use feature 'signatures';
no warnings 'experimental::signatures';
use utf8;
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

use Carp qw(confess);
use Math::Trig 'pi2';
use Pod::Usage;
use Getopt::Long qw(:config gnu_getopt ignore_case);

$Carp::Verbose = 1;

our %color = (
    plain    => "\033[0m",
    bold     => "\033[1m",
    red      => "\033[31m",
    green    => "\033[32m",
    yellow   => "\033[33m",
    blue     => "\033[34m",
    magenta  => "\033[35m",
    cyan     => "\033[36m",
    gray     => "\033[37m",
    orange   => "\033[38;5;208m",
);

sub main         :prototype();
sub ohms_law     :prototype(\$\$\$);
sub sanity_check :prototype(\%);
# Read formatted input
sub interpret_current    :prototype($);
sub interpret_voltage    :prototype($);
sub interpret_resistance :prototype($);
sub interpret_power      :prototype($);
sub interpretation_error :prototype($_);
# Format output
sub format_generic    :prototype($$;$);
sub format_current    :prototype($_);
sub format_voltage    :prototype($_);
sub format_resistance :prototype($_);
sub format_power      :prototype($_);
# Misc
sub longest    :prototype(@);
sub perror     :prototype(@);
sub show_usage :prototype(@);

# Unused
#sub interpret_frequency   :prototype($);
#sub interpret_capacitance :prototype($);
#sub get_capacitive_reactance :prototype(\$\$);
#sub format_capacitance :prototype($_);
#sub format_frequency   :prototype($_);

my %opt;
main;
exit 0;

#=========================================================================================
# Main

sub main :prototype()
{
    my %vals;
    my $n = 0;
    
    GetOptions(
        'help|h|?'       => \$opt{help},
        'full-values|f!' => \$opt{full},
        'current|I=s'    => \$vals{I},
        'voltage|V=s'    => \$vals{V},
        'resistance|R=s' => \$vals{R},
        'power|P|W=s'    => \$vals{P},
    ) or show_usage 'Invalid option';
    show_usage if ($opt{help});
    
    my $I = interpret_current $vals{I};
    my $V = interpret_voltage $vals{V};
    my $R = interpret_resistance $vals{R};
    my $P = interpret_power $vals{P};

    if (defined $P) {
        if    (defined $I) { $V = $P / $I }
        elsif (defined $V) { $I = $P / $V }
        elsif (defined $R) { $I = sqrt($P / $R) }
        ohms_law $I, $V, $R;
    }
    else {
        ohms_law $I, $V, $R;
        $P = $I * $V;
    }

    my $mlen = longest $I, $V, $R, $P;
    $_ = $mlen;

    printf(  "Current:     %s\n"
           . "Voltage:     %s\n"
           . "Resistance:  %s\n"
           . "Power:       %s\n",
           format_current($I), format_voltage($V),
           format_resistance($R), format_power($P)
    );
}

#=========================================================================================

sub ohms_law :prototype(\$\$\$) ($I, $V, $R)
{
    if    (not defined $$I) { $$I = $$V / $$R }
    elsif (not defined $$V) { $$V = $$I * $$R }
    elsif (not defined $$R) { $$R = $$V / $$I }
    else {
        perror '"Unreachable" code was somehow reached.';
        confess;
    }
}

sub sanity_check :prototype(\%) ($vals)
{
    my ($n, $mlen) = (0, 0);
    $n += defined($_) foreach (values(%$vals));
    unless ($n == 2) { show_usage 'Exactly 2 values must be specified' }
}

#=========================================================================================
# Interpretation

sub interpretation_error :prototype($_) ($str, $val)
{
        perror "invalid $str value \"$val\"";
        exit 1;
}

sub interpret_current :prototype($) ($val)
{
    return undef unless defined $val;
    my $ret;

    for ($val) {
        if    (/^((?:\d+\.?\d*)|(?:\.\d+))uA?$/) { $ret = $1 / 1000000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))mA?$/) { $ret = $1 / 1000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))kA?$/) { $ret = $1 * 1000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))MA?$/) { $ret = $1 * 1000000}
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))A?$/)  { $ret = $1 }
        else {
            interpretation_error 'current';
        }
    }

    return $ret;
}

sub interpret_voltage :prototype($) ($val)
{
    return undef unless defined $val;
    my $ret;

    for ($val) {
        my $is_rms = 0;
        if (/\s*rms$/i) {
            $val =~ s/\s*rms$//i;
            $is_rms = 1;
        }

        if    (/^((?:\d+\.?\d*)|(?:\.\d+))uV?$/) { $ret = $1 / 1000000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))mV?$/) { $ret = $1 / 1000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))kV?$/) { $ret = $1 * 1000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))MV?$/) { $ret = $1 * 1000000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))V?$/)  { $ret = $1 }
        else {
            interpretation_error 'voltage';
        }

        say STDERR "Is rms, multiplying $ret by sqrt(2) [", sqrt(2), "]" if $is_rms;
        $ret *= sqrt(2) if $is_rms;
    }

    return $ret;
}

sub interpret_resistance :prototype($) ($val)
{
    return undef unless defined $val;
    my $ret = 0;

    for ($val) {
        if    (/^((?:\d+\.?\d*)|(?:\.\d+))M$/)    { $ret = $1 * 1000000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))[kK]$/) { $ret = $1 * 1000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))$/)     { $ret = $1 }
        elsif (/^(\d+)R(\d+)$/)                   { $ret = ($1 * 1000) + ($2 * 100) }
        else {
            interpretation_error 'resistance';
        }
    }

    return $ret;
}

sub interpret_power :prototype($) ($val)
{
    return undef unless defined $val;
    my $ret;

    for ($val) {
        if    (/^((?:\d+\.?\d*)|(?:\.\d+))mW?$/) { $ret = $1 / 1000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))kW?$/) { $ret = $1 * 1000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))MW?$/) { $ret = $1 * 1000000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))GW?$/) { $ret = $1 * 1000000000 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))W?$/)  { $ret = $1 }
        else {
            interpretation_error 'wattage';
        }
    }

    return $ret;
}

#=========================================================================================
# Unused

#sub interpret_frequency :prototype($) ($freq)
#{
#    my $val = 0;
#
#    for ($freq) {
#        if    (/^((?:\d+\.?\d*)|(?:\.\d+))G(?:[hH]z|[cC])?$/) { $val = $1 * 1000000000.0 }
#        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))M(?:[hH]z|[cC])?$/) { $val = $1 * 1000000.0 }
#        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))k(?:[hH]z|[cC])?$/) { $val = $1 * 1000.0 }
#        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))(?:[hH]z|[cC])?$/)  { $val = $1 }
#        else {
#            say STDERR qq{Error: invalid frequency value "$freq"};
#            exit 1;
#        }
#    }
#
#    return $val;
#}
#
#sub interpret_capacitance :prototype($) ($cap)
#{
#    my $val = 0;
#
#    for ($cap) {
#        # The default interpretation for the value is in microfarads.
#        if    (/^((?:\d+\.?\d*)|(?:\.\d+))p[fF]?$/)    { $val = $1 / 1000000000000.0 }
#        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))n[fF]?$/)    { $val = $1 / 1000000000.0 }
#        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))(u[fF]?)?$/) { $val = $1 / 1000000.0 }
#        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))m[fF]?$/)    { $val = $1 / 1000.0 }
#        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))[fF]$/)      { $val = $1 }
#        else {
#            say STDERR qq{Error: invalid capacitance value "$cap"};
#            exit 1;
#        }
#    }
#
#    return $val;
#}
#
#sub get_capacitive_reactance :prototype(\$\$) ($cap, $freq)
#{
#    $$freq = interpret_frequency $$freq;
#    $$cap  = interpret_capacitance $$cap;
#    return 1/($$cap * $$freq * pi2);
#}
#sub format_capacitance :prototype($_) ($val, $mlen) { return format_generic $val, 'F',  $mlen }
#sub format_frequency   :prototype($_) ($val, $mlen) { return format_generic $val, 'Hz', $mlen }

#=========================================================================================
# Formatting

sub format_generic :prototype($$;$) ($val, $c, $mlen = 0)
{
    my    $ret;
    state $single  = 'cyan';
    state $addbold = 0;
    state @e       = (
        $color{$single},
        ($addbold ? $color{bold} : '') . $color{$single},
        $color{plain},
    );

    if    ($opt{full})          { goto full }
    elsif ($val >= 1000000000)  { $ret = sprintf '%*f %sG%s%s%s', $mlen, $val / 1000000000,    $e[0], $e[1], $c, $e[2] }
    elsif ($val >= 1000000)     { $ret = sprintf '%*f %sM%s%s%s', $mlen, $val / 1000000,       $e[0], $e[1], $c, $e[2] }
    elsif ($val >= 1000)        { $ret = sprintf '%*f %sk%s%s%s', $mlen, $val / 1000,          $e[0], $e[1], $c, $e[2] }
    elsif ($val >= 1)    { full:  $ret = sprintf '%*f  %s%s%s',   $mlen, $val,                 $e[1], $c, $e[2] }
    elsif ($val >= 0.01)        { $ret = sprintf '%*f %sm%s%s%s', $mlen, $val * 1000,          $e[0], $e[1], $c, $e[2] }
    elsif ($val >= 0.000001)    { $ret = sprintf '%*f %su%s%s%s', $mlen, $val * 1000000,       $e[0], $e[1], $c, $e[2] }
    elsif ($val >= 0.000000001) { $ret = sprintf '%*f %sn%s%s%s', $mlen, $val * 1000000000,    $e[0], $e[1], $c, $e[2] }
    else                        { $ret = sprintf '%*f %sp%s%s%s', $mlen, $val * 1000000000000, $e[0], $e[1], $c, $e[2] }

    return $ret;
}

sub format_current     :prototype($_) ($val, $mlen) { return format_generic $val, 'A',  $mlen }
sub format_voltage     :prototype($_) ($val, $mlen) { return format_generic $val, 'V',  $mlen }
sub format_resistance  :prototype($_) ($val, $mlen) { return format_generic $val, 'Ω ', $mlen }
sub format_power       :prototype($_) ($val, $mlen) { return format_generic $val, 'W',  $mlen }

#=========================================================================================
# Some lazy util functions

sub longest :prototype(@) (@lst)
{
    my $max = 0;

    foreach my $num (@lst) {
        my $s = format_generic $num, ord 'A', $max;
        $s    =~ m/(\d+\.?\d*).*/;
        $max  = (length($1) > $max) ? length($1) : $max;
    }

    return $max;
}

#=========================================================================================
# Usage and errors

sub perror :prototype(@) (@msg)
{
    say STDERR $color{bold} . $color{red} . 'Error:' . $color{plain} . " @msg";
}

sub show_usage :prototype(@)
{
    my $val = scalar @_;
    if ($val) {
        my ($msg) = @_;
        perror $msg;
    }

    print STDERR << "EOF";
Usage: $0 <options> -[IVRP]

This simple program will calculate Ohm's Law, given two inputs. Many 
abbreviations are accepted (eg. 10k for 10000 Ohms). Specifying the unit is
allowed but not required.
Paramaters may not be positional. Please input values as options. Options are
not case sensitive.

Options:
    h|help|?          Show this help
    f|full-values     Show output in full values (eg. 10000V instead of 10kV)
    I|current=VAL     Specify the current
    V|voltage=VAL     Specify the voltage
    R|resistance=VAL  Specify the resistance
    P|W|power=VAL     Specify the power
EOF

    exit $val;
}
