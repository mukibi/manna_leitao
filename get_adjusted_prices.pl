#!/usr/bin/perl

use strict;
use warnings;
use Spreadsheet::Read;

#use Spreadsheet::ParseExcel;
use Time::Local qw/timelocal/;

my @files = <files/files/*.xls>;
push @files, <files/files/*.xlsx>;

my %stocks = ();
my $skip = 1;

my %events   = ();
my $event_id = 0;

for my $file (sort { $a cmp $b } @files ) {

	if ($file =~ m{/2002-} ) {
		$skip = 0;
	}
	#next if ($skip);

	my $date = undef;

	if ( $file =~ /(\d{4}-\d{2}-\d{2})/ ) {
		$date = $1;
	}

	next unless (defined $date);
	#next unless ($file =~ /\.xls/);

	print $file, $/;

	#open (my $file_h, "<$file");
	#binmode($file_h);

	eval {

		my $book = Spreadsheet::Read->new($file);
		next if (not defined $book);

		my $sheet = $book->sheet(2);
	 	#my $parser = Spreadsheet::ParseExcel->new();
		#my $workbook = $parser->parse($file);

		next if (not defined $sheet);
		#print "...\n";

		#next if (not defined $workbook);

		#my $sheet = $workbook->worksheet(1);

		my $num_cols = $sheet->maxcol;
		my $num_rows = $sheet->maxrow;

		#print "$num_cols...\n";
		my $space = " ";

		#print "Num cols: ", $num_cols, $/;
		#next;

		my $company_name_col = 1;
		my $num_shares_col = 2;

		if ($num_cols > 4) {
			$company_name_col = 5;
			$num_shares_col = 6;
		}

		for my $row ( 1..$num_rows ) {

			#print $/;
			#next;

			my $company_name = $sheet->cell($company_name_col, $row);
			#print $company_name, $/;

			#my $company_name_cell = $sheet->get_cell($row, 0);
			#next unless (defined $company_name_cell);

			#my $company_name = $sheet->cell(1, $row);
			#my $company_name = $company_name_cell->value();

			if ( defined $company_name ) {

				#print $company_name, "\t";

				if ( $company_name =~ /^\s*(.*)\Word\W/i ) {

					$company_name = $1;
					$company_name =~ s/\sco\.?\s//ig;
					$company_name =~ s/\sltd\W*//ig;

					$company_name =~ s/[^a-z\s]//gi;
					$company_name =~ s/\s+/ /gi;

					my $company_uc = uc($company_name);

					#my $num_shares_cell = $sheet->get_cell($row, 1);
					#my $num_shares = $num_shares_cell->value();

					#my $celln = $sheet->cr2cell(2, $row);

					my $num_shares = $sheet->cell($num_shares_col, $row);
					
					#$num_shares =~ s/,//g;

				#	if ( $company_uc =~ /KENYA COMM/ ) {
				#		print "$num_shares\n";
				#	}

					#next;

					if ( not exists $stocks{$company_uc} ) {
						$stocks{$company_uc} = {"unformatted_name" => $company_name, "init_num_shares" => $num_shares, "current_num_shares" => $num_shares, "last_reset_date" => $date };
					}

					elsif ( $num_shares != $stocks{$company_uc}->{"current_num_shares"} ) {

						my $ratio = $stocks{$company_uc}->{"current_num_shares"} / $stocks{$company_uc}->{"init_num_shares"};
						my @day_bts = split/-/, $date;

						my $day_secs = timelocal(0,0,0,$day_bts[2], $day_bts[1]-1,$day_bts[0]);
						$day_secs -= (24*60*60);

						my @prev_day_bts = localtime($day_secs);
						my $prev_day = sprintf( "%4d-%02d-%02d", 1900+$prev_day_bts[5], $prev_day_bts[4] + 1, $prev_day_bts[3] );

						#my $date_range 
						$events{$event_id++} = qq!$company_uc,$ratio,$stocks{$company_uc}->{"last_reset_date"} $prev_day!;

						#update last_reset_date and current_num_shares
						$stocks{$company_uc}->{"last_reset_date"} = $date;
						$stocks{$company_uc}->{"current_num_shares"} = $num_shares;

						print "$company_uc -> $ratio$/";
					}
					else {
						if ($company_uc =~ /KENYA COMM/) {
							#print qq!$company_uc: $stocks{$company_uc}->{"current_num_shares"} : $num_shares\n!;
						}
					}

					#print $company_name;
				}

				#print $/;
			}

		}

		$book = undef;
		$sheet = undef;


	};

	#close($file_h);
	#last;
}

#close share change
for my $company (keys %stocks) {

	my $ratio = $stocks{$company}->{"current_num_shares"} / $stocks{$company}->{"init_num_shares"};
	$events{$event_id++} = qq!$company,$ratio,$stocks{$company}->{"last_reset_date"} 2017-12-31!;

}

open (my $f, ">dilution.csv");

for my $event (keys %events) {
	print $f $events{$event}, $/;
}
