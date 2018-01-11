#!/usr/bin/perl

use strict;
use warnings;

use List::Util qw/shuffle/;

my @txt_files = shuffle(<files/files/*.txt>);

for my $txt_file (@txt_files) {

	my $isin = 0;
	my $summary = 0;

	open(my $f, "<$txt_file");

	my @lines = <$f>;

	my $lines_str = join("", @lines);


	if ($lines_str =~ /KE\d{10}/) {
		$isin++;	
	}

	elsif ($lines_str =~ /^Banking Sector$/im or $lines_str =~ /^Banking$/im) {
		$summary++;
	}

	if ( $isin ) {

		#print "***---$txt_file----****\n";

		my $csv_out_f_name = $txt_file;
		$csv_out_f_name =~ s/\.txt$/.csv/g;
 
		open ( my $csv_out_f, ">$csv_out_f_name" );

		for my $line (@lines) {

			chomp($line);

			if ($line =~ /\WKE\d{10}\W/) {

				my @fields = split/\s{3,}/, $line;
			
				my $num_shares = 0;
				if ($fields[$#fields] =~ /^([\d,]+)$/) {
					$num_shares = $1;
					$num_shares =~ s/,//g;
				}

				#my $company_name_index = undef;
				my $company_name = undef;

				for ( my $i = 0; $i < scalar(@fields); $i++ ) {

					if ( $fields[$i] =~ /(.*?)(?:\s*ltd\s*)?ord\W+/i or $fields[$i] =~ /(.*?)(?:\s*ltdgems\s*)/i ) {

						$company_name = $1;

						#some company names are prefixed by the 
						#12-month low. clean that.
						$company_name =~ s/^\d+\.\d+\s*//g;
						$company_name =~ s/^\-\s*//g;
						#$company_name_index = $i;
						#print $company_name, $/;
						last;
					}
				}

				my ($high,$low,$avg,$prev) = ("-", "-", "-", "-");

				if ( $fields[$#fields -1] =~ /^\d+\.\d+?$/ ) {
					$prev = $fields[$#fields -1];
				}
				if ( $num_shares > 0 ) {

					if ( scalar(@fields) > 4 ) {
	
						if ( $fields[$#fields -2] =~ /^\d+\.\d+?$/ ) {
							$avg = $fields[$#fields -2];
						}
	
						if ( $fields[$#fields -3] =~ /^\d+\.\d+?$/ ) {
							$low = $fields[$#fields -3];
						}
	
						if ( $fields[$#fields -4] =~ /^\d+\.\d+?$/ ) {
							$high = $fields[$#fields -4];
						}
					}

				}

				if (defined $company_name) {
					print $csv_out_f "$company_name,$high,$low,$avg,$prev,$num_shares\n";
				}
			}
	
		}

		#last;
		#print "$txt_file,ISIN", $/;
	}

	elsif ($summary ) {

		my $csv_out_f_name = $txt_file;
		$csv_out_f_name =~ s/\.txt$/.csv/g;
 
		open ( my $csv_out_f, ">$csv_out_f_name" );

		#print "--**--$txt_file--**--", $/;
		my $sector = "";

		#break on periods not newlines
		my @semantic_lines = split/(?:\.\s+)|(?:\.\n)/, $lines_str;

		my $line_num = 0;

		my $seen_respectively = 0;
		for my $line ( @semantic_lines ) {


			$line =~ s/^.*sector\n//ig;
			$line =~ s/^(?:(Agricultural)|(Automobiles (and|&) Accessories)|(Banking)|(Commercial (and|&) Services)|(Construction (and|&) Allied)|(Energy (and|&) Petroleum)|(Growth Enterprise Market)|(Indices)|(Insurance)|(Investment)|(Investment Services)|(Manufacturing (and|&) Allied)|(Real Estate Investment Trusts)|(Sector)|(Telecommunication (and|&) Technology))//ig;

			if ($line =~ /respectively$/) {

				$line =~ s/^Automobiles\s*&\s*Accessories\n//ig;

				if ( $line =~ /^((.*?)\s+(?:\&|(?:and))\s+)/i ) {

					my $prefix = $1;
					my $company_1 = $2;
			
					$line =~ s/^$prefix//;

					if ($line =~ /^(.*)\s+(?:remained|each)/) {
						my $company_2 = $1;

						my $shares_1 = "-";

						if ( $line =~ /((?:\d+(?:\.\d+)?M)|(?:[\d,]+))\s+shares/i) {

							my $shares_1 = $1;
							my $shares_1_numeric = $shares_1;

							if (index($shares_1, "M") >= 0) {
								$shares_1_numeric =~ s/M$//;
								$shares_1_numeric *= 1000000;
							}

							$shares_1_numeric =~ s/,//g;

							#$shares_1 *= 1000000;
							$line =~ s/$shares_1//;

							if ( $line =~ /((?:\d+(?:\.\d+)?M)|(?:[\d,]+))\s+shares/i) {

								my $shares_2 = $1;
								my $shares_2_numeric = $shares_2;

								if (index($shares_2, "M") >= 0) {
									$shares_2_numeric =~ s/M$//;
									$shares_2_numeric *= 1000000;
								}

								$shares_2_numeric =~ s/,//g;

								my $price_1 = "-";

								if ( $line =~ /shs|kes\.(\d+(?:\.\d+))/i ) {

									my $price_1 = $1;
									#print "178: $price_1 :: \n\t$line\n";
									$line =~ s/$price_1//;

									if ( $line =~ /shs|kes\.(\d+(?:\.\d+))/i ) {

										my $price_2 = $1;

										print $csv_out_f "$company_1,-,-,$price_1,-,$shares_1_numeric\n";
										print $csv_out_f "$company_2,-,-,$price_2,-,$shares_2_numeric\n";
										
									}
	
								}
							}
						}
					}
				}
			}
			elsif ( $line =~ /^([A-Z]\S*(?:\s[A-Z]\S*)?(?:\s[A-Z]\S*)?)/ ) {

				my $company = $1;
				$company =~ s/\n/ /;

				my $high = "-";
				my $low  = "-";
				my $avg  = "-";

				my $num_shares = "-";

				$line =~ s/\n/ /g;

				$line .= " ";

				if ( $line =~ /(?:(?:shs|kes)\.(\d+(?:\.\d+))).*?\s+and\s+.*?(?:(?:shs|kes)\.(\d+(?:\.\d+)))/i) { 

					$high = $1;
					$low  = $2;

					#print "PARTIAL: $high;$low\n\t$line\n";

					if ( $high < $low ) {
						my $tmp = $high;
						$high = $low;
						$low  = $tmp;
					}

					$avg = $low;

				}
				elsif ( $line =~ /(?:shs|kes\.(\d+(?:\.\d+)))/i ) {
					$avg = $1;
				}

				if ( $line =~ /((?:\d+(?:\.\d+)?M)|(?:[\d,]+)) shares/i ) {

					my $shares = $1;

					$shares =~ s/,//g;
					$num_shares = $shares;

					if ($shares =~ /M$/) {
						$shares =~ s/M$//;
						$num_shares = $shares * 1000000;
					}

				}

				if ( defined $avg and $avg ne "-" and $num_shares ne "-" ) {
					print $csv_out_f "$company,$high,$low,$avg,-,$num_shares\n";
				}

			}

			$line_num++;

		}
	
		#print "$txt_file,SUMMARY", $/;
		#last if ($seen_respectively);
	}

	else {
		print $txt_file, $/;
		print $lines_str;
		last;
	}

	close($f);
}

#print scalar(@txt_files), $/;


