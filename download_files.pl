#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;

$| = 1;

my $ua = LWP::UserAgent->new();
$ua->timeout(10);
$ua->ssl_opts( verify_hostname => 0 ,SSL_verify_mode => 0x00);


my %files = ();

open (my $f, "<files.csv");

while (<$f>) {

	chomp;
	my @bts = split/,/,$_;

	$files{$bts[0]} = $bts[1];	
}

close($f);

for my $id (keys %files) {

        my $response = $ua->get("https://www.nse.co.ke/%20index.php?option=com_phocadownload&view=category&download=$id");
        
	print "$id\n";

        if ( $response->is_success ) {

                open (my $f2, ">files/$files{$id}");

                my $content = $response->decoded_content();
                print $f2 $content;
       
		close($f2); 

        }

	else {
		print STDERR $response->status_line();
	}
	
}
