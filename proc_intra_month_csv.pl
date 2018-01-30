#!/usr/bin/perl

use strict;
use warnings;

open (my $f, "</home/k0k1/Documents/Intra_month_returns.csv");

my %data = ();

while (<$f>) {

	chomp;
	if ($_ =~ /^Year,/) {

		my @bts = split/,/,$_;
		for (my $i = 1; $i <= $#bts; $i++ ) {
			$data{$bts[$i]} = {"low" => 0, "high" => 0, "close" => 0};
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
				$data{$i}->{"close"}  = $bts[$i];
			}
		}

	}
	#print $_, $/;

}

for my $day ( sort { $a <=> $b } keys %data ) {
	print qq!$day,$data{$day}->{"low"},$data{$day}->{"low"},$data{$day}->{"high"},$data{$day}->{"close"}\n!;
}

#print join(", ", keys %data), $/;

