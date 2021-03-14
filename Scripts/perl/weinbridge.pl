#!/usr/bin/env perl
use 5.26.0; use warnings; use strict;
use feature 'signatures';
no warnings 'experimental::signatures';
use utf8;
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

use Carp;
use Math::Trig 'pi2';
use Getopt::Long qw(:config gnu_getopt ignore_case);

use constant {
    nCYAN   => "\033[0;36m",
    nYELLOW => "\033[0;33m",
    bYELLOW => "\033[1;33m",
    bRED    => "\033[1;31m",
    NOCOLOR => "\033[0m",
};

sub main                  :prototype();
sub do_calculation        :prototype($$);
sub calculate_frequency   :prototype($$);
sub calculate_resistance  :prototype($$);
sub calculate_capacitance :prototype($$);
sub interpret_capacitance :prototype($);
sub interpret_resistance  :prototype($);
sub interpret_frequency   :prototype($);
sub format_resistance     :prototype($);
sub format_capacitance    :prototype($);
sub format_frequency      :prototype($);
sub show_usage            :prototype(@);

main;
exit 0;

#=========================================================================================

sub main :prototype()
{
    my %opt;
    GetOptions(
        'h|H|?|help'        => \$opt{help},
        'f|F|frequency=s'   => \$opt{freq},
        'c|C|capacitance=s' => \$opt{cap},
        'r|R|resistance=s'  => \$opt{res},
    ) or show_usage 'Invalid option';

    show_usage if ($opt{help});

    if ($opt{freq}) {
        if ($opt{cap} and $opt{res}) {
            show_usage 'Nothing to calculate';
        }
        elsif ($opt{cap}) { calculate_resistance $opt{freq}, $opt{cap} }
        elsif ($opt{res}) { calculate_capacitance $opt{freq}, $opt{res} }
        else              { show_usage 'Missing input value(s).' }
    } else {
        if (@ARGV > 2) { show_usage 'Too many positional input paramaters.' }
        if (@ARGV)     { $opt{res} = shift @ARGV }
        if (@ARGV)     { $opt{cap} = shift @ARGV }
        if (not defined $opt{cap} or not defined $opt{res}) {
            show_usage 'Missing input value(s).';
        }
        calculate_frequency $opt{res}, $opt{cap};
    }
}

#=========================================================================================

sub do_calculation :prototype($$) ($a, $b)
{
    return (1.0 / (pi2 * $a * $b));
}

sub calculate_frequency :prototype($$) ($res, $cap)
{
    $res = interpret_resistance  $res;
    $cap = interpret_capacitance $cap;
    printf(  'Formula:     ' . nCYAN    . 'F = 1/(2πRC)' . NOCOLOR . "\n"
           . 'Resistance:  ' . nYELLOW  . '%s'           . NOCOLOR . "\n"
           . 'Capacitance: ' . nYELLOW  . '%s'           . NOCOLOR . "\n"
           . 'Frequency:   ' . bYELLOW  . '%s'           . NOCOLOR . "\n",
           format_resistance $res, format_capacitance $cap,
           format_frequency do_calculation($res, $cap) 
    );
}

sub calculate_resistance :prototype($$) ($freq, $cap)
{
    $freq = interpret_frequency   $freq;
    $cap  = interpret_capacitance $cap;

    printf(  'Formula:     ' . nCYAN    . 'R = 1/(2πFC)' . NOCOLOR . "\n"
           . 'Frequency:   ' . nYELLOW  . '%s'           . NOCOLOR . "\n"
           . 'Capacitance: ' . nYELLOW  . '%s'           . NOCOLOR . "\n"
           . 'Resistance:  ' . bYELLOW  . '%s'           . NOCOLOR . "\n",
           format_frequency $freq, format_capacitance $cap,
           format_resistance do_calculation($freq, $cap) 
    );
}

sub calculate_capacitance :prototype($$) ($freq, $res)
{
    $freq = interpret_frequency  $freq;
    $res  = interpret_resistance $res;

    printf(  'Formula:     ' . nCYAN    . 'C = 1/(2πRF)' . NOCOLOR . "\n"
           . 'Frequency:   ' . nYELLOW  . '%s'           . NOCOLOR . "\n"
           . 'Resistance:  ' . nYELLOW  . '%s'           . NOCOLOR . "\n"
           . 'Capacitance: ' . bYELLOW  . '%s'           . NOCOLOR . "\n",
           format_frequency $freq, format_resistance $res,
           format_capacitance do_calculation($freq, $res) 
    );
}

#=========================================================================================

sub interpret_capacitance :prototype($) ($cap)
{
    my $val = 0;

    for ($cap) {
        # The default interpretation for the value is in microfarads.
        if    (/^((?:\d+\.?\d*)|(?:\.\d+))p[fF]?$/)      { $val = $1 / 1000000000000.0 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))n[fF]?$/)      { $val = $1 / 1000000000.0 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))(?:u[fF]?)?$/) { $val = $1 / 1000000.0 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))m[fF]?$/)      { $val = $1 / 1000.0 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))[fF]$/)        { $val = $1 }
        else {
            say STDERR qq{Error: invalid capacitance value "$cap"};
            exit 1;
        }
    }

    return $val;
}

