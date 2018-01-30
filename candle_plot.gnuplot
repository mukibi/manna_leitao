set terminal png size 1000,1000;
set output 'month_day.png';
set title 'Day of Month Returns';
set xlabel 'Year';
set ylabel 'Return Delta %';
set xrange [2001:2017];
set yrange [*:*];
set ytics;
set grid ytics;
set grid xtics;
set tmargin at screen 0.9;
set bmargin at screen 0.1;
set rmargin at screen 0.98;
set lmargin at screen 0.08;
set datafile separator ',';
plot 'candle_data.csv' using 1:2:4:3:5 notitle with candlesticks;

