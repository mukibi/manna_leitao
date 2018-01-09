#!/usr/bin/perl

use strict;
use warnings;

chdir("files/files/");
my @files = <*.pdf>;

for my $file (@files) {
	print $file,$/;
	`pdftotext -layout $file`;
}

#print scalar(@files);

