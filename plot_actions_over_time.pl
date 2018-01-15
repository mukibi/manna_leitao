#!/usr/bin/perl

use strict;
use warnings;

my %events = ();

open (my $f, "<corporate_events.csv");

my %actions = ();
my %yrs = ();

while ( <$f> ) {

	chomp;
	my @bts = split/,/, $_;

	if ( $bts[3] =~ m![/\-](\d{2,4})$! ) {

		my $yr = $1;
		#convert 2-digit years to 3 digits
		if (length($yr) == 2) {
			$yr = "20$yr";
		}

		$actions{$bts[1]}++;
		$yrs{$yr}++;

		$events{$yr}->{$bts[1]}++;

	}

}


my $max = 0;
for my $yr ( keys %events ) {
	for my $action_type (keys %{$events{$yr}}) {
		if ($events{$yr}->{$action_type} > $max) {
			$max = $events{$yr}->{$action_type};
		}
	}
}

my @color_palette = ("#000000","#0000FF","#A52A2A","#7FFF00","#FFD700","#00FF00","#FF00FF","#6B8E23","#FFA500","#A020F0","#FF0000","#A0522D","#00FFFF","#FF7F50","#B03060","#7FFFD4","#D2691E","#B22222","#000080","#DA70D6","#FA8072","#FF6347","#40E0D0","#EE82EE","#FFFF00","#CD853F");


my @sorted_yrs = sort {$a <=> $b} keys %yrs;
my $num_yrs = scalar(@sorted_yrs);

my $x_tics = join(", ", @sorted_yrs);
my $gnuplot_code = 
qq%set terminal png size 1000,1000;\\
set output 'corp_deals.png';\\
set multiplot;\\
set title 'Number of Corporate Actions per Year';\\
set xlabel 'Year';\\
set ylabel 'Number of Actions';\\
set xrange [2000:2017];\\
set yrange [0:$max];\\
set ytics;\\
set grid ytics;\\
set grid xtics;\\
set tmargin at screen 0.9;\\
set bmargin at screen 0.1;\\
set rmargin at screen 0.98;\\
set lmargin at screen 0.08;\\
set xtics($x_tics);\\
%;


my $gnuplot_data = "";
my $color_cntr = 0;

for my $action ( sort { $a cmp $b } keys %actions ) {

	for ( my $i = 0; $i < @sorted_yrs; $i++ ) {

		my $num_actions = 0;
		if (exists $events{$sorted_yrs[$i]}->{$action}) {
			$num_actions = $events{$sorted_yrs[$i]}->{$action};
		}

		$gnuplot_data .= 2000+$i . " $num_actions\n";
	}

	my $y_loc = 30 - (2*$color_cntr);

	$gnuplot_data .= "e\n";
	$gnuplot_code .= 
qq%
set label '$action' tc rgb '$color_palette[$color_cntr]' at 5,$y_loc;\\
plot '-' using 1:2 notitle with linespoints linecolor rgb '$color_palette[$color_cntr]' linewidth 3;\\
%;
	$color_cntr++;

}


`echo '$gnuplot_data' | gnuplot -e "$gnuplot_code"`;
print $gnuplot_code, $/;
