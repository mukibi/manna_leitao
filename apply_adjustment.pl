#!/usr/bin/perl

use strict;
use warnings;

use Time::Local;
#use POSIX qw/strftime/;

my %dilution = ();

open (my $f2, "<dilution.csv");

while ( <$f2> ) {

	chomp;
	my @bts = split/,/, $_;

	my ($start_date, $stop_date) = split/\s+/, $bts[2];

	my ($start_yr, $start_month, $start_day) = split/-/, $start_date;
	my ($stop_yr, $stop_month, $stop_day) = split/-/, $stop_date;

	my $start_time = timelocal(0,0,0,$start_day, $start_month - 1, $start_yr);
	 my $stop_time = timelocal(59,59,23,$stop_day, $stop_month - 1, $stop_yr);

	$dilution{$bts[0]}->{"$start_time-$stop_time"} = $bts[1];

}

my @files = <files/files/*.csv>;


for my $file ( sort { $a cmp $b } @files ) {

	if ($file =~ /\/(\d{4})-(\d{2})-(\d{2})\.csv$/) {

		my ($yr, $month, $day) = ($1, $2, $3);
		#next unless ($yr eq "2007");

		my $time = timelocal(0, 0, 0, $day, $month - 1, $yr);

		open (my $f, "<$file");

		my $exit = 0;

		my $n_file_name = $file;
		$n_file_name =~ s!/files/!/files2/!;

		open (my $n_file, ">$n_file_name");

		while ( <$f> ) {

			chomp;
			my @bts = split/,/, $_;

			my $diluted_price = "-";

			unless ( $bts[5] eq "-" or $bts[3] eq "-" or  $bts[5] eq "0" or $bts[3] eq "0" ) {

				my $company_name = $bts[0];

				$company_name =~ s/\sco\.?\s//ig;
				$company_name =~ s/\sco\.?$//ig;

				$company_name =~ s/\sltd\W*//ig;
				$company_name =~ s/&amp;/&/ig;

				$company_name =~ s/[^a-z\s]//gi;
				$company_name =~ s/\s+/ /gi;

				$company_name =~ s/\s+$//g;

				$company_name =~ s/\s+LIMITED\s*//ig;

				$company_name =~ s/ OF KENYA//ig;
				$company_name =~ s/ COKENYA//ig;

				$company_name =~ s/STANDARD CHARTERED BANK KENYA/STANDARD CHARTERED BANK/ig;
				$company_name =~ s/EXPRESS KENYA/EXPRESS/ig;
				$company_name =~ s/CROWN BERGER KENYA/CROWN BERGER/ig;
				$company_name =~ s/KENYA RE INSURANCE/KENYA REINSURANCE/ig;
				$company_name =~ s/THE LIMURU TEA/LIMURU TEA/ig;
				$company_name =~ s/SASINI TEA$/SASINI TEA COFFEE/ig;
				$company_name =~ s/^KCB$/KENYA COMMERCIAL BANK/ig;
				$company_name =~ s/BRITISHAMERICAN INVESTMENTS COMPANY KENYA/BRITISHAMERICAN INVESTMENTS/ig;
				$company_name =~ s/^KENYA POWER$/KENYA POWER LIGHTING/ig;
				$company_name =~ s/^COOPERATIVE BANK$/THE COOPERATIVE BANK/ig;
				$company_name =~ s/UCHUMI SUPERMARKETS$/UCHUMI SUPERMARKET/ig;
				$company_name =~ s/EA CABLES/EACABLES/ig;
				$company_name =~ s/EA BREWERIES/EAST AFRICAN BREWERIES/ig;
				$company_name =~ s/^BRITISH AMERICAN TOBACCO.*$/BRITISH AMERICAN TOBACCO KENYA/ig;
				$company_name =~ s/CFC STANBIC/CFC BANK/ig;
				$company_name =~ s/CFC STANBIC HOLDINGS/CFC BANK/ig;
				$company_name =~ s/CFC BANK HOLDINGS/CFC BANK/ig;
				$company_name =~ s/BRITISH AMERICAN INVESTMENTS/BRITISHAMERICAN INVESTMENTS/ig;
				$company_name =~ s/HFCK/HOUSING FINANCE/ig;
				$company_name =~ s/CROWN PAINTS KENYA/CROWN BERGER/ig;
				$company_name =~ s/KENYA POWER AND LIGHTING/KENYA POWER LIGHTING/ig;
				$company_name =~ s/^WILLIAMSON TEA$/WILLIAMSON TEA KENYA/ig;
				$company_name =~ s/^KENYARE$/KENYA REINSURANCE CORPORATION/ig;
				$company_name =~ s/EA PORTLAND CEMENT/EAPORTLAND CEMENT/ig;
				$company_name =~ s/^EVEREADY$/EVEREADY EAST AFRICA/ig;
				$company_name =~ s/CAR GENERAL/CAR GENERAL K/ig;
				$company_name =~ s/CAR GENERAL K K/CAR GENERAL K/ig;
				$company_name =~ s/CIC INSURANCE$/CIC INSURANCE GROUP/ig;
				$company_name =~ s/COOP BANK$/THE COOPERATIVE BANK/ig;
				$company_name =~ s/^KENYA RE$/KENYA REINSURANCE CORPORATION/ig;
				$company_name =~ s/BRITISH AMERICAN INVESTMENT/BRITISHAMERICAN INVESTMENTS/ig;
				$company_name =~ s/EQUITY GROUP HOLDINGS/EQUITY BANK/ig;
				$company_name =~ s/LONGHORN PUBLISHERS/LONGHORN KENYA/ig;
				$company_name =~ s/HOUSING FINANCE GROUP/HOUSING FINANCE/ig;
				$company_name =~ s/WPP SCANGROUP/SCANGROUP/ig;
				$company_name =~ s/BRITAM HOLDINGS/BRITISHAMERICAN INVESTMENTS/ig;
				$company_name =~ s/KCB GROUP/KENYA COMMERCIAL BANK/ig;
				$company_name =~ s/DEACONS EAST AFRICA PLC/DEACONS/ig;
				$company_name =~ s/SANLAM KENYA PLC/SANLAM/ig;
				$company_name =~ s/STANBIC HOLDINGS PLC/CFC BANK/ig;
				$company_name =~ s/ARM/ATHI RIVER MINING/ig;
				$company_name =~ s/ATHI RIVER MINING CEMENT$/ATHI RIVER MINING/ig;
				$company_name =~ s/ATHI RIVER MINING CEMENT PLC$/ATHI RIVER MINING/ig;
				$company_name =~ s/CENTUM INVESTMENTPLC/CENTUM INVESTMENT/ig;
				$company_name =~ s/CARBACID INVESTMENTS PLC/CARBACID INVESTMENTS/ig;
				$company_name =~ s/BRITISHAMERICAN INVESTMENTS PLC/BRITISHAMERICAN INVESTMENTS/ig;
				$company_name =~ s/NAIROBI SECURITIES EXCHANGE PLC/NAIROBI SECURITIES EXCHANGE/ig;
				$company_name =~ s/KAKUZI PLC/KAKUZI/ig;
				$company_name =~ s/UCHUMI SUPERMARKET PLC/UCHUMI SUPERMARKET/ig;
				$company_name =~ s/HOUSING FINANCE PLC/HOUSING FINANCE/ig;
				$company_name =~ s/EQUITY BANK PLC/EQUITY BANK/ig;
				$company_name =~ s/CROWN BERGER PLC/CROWN BERGER/ig;
				$company_name =~ s/STANDARD GROUP PLC/STANDARD GROUP/ig;
				$company_name =~ s/HF GROUP PLC/HOUSING FINANCE/ig;
				$company_name =~ s/NIC GROUP PLC/NIC BANK/ig;
				$company_name =~ s/WILLIAMSON TEA KENYA PLC/WILLIAMSON TEA KENYA/ig;
				$company_name =~ s/NATION MEDIA GROUP PLC/NATION MEDIA GROUP/ig;
				$company_name =~ s/KAPCHORUA TEA KENYA PLC/KAPCHORUA TEA/ig;

				my $company_uc = uc($company_name);


				my $dilution = 1;
				for my $start_stop ( keys %{$dilution{$company_uc}} ) {

					my ($start_time, $stop_time) = split/-/, $start_stop;

					if ( $time >= $start_time and $time <= $stop_time ) {

						my $possib_dilution = $dilution{$company_uc}->{$start_stop};
						if ($possib_dilution != 0 and $possib_dilution > $dilution) {
							$dilution = $possib_dilution;
						}

					}
				}

				#print "$company_uc: $file: $dilution\n";

				$diluted_price = sprintf "%.2f", $bts[3] * $dilution;
			}

			print $n_file "$_,$diluted_price\n";

		}

		close($f);
		close($n_file);

		last if ($exit);




	}
}

