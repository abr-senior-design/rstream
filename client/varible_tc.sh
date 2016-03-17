#!/bin/bash

MAX_BANDWIDTH=$1
MIN_BANDWIDTH=$2

if [ "$#" -ne 2 ]; then
	echo "Incorrect usage."
	echo "./throlle.sh <max_bandwidth> <min_bandwidth>"
	exit 1
fi

HI=$MAX_BANDWIDTH
MOD=$((MAX_BANDWIDTH / 4))
MOD1=$((MOD / 2))

TEMP=0

function switch_rate() {
    NUM1=$((RANDOM % MOD))
    NUM2=$((NUM1 - MOD1))

    TEMP=$((HI + NUM2))

    while [ $TEMP -gt $MAX_BANDWIDTH -o $TEMP -lt $MIN_BANDWIDTH ]; do
        NUM1=$((RANDOM % MOD))
        NUM2=$((NUM1 - MOD1))

        TEMP=$((HI + NUM2))
	echo $TEMP
    done

    HI=$TEMP;
}
FILE=ASTREAM_LOGS/limit_bandwidth_8.csv

touch $FILE

START="$(date +%s)"
HI_S=$HI"kbps"

echo $HI_S

    sudo tc qdisc del dev lo root
    sudo tc qdisc add dev lo root handle 1: htb default 12
    sudo tc class add dev lo parent 1:1 classid 1:12 htb rate $HI_S

DIFF="$(date +%s)"

echo $DIFF >> $FILE

DIFF=$((DIFF - START))

echo $DIFF,$HI >> $FILE

while true; do

    switch_rate  
  
    HI_S=$HI"kbps"

    #echo $HI_S

    sudo tc class replace dev lo parent 1:1 classid 1:12 htb rate $HI_S
    tc class show dev lo

    DIFF="$(date +%s)"
    DIFF=$((DIFF - START))

    echo $DIFF,$HI >> $FILE

    sleep 1s
#tc qdisc add dev lo parent 1:12 netem delay 200ms
#don't really need latency, just bandwidth reduction

done

