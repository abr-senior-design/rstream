#!/bin/bash

gnuplot <<- EOF
    set xlabel "Epoch Time"
    set ylabel "Bitrate"
    set datafile separator ","
  	set term png size 1080,512
    set output "Bitrate.png"
    set title "Chosen Bitrate"
    plot "limit_bandwidth.csv" using (\$1 <= 100 && \$1 >= 15 ? \$2 : 1/0) with lines title "Bandwidth Limiter", \
        "lowest1.csv" using (\$0 + 15):6 with lines title "Lowest 1", \
        "Bandwidth1.csv" using (\$0 + 16):6 with lines title "Bandwidth 1", \
        "Netflix1.csv" using (\$0 + 17):6 with lines title "Netflix 1", \
        "smart1.csv" using (\$0 + 18):6 with lines title "Smart 1", \
        "basic1.csv" using (\$0 + 19):6 with lines title "Basic 1", \
        "highest1.csv" using (\$0 + 20):6 with lines title "Highest 1", \
        "lowest2.csv" using (\$0 + 21):6 with lines title "Lowest 2", \
        "bandwidth2.csv" using (\$0 + 22):6 with lines title "Bandwidth 2", \
        "smart2.csv" using (\$0 + 24):6 with lines title "Smart 2", \
        "basic2.csv" using (\$0 + 25):6 with lines title "Basic 2"

EOF
