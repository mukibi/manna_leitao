#!/usr/bin/perl

use strict;
use warnings;

use Spreadsheet::Read;
use Digest::MD5 qw(md5_hex);

my %month_lookup = ("jan" =>"01","feb" =>"02","mar" =>"03","apr" =>"04","may" =>"05","jun" =>"06","jul" =>"07","aug" =>"08","sep" =>"09","oct" => "10","nov" => "11","dec" => "12");
my %month_lookup_2 = ("january" =>"01","february" =>"02","march" =>"03","april" =>"04","may" =>"05","june" =>"06","july" =>"07","august" =>"08","september" =>"09","october" => "10","november" => "11","december" => "12");

my @files = <files/files/*.xls>;

push @files, <files/files/*.xlsx>;

my %corp_events = ();

my $skip = 1;
my $id = 0;

for my $file (sort {$a cmp $b} @files ) {

	#if ( $file =~ m{/2012-09} ) {
	#	$skip = 0;
	#}

	#next if ($skip);

	print $file, $/;

	my $seen_announcement = 0;

	eval {

		my $book = Spreadsheet::Read->new($file);
		next if (not defined $book);

		my $sheet = $book->sheet(1);

		next if (not defined $sheet);

		my $num_rows = $sheet->maxrow;

		my $in_announcements = 0;
		my $fail = 0;

		for my $row ( 1..$num_rows ) {

			my $first_cell = $sheet->cell(1, $row);

			if ( defined $first_cell  and length($first_cell) > 0 ) {

				#print ($first_cell);
				if ( $in_announcements ) {

					my $company = undef;
					my $type = undef;
					my $details = undef;
					my $date = undef;

					my $valid = 0;
					$first_cell =~ s/ann'ced/announced/g;
					$first_cell =~ s/(?:(?:shs)|(?:kes))\.\./shs.0./g;
					$first_cell =~ s/BATannounced/BAT announced/g;
					$first_cell =~ s/share split of 10:1on/share split of 10:1 on/g;
					$first_cell =~ s/announced  a bonus1:5/announced  a bonus 1:5/g;
					$first_cell =~ s/bonus of 2:1on/bonus of 2:1 on/g;
					$first_cell =~ s/bonus of 1:1\(1 share for every/bonus of 1:1 (1 share for every/g;
					$first_cell =~ s/August \-2010/August-2010/g;
					$first_cell =~ s/Ratio of 20:51at/Ratio of 20:51 at/g;
					$first_cell =~ s/\s+(\d+)\s+.*?for\s+(?:every\s)?(\d+)\s+.*?held/ $1:$2 /g;
					$first_cell =~ s/\s+(\d+)\s+for\s+(\d+)\s+/ $1:$2 /g;
					$first_cell =~ s/share-split/share split/g;
					$first_cell =~ s/01\-March 2012/01-March-2012/g;

					if ( $first_cell =~ m!^(.*?)\s+rights?\s+issue:?\s+.*?(\d+:\d+)\s+.*?(?:(?:shs)|(?:kes)|(?:ksh))?[\.\s]?(\d+(?:\.\d+)).*\s+(\d{1,2}[/\-](?:(?:\d{1,2})|(?:[a-z]{3,9}))[/\-]\d{2,4})!i ) {

						$company = $1;
						$type = "RIGHTS ISSUE";
						$details = "$2 for $3";
						$date = $4;

                                                $date =~ s/\/(\d{2})$/\/20$1/;

						if ($date =~ m{[/\-]([a-z]{3})[/\-]}i) {
							my $month = lc($1);
							my $month_numeric = $month_lookup{$month};
							$date =~ s/$month/$month_numeric/i;
						}

						if ($date =~ m{[/\-]([a-z]{3,9})[/\-]}i) {
							my $month = lc($1);
							my $month_numeric = $month_lookup_2{$month};
							$date =~ s/$month/$month_numeric/i;
						}

						$valid++;

					}

					elsif ( $first_cell =~ m!^(.*?)\s+(?:(?:announced)|(?:issued))\s+.*?(?:(?:dividend)|(?:div)|(?:final))\s+.*(?:(?:shs)|(?:kes)|(?:ksh))?[\.\s]?(\d+(?:\.\d+))\s+.*?\s+(\d{1,2}[/\-](?:(?:\d{1,2})|(?:[a-z]{3,9}))[/\-]\d{2,4})!i ) {

						$company = $1;
						$type = "DIVIDEND";
						$details = $2;
						$date = $3;
				
						#print "$first_cell: $details\n";

						#$date =~ s/\/\d{2}$/20$1/;
                                                $date =~ s/\/(\d{2})$/\/20$1/;
	
						if ($date =~ m{[/-]([a-z]{3})[/-]}i) {
							my $month = lc($1);
							my $month_numeric = $month_lookup{$month};
							$date =~ s/$month/$month_numeric/i;
							#print "Date: $date\n";
						}

						if ($date =~ m{[/\-]([a-z]{3,9})[/-]}i) {
							my $month = lc($1);
							my $month_numeric = $month_lookup_2{$month};
							$date =~ s/$month/$month_numeric/i;
							#print "Date: $date\n";
						}

						$valid++;


					}

					elsif ( $first_cell =~ m!^(.*?)\s+(?:(?:announced)|(?:issued))\s+.*?\s*bonus\s+.*(\d+:\d+)\s+.*?\s+(\d{1,2}[/\-](?:(?:\d{1,2})|(?:[a-z]{3,9}))[/\-]\d{2,4})!i ) {

						$company = $1;
						$type = "BONUS";
						$details = $2;
						$date = $3;

                                                $date =~ s/\/(\d{2})$/\/20$1/;
						if ($date =~ m{[/\-]([a-z]{3})[/\-]}i) {
							my $month = lc($1);
							my $month_numeric = $month_lookup{$month};
							$date =~ s/$month/$month_numeric/i;
						}

						if ($date =~ m{[/\-]([a-z]{3,9})[/\-]}i) {
							my $month = lc($1);
							my $month_numeric = $month_lookup_2{$month};
							$date =~ s/$month/$month_numeric/i;
						}

						$valid++;


					}

					elsif ( $first_cell =~ m!^(.*?)\s+(?:(?:offered)|(?:announced))\s+.*\s*rights?\s+issue\s+.*(\d+:\d+)\s+.*?\s+(\d{1,2}[/\-](?:(?:\d{1,2})|(?:[a-z]{3,9}))[/\-]\d{2,4})!i ) {

						$company = $1;
						$type = "RIGHTS ISSUE";
						$details = "$2 for -";
						$date = $3;

                                                $date =~ s/\/(\d{2})$/\/20$1/;
						if ($date =~ m{[/\-]([a-z]{3})[/\-]}i) {
							my $month = lc($1);
							my $month_numeric = $month_lookup{$month};
							$date =~ s/$month/$month_numeric/i;
						}

						if ($date =~ m{[/\-]([a-z]{3,9})[/\-]}i) {
							my $month = lc($1);
							my $month_numeric = $month_lookup_2{$month};
							$date =~ s/$month/$month_numeric/i;
						}

						$valid++;

					}

					elsif ( $first_cell =~ m!^(.*?)\s+(?:(?:announced)|(?:issued))\s+.*?\s*share\s+split\s+.*?(\d+:\d+)\s+.*?\s+(\d{1,2}[/\-](?:(?:\d{1,2})|(?:[a-z]{3,9}))[/\-]\d{2,4})!i ) {
					#elsif ( $first_cell =~ m!^(.*?)\s+(?:(?:announced)|(?:issued))\s+.*?\s*share\s+split! ) {

						#$fail++;
						#print "Match\n";
						#last;

						$company = $1;
						$type = "SHARE SPLIT";
						$details = $2;
						$date = $3;

                                                $date =~ s/\/(\d{2})$/\/20$1/;
						if ($date =~ m{[/\-]([a-z]{3})[/\-]}i) {
							my $month = lc($1);
							my $month_numeric = $month_lookup{$month};
							$date =~ s/$month/$month_numeric/i;
						}

						if ($date =~ m{[/\-]([a-z]{3,9})[/\-]}i) {
							my $month = lc($1);
							my $month_numeric = $month_lookup_2{$month};
							$date =~ s/$month/$month_numeric/i;
						}

						$valid++;


					}
	
					if ($valid) {

						my $hash = md5_hex($company . $type . $details . $date);
						$id++;
						$corp_events{$hash} = {"event" => "$company,$type,$details,$date", "id" => $id};

					}

					else {
						if ( $first_cell =~ /explanations/i or $first_cell =~ /VWAP/i) {
							$in_announcements = 0;
							last;
						}
						else {
							#print $file, ": ", $row, ": " , $first_cell, $/;
							#$fail++;
							last;
						}

					}
				}
				elsif ( $first_cell =~ /^announcements$/i or  $first_cell =~ /^corporate\s+actions:?$/i ) {
					$in_announcements++;
				}

			}

			elsif ($in_announcements) {
				last;
			}
		}

		if ($fail or not $in_announcements) {
			#print $file, $/;
			#last;
		}

	}

}

open (my $f, ">corporate_events.csv");

for my $event ( sort {$corp_events{$a}->{"id"} <=> $corp_events{$b}->{"id"} } keys %corp_events ) {
	print $f $corp_events{$event}->{"event"}, $/;
}



