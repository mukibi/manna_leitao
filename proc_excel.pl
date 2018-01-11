#!/usr/bin/perl

use strict;
use warnings;
use Spreadsheet::Read;
use Data::Dumper;


my @files = <files/files/*.xls>;

push @files, <files/files/*.xlsx>;

my $past_skip = 0;

for my $file (@files) {

	#around 2011, the NSE introduced ISINs
	#to the Excel format
	#
	if ($file =~ m{/2011\-}) {
		$past_skip++;
	}

	next unless($past_skip);

	my $csv_file_name = $file;
	$csv_file_name =~ s/\.xlsx?/.csv/;

	#next if (-e $csv_file_name);

	print "Proc'ng $file$/";

	open (my $csv_file, ">$csv_file_name");

	eval {
	my $book = Spreadsheet::Read->new($file);
	next if (not defined $book);

	my $sheet = $book->sheet(1);

	next if (not defined $sheet);

	my $num_cols = $sheet->maxcol;
	my $num_rows = $sheet->maxrow;

	#print $file, ": ",  $sheet->maxcol, "; ", $sheet->maxrow, $/;
	my $incorrect_cols_offset = 1;

	my $all_filled = 1;
	my $is_isin = 0;
	my $vwap_offset = 0;
	my $isin_multi_col = 0;

	for my $row (1..$num_rows) {

		my $company_name = $sheet->cell(3, $row);
	
		if ( defined ($company_name) ) {

			if ($company_name =~ /(.*?)(?:\s*ltd\s*)?ord\W+/i or $company_name =~ /(.*?)(?:\s*ltdgems\s*)/i ) {

				my $isin_cell_1 = $sheet->cr2cell(4, $row);
				my $isin_val_1 = $sheet->cell($isin_cell_1);

				my $isin_cell_2 = $sheet->cr2cell(5, $row);
				my $isin_val_2 = $sheet->cell($isin_cell_2);

				if ($isin_val_1 eq "K" and $isin_val_2 eq "E") {
					$isin_multi_col++;
					last;
				}

				my $isin_cell = $sheet->cr2cell(4, $row);
				my $isin_val = $sheet->cell($isin_cell);

				if ($isin_val =~ /KE\d{10}/) {
					$is_isin = 1;	
					last;
				}

				
				my $cell_n = $sheet->cr2cell(7, $row);

				my $tmp_prev = $sheet->cell($cell_n);

				unless ( defined $tmp_prev and $tmp_prev =~ /^\d+(\.\d+)$/ ) {
					$all_filled = 0;
					#print "Invalid entry for $company_name ($tmp_prev)\n";
					last;
				}




			}

		}
	}

	if ($all_filled) {
		$incorrect_cols_offset = 0;
	}

	if ($is_isin) {

		$incorrect_cols_offset = 2;

		#last;
	}

	if ($isin_multi_col) {
		$incorrect_cols_offset = 13;
	}

	for my $row (1..$num_rows) {

		my @data = ();

		my $company_name = $sheet->cell(3, $row);
	
		if ( defined ($company_name) ) {

			if ($company_name =~ /(.*?)(?:\s*ltd\s*)?ord\W+/i or $company_name =~ /(.*?)(?:\s*ltdgems\s*)/i ) {

				$company_name = $1;

				$company_name =~ s/^\s*//g;
				$company_name =~ s/\s*$//g;

				
				my ($high, $low, $close, $prev, $num_shares) = ("-","-","-","-","-");


				my $tmp_high = $sheet->cell(4+$incorrect_cols_offset, $row);
				if ( defined $tmp_high and $tmp_high =~ /^\d+(\.\d+)?$/ ) {
					$high = $tmp_high;
				}

				my $tmp_low = $sheet->cell(5+$incorrect_cols_offset, $row);
				if ( defined $tmp_low and $tmp_low =~ /^\d+(\.\d+)?$/ ) {
					$low = $tmp_low;
				}

				my $tmp_close = $sheet->cell(6+$incorrect_cols_offset, $row);
				if ( defined $tmp_close and $tmp_close =~ /^\d+(\.\d+)?$/ ) {
					$close = $tmp_close;
				}

				my $tmp_prev = $sheet->cell(7+$incorrect_cols_offset, $row);
				if ( defined $tmp_prev and $tmp_prev =~ /^\d+(\.\d+)?$/ ) {
					$prev = $tmp_prev;
				}

				my $tmp_num_shares = $sheet->cell(8+$incorrect_cols_offset, $row);
				if ( defined $tmp_num_shares and $tmp_num_shares =~ /^\d+(\.\d+)?$/ ) {
					$num_shares = $tmp_num_shares;
				}

				print $csv_file "$company_name,$high,$low,$close,$prev,$num_shares$/";

			}

		}



		for my $col (1..$num_cols) {
		#	push @data, $sheet->cell($col, $row);
		}

		#print join(" ", @data), $/;

	}

	#last;

	close($csv_file);
	};

}


  
