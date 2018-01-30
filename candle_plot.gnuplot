set terminal png size 1000,1000;
set output 'month_day.png';
set title 'Day of Month Returns';
set xlabel 'Day of the Month';
set ylabel 'Return Delta';
set xrange [1:31];
set yrange [-10:10];
set ytics;
set grid ytics;
set grid xtics;
set tmargin at screen 0.9;
set bmargin at screen 0.1;
set rmargin at screen 0.98;
set lmargin at screen 0.08;
set datafile separator ',';
plot 'candle_data.csv' using 1:2:3:4:5 notitle with candlesticks;

