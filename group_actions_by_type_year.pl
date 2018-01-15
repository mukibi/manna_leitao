#!/usr/bin/perl

use strict;
use warnings;

my %events = ();

open (my $f, "<corporate_events.csv");

my %actions = ();
my %yrs = ();

while (<$f>) {

	chomp;
	my @bts = split/,/, $_;

	if ( $bts[3] =~ m![/\-](\d{2,4})$! ) {

		my $yr = $1;
		#convert 2-digit years to 3 digits
		if (length($yr) == 2) {
			$yr = "20$yr";
		}

		$actions{$bts[1]}++;
		$events{$yr}->{$bts[1]}++;
		$yrs{$yr}++;

	}

}

print "Year \t";

for my $action_type ( sort { $a cmp $b } keys %actions ) {
	print $action_type . "\t";
}

print $/;

for my $yr ( sort {$a <=> $b} keys %yrs ) {

	my $yr_total = 0;
	print "$yr \t";

	for my $action_type ( sort {$a cmp $b} keys %actions ) {

		my $len = length($action_type);
		my $num_events = 0;

		$yr_total += $num_events;

		if ( exists $events{$yr}->{$action_type} ) {
			$num_events = $events{$yr}->{$action_type};
		}

		printf "%${len}d \t", $num_events;
	}

	print $/;

}

