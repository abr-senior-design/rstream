#!/bin/bash

MAXIMUM_BADWIDTH=18000
MINIMUM_BANDWIDTH=0

LO=$MINIMUM_BANDWIDTH
HI=18000
NUM=$((RANDOM % $((18000/2)) ))
NUM=$((NUM - $((18000/4)) ))

TEMP=0

switch_rate() {
    MOD=$((18000 / 2))
    NUM=$((RANDOM % MOD ))
    MOD=$((MOD / 2))
    NUM=$((NUM - MOD ))

    TEMP=$((HI + NUM))

    while [ $TEMP -gt 18000 -a $TEMP -lt 0 ]; do
        NUM=$((RANDOM % $(( 18000 /2)) ))
        NUM=$((NUM - $(( 18000 /4)) ))

        TEMP=$((HI + NUM))
    done

    HI=$TEMP;
}
FILE=ASTREAM_LOGS/limit_bandwidth.csv

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

    MOD=$((18000 / 2))
    NUM=$((RANDOM % MOD ))
    MOD=$((MOD / 2))
    NUM=$((NUM - MOD ))

    TEMP=$((HI + NUM))

    while [ $TEMP -gt 18000 -o $TEMP -lt 0 ]; do
        NUM=$((RANDOM % $(( 18000 /2)) ))
        NUM=$((NUM - $(( 18000 /4)) ))

        TEMP=$((HI + NUM))
    done

    HI=$TEMP

    sudo tc class replace dev lo parent 1:1 classid 1:12 htb rate $HI_S

    DIFF="$(date +%s)"
    DIFF=$((DIFF - START))

    echo $DIFF,$HI >> $FILE

    sleep 1s
#tc qdisc add dev lo parent 1:12 netem delay 200ms
#don't really need latency, just bandwidth reduction

done

