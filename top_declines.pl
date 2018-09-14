#!/usr/bin/perl

use strict;
use warnings;

use Time::Local;

my %nse_20_data = ();

my @dates = ();
my @index_points = ();

open(my $nse_20_f, "<nse_20.csv");

while (<$nse_20_f>) {

	chomp;

	my @bts = split/,/, $_;

	next if not defined $bts[1];

	if ($bts[1] =~ /^\d+(\.\d+)?$/) {
		push @dates, $bts[0];
		push @index_points, $bts[1];

	}
	
}

my %top_declines = ();

my @stack_dates = ();
my @stack_points = ();

my $min_range = 12*24*60*60;
my $max_range = 16*24*60*60;

for (my $i = 0; $i < scalar(@dates); $i++) {

	push @stack_dates, $dates[$i];
	push @stack_points, $index_points[$i];

	my @stack_bottom_bts = split/\-/,$stack_dates[0];
	my @stack_top_bts = split/\-/, $stack_dates[$#stack_dates];

	my $stack_bottom_time = timelocal(0,0,0,$stack_bottom_bts[2],$stack_bottom_bts[1]-1,$stack_bottom_bts[0]);
	my $stack_top_time = timelocal(0,0,0,$stack_top_bts[2],$stack_top_bts[1]-1,$stack_top_bts[0]);


	my $diff_time = $stack_top_time - $stack_bottom_time;
	if ( $diff_time >= $min_range and $diff_time <= $max_range ) {

		my $diff_points = ($stack_points[$#stack_points] - $stack_points[0]) / $stack_points[0];

		#print "$stack_dates[0] - $stack_dates[$#stack_dates]: ", $diff_points, $/;

		$top_declines{"$stack_dates[0]-$stack_dates[$#stack_dates]"} = $diff_points;
		my @sorted_declines = sort { $top_declines{$a} <=>  $top_declines{$b} } keys %top_declines;

		if (scalar(@sorted_declines) > 10) {
			delete $top_declines{$sorted_declines[$#sorted_declines]};
		}

	}

	while (scalar(@stack_dates) > 0) {

		my @stack_pos_j_bts = split/\-/,$stack_dates[0];
		my $stack_pos_j_time = timelocal(0,0,0,$stack_pos_j_bts[2],$stack_pos_j_bts[1]-1,$stack_pos_j_bts[0]);

		my $pos_j_diff = $stack_top_time - $stack_pos_j_time;

		if ($pos_j_diff > $max_range)  {
			shift @stack_dates;
			shift @stack_points;
		}
		else {
			last;
		}
	}
}


close($nse_20_f);

for my $date ( sort { $top_declines{$a} <=> $top_declines{$b} } keys %top_declines ) {
	print $date,",",$top_declines{$date},$/;	
}
