#!/usr/bin/perl

use feature 'say';

use Data::Dumper;
use Time::Piece;
use File::Copy;

open my $INV, '<', 'inventory' or die "Can't open inventory file: $!\n";

my %hosts;

while (<$INV>) {
    if (/^(\d+\.\d+\.\d+\.\d+).*/) {
        my $ip = $1;
        if (  /ProxyJump=([^@]+@?\d+\.\d+\.\d+\.\d+)[^0-9]/ ) {
            push @{$hosts{$1}}, $ip;
        }
        else {
            push @{$hosts{_DIRECT}}, $ip;
        }
    }
}
close $INV;

my %hashes = ();
for my $proxy (sort keys %hosts) {
    my @command = ('ssh-keyscan', '-t', 'ssh-rsa');
    my @ips = @{$hosts{$proxy}};
    push @command, @ips;
    if ( $proxy ne '_DIRECT' ) {
        unshift @command, 'ssh', $proxy;
    }
    push @command, '2>/dev/null';
    open my $CMD, '-|', "@command" or die "Can't open";
    while (<$CMD>) {
        next if /^#/;
        chomp;
        my ($host) = /^(\S+)/;
        $hashes{$1} = $_;
    }
}

my $known_hosts_file = "$ENV{HOME}/.ssh/known_hosts";
my $backup = backup_file($known_hosts_file);

open my $KNOWN_HOSTS, '<', $backup or die "Could not open backup known hosts file: $!\n";
open my $NEW_HOSTS, '>', $known_hosts_file or die "Could not open new hosts file: $!\n";

while (<$KNOWN_HOSTS>) {
    my ($ip) = /^(\S+)/;
    if (defined $ip && exists $hashes{$ip}) {
        say $NEW_HOSTS $hashes{$ip};
        delete $hashes{$ip};
    }
    else {
        print $NEW_HOSTS $_;
    }
}

for my $extra (values %hashes) {
    say $NEW_HOSTS $extra;
}

close $NEW_HOSTS;
close $KNOWN_HOSTS;

say "Known hosts file updated.";

sub backup_file {
    my ($file) = @_;
    
    my $now = localtime();
    my $backup_file_name = sprintf("%s.bak-%s", $file, $now->strftime("%Y%m%dT%H%M%S"));
    copy($file, $backup_file_name);
    return $backup_file_name;
}
