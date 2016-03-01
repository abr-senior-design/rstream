#!/bin/bash

gnuplot <<- EOF
    set xlabel "EpochTime"
    set ylabel "Bitrate"
    set term png
    set output "sample.png"
    set datafile separator ","
    plot "sample.csv" using 1:6 with lines
EOF
