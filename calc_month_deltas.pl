#!/usr/bin/perl

use strict;
use warnings;

use Time::Local;
use POSIX qw/strftime/;

my @files = <files/files/*.csv>;

my %per_year_avgs = ();
#my %all_years_avgs = ();

#my %month_prices = ();
my %month_avgs  = ();

my %yr_avgs = ();

my $current_yr = "";

for my $file (sort { $a cmp $b } @files) {

	if ($file =~ /\/(\d{4})-(\d{2})-(\d{2})\.csv$/) {

		my ($yr, $month, $day) = ($1, $2, $3);
		#next unless ($yr eq "2007;


		if ( $yr ne $current_yr ) {

			#print "$yr\n";

			for my $stock ( keys %month_avgs ) {

				for my $month ( keys %{$month_avgs{$stock}} ) {
					
					my $month_price = $month_avgs{$stock}->{$month}->{"avg"};
					my $yr_avg = $yr_avgs{$stock}->{"avg"};

					if ($yr eq "2009") {
						#print "$month\n";
						#print "$stock :: $month :: $yr :: $yr_avg :: $month_price\n";
					}

					my $delta = (($month_price - $yr_avg) / $yr_avg) * 100;

					#print "$yr || $day || $delta\n";

					if ( not exists $per_year_avgs{$yr}->{$month} ) {
						$per_year_avgs{$yr}->{$month} = {"avg" => $delta, "count" => 1};
					}

					else {
						$per_year_avgs{$yr}->{$month}->{"count"}++;
						$per_year_avgs{$yr}->{$month}->{"avg"} += (($delta - $per_year_avgs{$yr}->{$month}->{"avg"}) / $per_year_avgs{$yr}->{$month}->{"count"});
						#print qq!$yr || $day || $per_year_avgs{$yr}->{$day}->{"avg"}\n!;
					}

					if ( not exists $per_year_avgs{"all"} ) {
						$per_year_avgs{"all"}->{$month} = {"avg" => $delta, "count" => 1};
					}
					else {
						$per_year_avgs{"all"}->{$month}->{"count"}++;
						#print qq!$delta || $per_year_avgs{"all"}->{$day}->{"avg"} || $per_year_avgs{"all"}->{$day}->{"count"}\n!;
						$per_year_avgs{"all"}->{$month}->{"avg"} += (($delta - $per_year_avgs{"all"}->{$month}->{"avg"}) / $per_year_avgs{"all"}->{$month}->{"count"});
						#print qq!$yr || $day || $per_year_avgs{"all"}->{$day}->{"avg"}\n!;
					}	
				}
			}

			#%month_prices = ();
			%month_avgs   = ();

			%yr_avgs = ();

			$current_yr = $yr;

			#$yr_avg = 0;
			#$yr_cnt = 0;

		}

		open (my $f, "<$file");

		while ( <$f> ) {

			chomp;
			my @bts = split/,/, $_;

			unless ( $bts[5] eq "-" or $bts[3] eq "-" or  $bts[5] eq "0" or $bts[3] eq "0") {

				#$month_prices{$bts[0]}->{$day} = $bts[3];

				if ( not exists $month_avgs{$bts[0]}->{$month} ) {
					$month_avgs{$bts[0]}->{$month} = {"avg" => $bts[3], "count" => 1 };
				}

				else {
					$month_avgs{$bts[0]}->{$month}->{"count"}++;
					$month_avgs{$bts[0]}->{$month}->{"avg"} +=  ($bts[3] - $month_avgs{$bts[0]}->{$month}->{"avg"}) / $month_avgs{$bts[0]}->{$month}->{"count"};
				}

				if (not exists $yr_avgs{$bts[0]}) {
					$yr_avgs{$bts[0]} = { "avg" => $bts[3], "count" => 1 };
				}
				else {
					$yr_avgs{$bts[0]}->{"count"}++;
					$yr_avgs{$bts[0]}->{"avg"} +=  ($bts[3] - $yr_avgs{$bts[0]}->{"avg"}) / $yr_avgs{$bts[0]}->{"count"};
				}
			}

		}

		close($f);


	}
}

open (my $f, ">month_margins.csv");

print "Year\t";
foreach (1..12) {
	printf "%4d\t", $_; 
}
print $/;

for my $yr ( sort { return 1 if ($a eq "all"); return -1 if ($b eq "all"); $a <=> $b } keys %per_year_avgs ) {

	print "$yr\t";
	print $f "$yr,";

	my @month_margins = ();
	my @month_margins_formatted = ();

	for my $month (1..12) {

		my $month_formatted = sprintf("%02d", $month);
		my $avg = "-";

		if ( exists $per_year_avgs{$yr}->{$month_formatted}->{"avg"} ) {
			$avg = sprintf("%0.4f", $per_year_avgs{$yr}->{$month_formatted}->{"avg"});
		}

		else {
			#print "N/A";
		}
		push @month_margins_formatted, $avg;
		push @month_margins, $avg;	

	}
	print join("\t", @month_margins_formatted), $/;
	print $f join(",", @month_margins), $/;
}

close($f);
