#!/usr/bin/env perl

use strict;
use warnings;

use feature 'say';

open my $HOSTS, '<', 'hosts' or die;

my %ips = ();
while (<$HOSTS>) {
    my ($ip, $name) = split;
    $name =~ s/-/_/g;
    $ips{ "${name}_ip" } = $ip;
}

open my $GV, '<', 'group_vars/_all' or die;
my @contents;
while (<$GV>) {
    chomp;
    my ($var, $setting) = /^(\S+):\s*(\S.*?)\s*$/;
    if ( $ips{$var} ) {
        push @contents, "$var: $ips{$var}";
    }
    else {
        push @contents, $_;
    }
}
close $GV;

open $GV, '>', 'group_vars/all' or die;
say $GV $_ for @contents;
close $GV;

#controller_01_ip: 10.0.0.5
