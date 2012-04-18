#!/usr/bin/env perl
use strict;
use warnings;

my $total = 0; 
my $success = 0;

while (<STDIN>) { 
	chomp;
	my @p = split(/\t/);
	if ( defined($p[1]) && $p[0] =~ /\/\Q$p[1]\E\// ) {
		$success++;
	}

	$total++;

	if ( $total % 1000 == 0 ) {
		print STDERR "$success\t$total\t", $success / $total, "\n";
	}
}

print "$success\t$total\t", $success / $total, "\n";
