#!/usr/bin/env perl
#
# spawns a lifter with a maximum lifetime as per the competition; if
# the lifter emits a route, feed it to the simulator as metadata on
# the map.

use strict;
use IPC::Open2;

my $LIFTER = shift or './lifter';
my $SIMULATOR = './src/simulator';
my $TIME_TO_LIVE = 150;

my $pid = open2(\*LIFTER_OUT, \*LIFTER_IN, $LIFTER) or die $!;
my $route = "";

# snarf the map first since we have to regurgitate it after.
my $map = "";
while(<>) { $map .= $_; }

eval {
    my $gracious = 1;
    local $SIG{ALRM} = sub {
        if($gracious) {
            kill 'INT', $pid;
            $gracious = 0;
            alarm 10;
        } else {
            kill 'KILL', $pid;
            alarm 0;
            die "Exceeded total life expectancy.\n";
        }
    };
    alarm($TIME_TO_LIVE);

    print LIFTER_IN $map;
    close(LIFTER_IN);
    while(<LIFTER_OUT>) { $route .= $_; }
    waitpid $pid, 0;
    alarm 0;
};
die $@ if($@);

# let the simulator spew its output to STDOUT
$pid = open2(\*STDOUT, \*SIM_IN, $SIMULATOR) or die $!
print SIM_IN $map;
print SIM_IN "\nRoute: ".$route."\n";
close SIM_IN;
waitpid $pid, 0;

exit 0;
