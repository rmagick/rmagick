set datafile separator ","

set key outside center top horizontal reverse Left samplen 2
unset border
set xtics scale 0
set ytics scale 0
set grid ytics linewidth 1 linetype -1

set style line 1 lt 1 lc rgbcolor "#3465a4" lw 2.5 pt 7 ps 1
set style line 2 lt 1 lc rgbcolor "#ff6347" lw 2.5 pt 7 ps 1
set style line 3 lt 1 lc rgbcolor "#888a85" lw 2.5 pt 5 ps 1

set xlabel "Nth loop"
set ylabel "Memory usage (MiB)"

plot "before.csv" with line linestyle 1, "after.csv" with line linestyle 2
