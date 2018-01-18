#!/usr/bin/perl

use strict;
use warnings;

use Time::Local;
use POSIX qw/strftime/;

my @files = <files/files/*.csv>;

my %observed_values = ();
my %expected_values = ();

my %temp = ();
my $current_week = "";

for my $file (sort { $a cmp $b } @files) {

	if ($file =~ /\/(\d{4})-(\d{2})-(\d{2})\.csv$/) {

		my ($yr, $month, $day) = ($1, $2, $3);
		#next unless ($yr eq "2007");

		my $time = timelocal(0, 0, 0, $day, $month - 1, $yr);

		my @day_details = localtime($time);

		my $week = strftime("%V", @day_details);
		my $wk_day = $day_details[6];

		my $yr_week = "$yr-$week";

		if ($yr_week ne $current_week) {

			#find full days
			for my $stock (keys %temp) {

				my $num_days = scalar (keys %{$temp{$stock}});
				#only accept stocks with atleast 4 trading days
				#and a trade on Monday
				if ( $num_days >= 4 and exists $temp{$stock}->{"1"} ) {
					#print "Adding $yr_week\n";
					$expected_values{$yr}++;

					my $position = 1;

					for my $day ( sort { $temp{$stock}->{$b} <=> $temp{$stock}->{$a} } keys %{$temp{$stock}} ) {

						#note the position of day 1 (Monday)
						if ( $day eq "1" ) {
							$observed_values{$yr}->{$position}++;
							last;
						}

						$position++;

					}

				}

			}

			%temp = ();
			$current_week = $yr_week;

		}

		open (my $f, "<$file");

		while ( <$f> ) {

			chomp;
			my @bts = split/,/, $_;

			unless ( $bts[5] eq "-" or $bts[3] eq "-" ) {
				$temp{$bts[0]}->{$wk_day} = $bts[3];
			}

		}

		close($f);

	}

}

open (my $data_f, ">monday_observed_expected.csv");

for my $yr ( sort { $a <=> $b } keys %observed_values) {

	my $expected_value = $expected_values{$yr} / 5;
	my @positions = ();

	foreach (1..5) {
		my $occ = 0;
		if (exists $observed_values{$yr}->{$_}) {
			$occ = $observed_values{$yr}->{$_};
		}

		push @positions, $occ;
	}

	my $positions = join(",", @positions);

	print  $data_f "$yr,$expected_value,$positions\n";

}

close($data_f);

