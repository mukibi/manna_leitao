#!/usr/bin/perl

use strict;
use warnings;

my @month_start_files = <files/2018\-0[1-7]-0[1-9].csv>;

my @month_end_files = <files/2018\-0[1-7]-2[2-9].csv>;
push @month_end_files,<files/2018\-0[1-7]-3[01].csv>; 

my %month_start_means = ();
my %month_end_means = ();
my %month_returns = ();
my %half_year_returns = ();

my %index_to_name = ();
my %months = ();

for my $file (sort {$a cmp $b} @month_start_files) {



	my $month = undef;
	if ( $file =~ /2018\-(\d{2})\-/ ) {
		$month = $1;
	}

	next if (not defined $month);
	$months{$month}++;


	if (not exists $month_start_means{$month}) {
		$month_start_means{$month} = {};
		$month_returns{$month} = {};
	}
	open (my $f, "<$file");

	while (<$f>) {
		chomp;
		my @bts = split/,/, $_;

		if (not exists $index_to_name{$.}) {
			$index_to_name{$.} = $bts[0];
		}


		next unless ($bts[3] =~ /^\d+(\.\d+)?$/);
		next unless ($bts[3] > 0);

		if ( not exists $month_start_means{$month}->{$.} ) {
			$month_start_means{$month}->{$.} = {"mean" => $bts[3], "count" => 1};
		}
		else {
			next if ($month_start_means{$month}->{$.}->{"count"} >= 4);
			$month_start_means{$month}->{$.}->{"mean"} += ($bts[3] - $month_start_means{$month}->{$.}->{"mean"}) / ++$month_start_means{$month}->{$.}->{"count"};
		}
	}
	close($f);
}



for my $file (sort {$b cmp $a} @month_end_files) {
	

	my $month = undef;
	if ( $file =~ /2018\-(\d{2})\-/ ) {
		$month = $1;
	}

	
	next if (not defined $month);
	$months{$month}++;
	$month_end_means{$month} = {} if not (exists $month_end_means{$month});



	open (my $f, "<$file");

	while (<$f>) {
		chomp;
		my @bts = split/,/, $_;

		if (not exists $index_to_name{$.}) {
			$index_to_name{$.} = $bts[0];
		}

		next unless ($bts[3] =~ /^\d+(\.\d+)?$/);
		next unless ($bts[3] > 0);

		if ( not exists $month_end_means{$month}->{$.} ) {
			$month_end_means{$month}->{$.} = {"mean" => $bts[3], "count" => 1};
		}
		else {
			if ( $month_end_means{$month}->{$.}->{"count"} < 4 ) { 
			$month_end_means{$month}->{$.}->{"mean"} += ($bts[3] - $month_end_means{$month}->{$.}->{"mean"}) / ++$month_end_means{$month}->{$.}->{"count"};
			}
		}

		#print "$file: $bts[0] : $bts[3] : " . $month_end_means{$month}->{$.}->{"mean"} . " " .  $/;

		if ( exists $month_start_means{$month}->{$.}->{"mean"} and $month_start_means{$month}->{$.}->{"mean"} > 0 ) {
			$month_returns{$month}->{$.} = ($month_end_means{$month}->{$.}->{"mean"} - $month_start_means{$month}->{$.}->{"mean"}) / $month_start_means{$month}->{$.}->{"mean"};


			if ($month eq "07" and exists $month_start_means{"01"}->{$.}->{"mean"} and  $month_start_means{"01"}->{$.}->{"mean"} > 0 ) {
				$half_year_returns{$.} = ($month_end_means{$month}->{$.}->{"mean"} - $month_start_means{"01"}->{$.}->{"mean"}) / $month_start_means{"01"}->{$.}->{"mean"}; 
			}
		}
		else {
			$month_returns{$month}->{$.} = 0;
		}

	}
	close($f);
}

open (my $month_returns_f, ">month_returns.csv");

my %month_name = ("01" => "January", "02" => "February", "03" => "March", "04" => "April", "05" => "May", "06" => "June", "07" => "July", "08" => "August");

print $month_returns_f "Stock,", join(",", sort { $a <=> $b } keys %months), ",HY", $/;

for my $stock_id ( sort {$a <=> $b} keys %index_to_name) {

	my @returns = ();
	
	for my $month ( sort { $a <=> $b } keys %month_returns ) {

		for my $stock_id_b (sort {$a <=> $b} keys %{$month_returns{$month}}) {
			next unless ($stock_id eq $stock_id_b);
			push @returns, sprintf("%.2f", ($month_returns{$month}->{$stock_id_b} * 100));
		}

	}

	my $hy_return = 0;
	if (exists $half_year_returns{$stock_id}) {
		$hy_return = sprintf("%.2f", $half_year_returns{$stock_id} * 100);
	}

	push @returns, $hy_return;

	print  $month_returns_f $index_to_name{$stock_id}, ",", join(",", @returns), $/;
}

close($month_returns_f);

#open (my $h1_returns_f, ">h1_returns.csv");

