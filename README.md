# manna_leitao
N.S.E Data Analysis

I'm putting together a set of scripts, tools and data sources to anaylse data from the Nairobi Stock Exchange.

i.) get_nse_data2.pl
A Perl script to scrape nse.co.ke for a list of all files available through https://www.nse.co.ke/%20index.php?option=com_phocadownload&view=category&download=8380

ii.) all_meta.csv.bz2

A CSV with id,file name pairs returned by script (i)

iii.) get_oldest.pl

A Perl script to filter out the files containing stock data.

iv.) files.csv.bz2

A CSV file with id,output file name pairs. The file name is of the format yyyy-mm-dd.{ext} where {ext} is one of 'pdf', 'xls' or 
xlsx'.

v.) download_files.pl

A Perl script to download files from nse.co.ke

vi.) read_pdfs.pl

A little Perl script to convert the pdfs to txt with 'pdftotext'.

vii.) proc_prose
A Perl script to convert our PDFs to CSVs.
