#!/usr/bin/perl

use strict;
use warnings;

use Time::Local;
use POSIX qw/strftime/;

my @files = <files/files/*.csv>;

my %per_year_avgs = ();
#my %all_years_avgs = ();

my %month_prices = ();
my %month_avgs  = ();

my $current_month = "";


for my $file (sort { $a cmp $b } @files) {

	if ($file =~ /\/(\d{4})-(\d{2})-(\d{2})\.csv$/) {

		my ($yr, $month, $day) = ($1, $2, $3);
		#next unless ($yr eq "2007");

		my $yr_month = "$yr-$month";

		if ($yr_month ne $current_month) {

			for my $stock ( keys %month_prices ) {

				for my $day ( keys %{$month_prices{$stock}} ) {
					
					my $day_price = $month_prices{$stock}->{$day};
					my $month_avg  = $month_avgs{$stock}->{"avg"};

					my $delta = ((($day_price - $month_avg) / $day_price) * 100);

					#print "$yr || $day || $delta\n";

					if ( not exists $per_year_avgs{$yr}->{$day} ) {
						$per_year_avgs{$yr}->{$day} = {"avg" => $delta, "count" => 1};
					}

					else {
						$per_year_avgs{$yr}->{$day}->{"count"}++;
						$per_year_avgs{$yr}->{$day}->{"avg"} += (($delta - $per_year_avgs{$yr}->{$day}->{"avg"}) / $per_year_avgs{$yr}->{$day}->{"count"});
						#print qq!$yr || $day || $per_year_avgs{$yr}->{$day}->{"avg"}\n!;
					}

					if ( not exists $per_year_avgs{"all"} ) {
						$per_year_avgs{"all"}->{$day} = {"avg" => $delta, "count" => 1};
					}
					else {
						$per_year_avgs{"all"}->{$day}->{"count"}++;
						#print qq!$delta || $per_year_avgs{"all"}->{$day}->{"avg"} || $per_year_avgs{"all"}->{$day}->{"count"}\n!;
						$per_year_avgs{"all"}->{$day}->{"avg"} += (($delta - $per_year_avgs{"all"}->{$day}->{"avg"}) / $per_year_avgs{"all"}->{$day}->{"count"});
						#print qq!$yr || $day || $per_year_avgs{"all"}->{$day}->{"avg"}\n!;
					}	
				}
			}

			%month_prices = ();
			%month_avgs   = ();

			$current_month = $yr_month;

		}

		open (my $f, "<$file");

		while ( <$f> ) {

			chomp;
			my @bts = split/,/, $_;

			unless ( $bts[5] eq "-" or $bts[3] eq "-" or  $bts[5] eq "0" or $bts[3] eq "0") {

				$month_prices{$bts[0]}->{$day} = $bts[3];

				if ( not exists $month_avgs{$bts[0]} ) {
					$month_avgs{$bts[0]} = {"avg" => $bts[3], "count" => 1 };
				}

				else {
					$month_avgs{$bts[0]}->{"count"}++;
					$month_avgs{$bts[0]}->{"avg"} +=  ($bts[3] - $month_avgs{$bts[0]}->{"avg"}) / $month_avgs{$bts[0]}->{"count"};
				}

			}

		}

		close($f);


	}
}

open (my $f, ">monthday_margins.csv");

print "Year\t";
foreach (1..31) {
	printf "%4d\t", $_; 
}
print $/;

for my $yr ( sort { return 1 if ($a eq "all"); return -1 if ($b eq "all"); $a <=> $b } keys %per_year_avgs ) {

	print "$yr\t";
	print $f "$yr,";

	my @day_margins = ();
	my @day_margins_formatted = ();

	for my $day (sort {$a <=> $b } keys %{$per_year_avgs{$yr}}) {

		my $avg = $per_year_avgs{$yr}->{$day}->{"avg"};
		push @day_margins_formatted, sprintf("%0.4f", $avg);
		push @day_margins, $avg;

	}

	print join("\t", @day_margins_formatted), $/;
	print $f join(",", @day_margins), $/;
}

close($f);
