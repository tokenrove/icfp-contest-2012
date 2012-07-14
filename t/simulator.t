#!/usr/bin/env perl

use strict;
use Test;

my $SIMULATOR = './src/simulator.ijs';

my @ins = glob("t/*.in");
plan tests => (1+$#ins);

for(@ins) {
    my $in = $_;
    my $out = s/\.in/\.out/r;
    ok(0 == system("$SIMULATOR < $in | diff -qb - $out"));
}