sub interpret_resistance :prototype($) ($res)
{
    my $val = 0;

    for ($res) {
        if    (/^((?:\d+\.?\d*)|(?:\.\d+))M$/)    { $val = $1 * 1000000.0 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))[kK]$/) { $val = $1 * 1000.0 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))$/)     { $val = $1 }
        elsif (/^(\d+)R(\d+)$/)                   { $val = ($1 * 1000.0) + ($2 * 100.0) }
        else {
            say STDERR qq{Error: invalid resistance value "$res"};
            exit 1;
        }
    }

    return $val;
}

sub interpret_frequency :prototype($) ($freq)
{
    my $val = 0;

    for ($freq) {
        if    (/^((?:\d+\.?\d*)|(?:\.\d+))G(?:[hH]z|[cC])?$/) { $val = $1 * 1000000000.0 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))M(?:[hH]z|[cC])?$/) { $val = $1 * 1000000.0 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))k(?:[hH]z|[cC])?$/) { $val = $1 * 1000.0 }
        elsif (/^((?:\d+\.?\d*)|(?:\.\d+))(?:[hH]z|[cC])?$/)  { $val = $1 }
        else {
            say STDERR qq{Error: invalid frequency value "$freq"};
            exit 1;
        }
    }

    return $val;
}

#=========================================================================================

sub format_resistance :prototype($) ($val)
{
    my $ret;

    if    ($val > 1000000000) { $ret = sprintf '%f GΩ ', $val / 1000000000.0 }
    elsif ($val > 1000000)    { $ret = sprintf '%f MΩ ', $val / 1000000.0 }
    elsif ($val > 1000)       { $ret = sprintf '%f kΩ ', $val / 1000.0 }
    else                      { $ret = sprintf '%f Ω ',  $val }

    return $ret;
}

sub format_capacitance :prototype($) ($val)
{
    my $ret;

    # if    ($val < 0.000000001) { $ret = sprintf '%f pF', $val * 1000000000000.0 }
    # elsif ($val < 0.01)        { $ret = sprintf '%f uF', $val * 1000000.0 }
    # else                       { $ret = sprintf '%f F',  $val }

    if    ($val < 0.000000001) { $ret = sprintf '%f pF', $val * 1000000000000.0 }
    elsif ($val < 0.000001)    { $ret = sprintf '%f nF', $val * 1000000000.0 }
    elsif ($val < 0.01)        { $ret = sprintf '%f uF', $val * 1000000.0 }
    else                       { $ret = sprintf '%f F',  $val }

    # if    ($val < 0.000000001) { $ret = sprintf '%f pF', $val * 1000000000000.0 }
    # elsif ($val < 0.000001)    { $ret = sprintf '%f nF', $val * 1000000000.0 }
    # elsif ($val < 0.001)       { $ret = sprintf '%f uF', $val * 1000000.0 }
    # elsif ($val < 1.0)         { $ret = sprintf '%f mF', $val * 1000.0 }
    # else                       { $ret = sprintf '%f F',  $val }

    return $ret;
}

sub format_frequency :prototype($) ($val)
{
    my $ret;

    if    ($val > 1000000000) { $ret = sprintf '%f GHz', $val / 1000000000.0 }
    elsif ($val > 1000000)    { $ret = sprintf '%f MHz', $val / 1000000.0 }
    elsif ($val > 1000)       { $ret = sprintf '%f kHz', $val / 1000.0 }
    else                      { $ret = sprintf '%f Hz',  $val }

    return $ret;
}

#=========================================================================================

sub show_usage : prototype(@)
{
    my $val = scalar @_;
    if ($val) {
        my ($msg) = @_;
        say STDERR bRED . "Error:" . NOCOLOR . " $msg";
    }

    print STDERR <<"EOF";
Usage: $0 {resistance} {capacitance}
Or:    $0 -r {resistance} -c {capacitance}
Or:    $0 -f {frequency} -r {resistance}
Or:    $0 -f {frequency} -c {capacitance}

This script calculates the formula `1/(2πRC)', where R is a resistance value in
Ohms and C is a capacitance value in Farads. The result is given in Hertz. If
frequency is specified and either resistance or capacitance is specified, the
unspecified value is calculated instead. The value for capacitance and
resistance may be given either by the positional form or the explicit option
form above, and the following abbreviations are accepted:

Resistance:
  [Value]
  [Value] k|K         = Value * 1000
  [Value] M           = Value * 1000000
  [Value1] R [Value2] = Value1*1000 + Value2*100 (eg. 3R3 is 3300Ω)
Capacitance:
  [Value]
  [Value]{scale}
      Where scale is one of 'pF', 'nF', 'uF', or 'mF' (the 'F' is optional).
      If no scale is specified the value is taken to be in microfarads (uF).
Frequency:
  [Value] Hz
  [Value] kHz|kc
  [Value] MHz|Mc
  [Value] GHz|Gc
      The 'Hz' or 'c' is optional.

In all cases a decimal place is optional, and a value with no leading '0' is
also accepted (for example '.01uF').
EOF

    exit $val;
}
