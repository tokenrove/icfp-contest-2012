#!/usr/bin/env perl
# For testing that harness actually does what it says on the label.

use strict;

local $SIG{INT} = sub {
    print STDERR "Got SIGINT!\n";
    print "A";
    exit(0);
};
sleep(1000);

