#!/usr/bin/perl

use strict;
use warnings;
use feature "switch";

my %month_lookup = ("jan" =>"01","feb" =>"02","mar" =>"03","apr" =>"04","may" =>"05","jun" =>"06","jul" =>"07","aug" =>"08","sep" =>"09","oct" => "10","nov" => "11","dec" => "12");

my %files = ();
my $matched = 0;
my %yrs = ();
my %raw_yrs = ();

my %pdf_collisions = ();

open (my $f, "<all_meta.csv");

while (<$f>) {

	chomp;
	my @bts = split/,/, $_;

	next if (not defined $bts[1]);

	if ( $bts[1] =~ /(\d{4})/ ) {
		$raw_yrs{$1}++;
	}

	my $day = undef;
	my $month = undef;
	my $yr = undef;
	my $ext = undef;

	if ( $bts[1] =~ /^(\d{2})\-(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[^-]*\-(\d{4})\.(xlsx?|pdf)/i ) {

		$day = $1;
		$month = $2;
		$yr = $3;

		$ext = $4;

	}

	elsif ( $bts[1] =~ /^(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[^-]*\-(\d{2})\-(\d{4})\.(xlsx?|pdf)/i ) {

		$day = $2;
		$month = $1;
		$yr = $3;

		$ext = $4;
	}

	elsif ( $bts[1] =~ /^equity\-price\-list\-(\d{2})\-(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\-(\d{4})\.(xlsx?|pdf)/ ) {

		$day = $1;
		$month = $2;
		$yr = $3;

		$ext = $4;

	}
	
	if (defined $day and defined $month and defined $yr and defined $ext) {

		$ext = lc($ext);
		$month = $month_lookup{lc($month)};

		my $f_name = "$yr-$month-$day.$ext";
		
		if ( not exists $files{$f_name} ) {
			$files{$f_name} = $bts[0];
		}
		#overwrite .pdf
		elsif ($ext eq "xls") {
			$files{$f_name} = $bts[0];		
		}
		
	}

}

for my $f_name (sort { $a cmp $b } keys %files) {
	print "$files{$f_name},$f_name\n";
} 


