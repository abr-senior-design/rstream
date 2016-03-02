#!/bin/bash

for FILE in ASTREAM_LOGS/*[0-9].csv; do
    START=0
    END=30
    BASE="$(echo $FILE | rev | cut -c 5- | rev)"
    NEWFILE=$BASE.bandwidth.csv
    touch $NEWFILE
    while true; do
       OUT="$(cat $FILE | awk -F "," ' $1 >= '"$START"' && $1 <= '"$END")"
       if [ -z "$OUT"  ]; then
           break
       fi

       MID=$((START+END))
       MID=$((MID/2))

       COUNTER="$(echo $OUT | grep -c ',BUFFERING,' $FILE)"

       echo $MID,$COUNTER >> $NEWFILE

       START=$((START+30))
       END=$((END+30))
    done

    gnuplot <<- EOF
        set xlabel "Epoch Time"
        set ylabel "Average rebuffering per 30 seconds"
        set datafile separator ","
        set output "$BASE.bandwidth.png"
        plot "$NEWFILE" using 0:1 with lines
EOF
done
