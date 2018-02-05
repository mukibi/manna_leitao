set terminal png size 1000,1000;
set output 'month.png';
set title 'Day of Month Returns';
set xlabel 'Month';
set ylabel 'Return Delta';
set xrange [1:12];
set yrange [-40:+40];
set ytics;
set grid ytics;
set grid xtics;
set tmargin at screen 0.9;
set bmargin at screen 0.1;
set rmargin at screen 0.98;
set lmargin at screen 0.08;
set datafile separator ',';
plot 'candle_data2.csv' using 1:2:3:4:5 notitle with candlesticks;

