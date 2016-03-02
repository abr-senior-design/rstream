#!/bin/bash

INPUT=limit_bandwidth.csv

FILE=ASTREAM_LOGS/limit_bandwidth.csv

touch $FILE

START="$(date +%s)"

sudo tc qdisc del dev lo root

sudo tc qdisc add dev lo root handle 1: htb default 12
sudo tc class add dev lo parent 1:1 classid 1:12 htb rate 20Mbps 

OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read epchtm bndwth
do
    echo "Bandwidth is: $bndwth"
    sudo tc class replace dev lo parent 1:1 classid 1:12 htb rate $bndwth"MBps"


    DIFF="$(date +%s)"
    DIFF=$((DIFF - START))

    echo $DIFF,$bndwth >> $FILE

    sleep 1s
done < $INPUT
IFS=$OLDIFS

