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

vii.) proc_prose.pl
A Perl script to convert our PDFs to CSVs.

viii.) proc_excel.pl

Standardize the Excel spreadsheets to CSVs with the following columns: company_name,high price,low proce,close/average price,previous price,number shares

ix.) get_adjusted_prices.pl

Find share dilution from price list Excel sheets

x.) dilution.csv.bz2

A CSV of the share dilution for each stock over time

xi.)group_actions_by_type_year.pl
Group corporate actions by type (dividend, share split, bonus, rights issue) and year.

xii.) plot_actions_over_time.pl
Plot the number of corporate actions of each type over the last 15 years.

xiii.) check_week_corr.pl

Get expected and observed values for the Friday/price correlation

xiv.) friday_observed_expected.csv.bz2

Expected and observed values for the Friday/price correlation in the form: Year,Expected Value,Highest count,2nd-highest count,3rd-highest count,4th-highest count,lowest count.

xv.) calc_chi_square.py

Calculate the Chi-square with scipy.stats for Friday

xvi.) calc_chi_square2.py

Calculate the Chi-square with scipy.stats for Monday

xvii.) check_week_corr2.pl

Get Observed/expected trades for Monday

xviii.) monday_observed_expected.csv.bz2
Expected/Observed trade data for Monday in the format: year,expected value,number highest,number 2nd highest,number 3rd highest, number 4th highest,lowest

xix.) calc_weekday_price_deltas.pl

Calculate the average margin between the average price for the week and the price on each weekday.

xx.) apply_adjustment.pl

Apply price adjustment. Reads the dilution factor from dilution.csv and writes CSVs in the format: stock,high price,low price,average price/closing price,previous price,number shares,corrected price.
The 'corrected price' is determined by: (current number of shares/number of shares in 2001) * current price

xxi.) candle_data.csv.bz2

The difference between the price of a stock on a given day and the average price for the month: ((day's price - average price for the month) / average price for the month) * 100.
The CSV is in the format: day of the month,lowest price seen,lowest price seen,highest price seen,average for the entire period(2001-2017).

xxii.) proc_intra_month_csv.pl

Read the CSV file generated by calc_month_day_deltas.pl and extract four columns: the day of the month, the highest price seen, the lowest price seen and the average for the entire period.

xxiii.) candle_plot.gnuplot

A gnuplot command script to generate the candlestick plot

xxiv.) calc_month_day_deltas.pl

Generate data on the difference between the average stock price for the month and the price on each month day.

xxv.) Intra_month_returns.csv.bz2

The data file generated by calc_month_day_deltas.pl + some additional data created through LibreOffice Calc.


