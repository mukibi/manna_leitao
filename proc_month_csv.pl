#!/usr/bin/perl

use strict;
use warnings;

open (my $f, "<month_margins.csv");

my %data = ();

while (<$f>) {

	chomp;
	if ($_ =~ /^Year,/) {

		my @bts = split/,/,$_;
		for (my $i = 1; $i <= $#bts; $i++ ) {
			$data{$bts[$i]} = {"low" => 0, "high" => 0, "avg" => 0, "open" => 0, "close" => 0};
		}

	}

	if ($_ =~ /Best Delta,/) {

		my @bts = split/,/,$_;
		for (my $i = 1; $i <= $#bts; $i++ ) {
			if (exists $data{$i}) {
				$data{$i}->{"high"}  = $bts[$i];
			}
		}

	}

	if ($_ =~ /Worst Delta,/) {

		my @bts = split/,/,$_;
		for (my $i = 1; $i <= $#bts; $i++ ) {
			if (exists $data{$i}) {
				$data{$i}->{"low"}  = $bts[$i];
			}
		}

	}

	if ($_ =~ /all,/) {

		my @bts = split/,/,$_;
		for (my $i = 1; $i <= $#bts; $i++ ) {
			if (exists $data{$i}) {
				$data{$i}->{"avg"}  = $bts[$i];
			}
		}

	}

	if ($_ =~ /Std Dev,/) {

		my @bts = split/,/,$_;
		for (my $i = 1; $i <= $#bts; $i++ ) {
			if (exists $data{$i}) {
				$data{$i}->{"open"}  = $data{$i}->{"avg"} - $bts[$i];
				$data{$i}->{"close"} = $data{$i}->{"avg"} + $bts[$i];
			}
		}

	}

	#print $_, $/;

}

for my $day ( sort { $a <=> $b } keys %data ) {
	print qq!$day,$data{$day}->{"open"},$data{$day}->{"low"},$data{$day}->{"high"},$data{$day}->{"close"}\n!;
}

#print join(", ", keys %data), $/;

