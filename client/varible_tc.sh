#!/bin/bash

MAXIMUM_BADWIDTH=19
MINIMUM_BANDWIDTH=0

HI=19
NUM=$((RANDOM % $((19/2)) ))
NUM=$((NUM - $((19/4)) ))

TEMP=0

switch_rate() {
    MOD=$((19 / 2))
    NUM=$((RANDOM % MOD ))
    MOD=$((MOD / 2))
    NUM=$((NUM - MOD ))

    TEMP=$((HI + NUM))

    while [ $TEMP -gt 19 -a $TEMP -lt 0 ]; do
        NUM=$((RANDOM % $(( 19 /2)) ))
        NUM=$((NUM - $(( 19 /4)) ))

        TEMP=$((HI + NUM))
    done

    HI=$TEMP;
}
FILE=ASTREAM_LOGS/limit_bandwidth.csv

touch $FILE

START="$(date +%s)"
HI_S=$HI"Mbps"

echo $HI_S

    sudo tc qdisc del dev lo root

    sudo tc qdisc add dev lo root handle 1: htb default 12
    sudo tc class add dev lo parent 1:1 classid 1:12 htb rate $HI_S

DIFF="$(date +%s)"

echo $DIFF >> $FILE

DIFF=$((DIFF - START))

echo $DIFF,$HI >> $FILE

while true; do

    MOD=$((19 / 2))
    NUM=$((RANDOM % MOD ))
    MOD=$((MOD / 2))
    NUM=$((NUM - MOD ))

    TEMP=$((HI + NUM))

    while [ $TEMP -gt 19 -o $TEMP -lt 0 ]; do
        NUM=$((RANDOM % $(( 19 /2)) ))
        NUM=$((NUM - $(( 19 /4)) ))

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

