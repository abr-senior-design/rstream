#!/bin/bash

MAXIMUM_BADWIDTH=18000
MINIMUM_BANDWIDTH=0

$LO=$MINIMUM_BANDWIDTH
$HI=$MAXIMUM_BANDWIDTH
$NUM=$((RANDOM % $((MAXIMUM_BANDWIDTH/2)) ))
$NUM=$((NUM - $((MAXIMUM_BANDWIDTH/4)) ))

$TEMP=0

switch_rate() {
    $NUM=$((RANDOM % $((MAXIMUM_BANDWIDTH/2)) ))
    $NUM=$((NUM - $((MAXIMUM_BANDWIDTH/4)) ))

    $TEMP=$((HIGH + NUM))

    while [ $TEMP -gt $MAXIMUM_BANDWIDTH || $TEMP -lt $MINIMUM_BANDWIDTH ]; do
        $NUM=$((RANDOM % $((MAXIMUM_BANDWIDTH/2)) ))
        $NUM=$((NUM - $((MAXIMUM_BANDWIDTH/4)) ))

        $TEMP=$((HIGH + NUM))
    done

    $HIGH=$TEMP;

}

$FILE=ASTREAM_LOGS/limit_bandwidth.csv

touch $FILE

$START="$(date +%s)"

sudo tc qdisc add dev lo root handle 1: htb default 12
sudo tc class add dev lo parent 1:1 classid 1:12 htb rate $LO_S ceil $HIGH_S

$DIFF="$(date +%s)"
$DIFF=$((DIFF - START))

echo $DIFF,$HI >> $FILE

while true; do

    switch_rate

    sudo tc qdisc change dev lo root handle 1: htb default 12
    sudo tc class change dev lo parent 1:1 classid 1:12 htb rate $LO_S ceil $HIGH_S

    $DIFF="$(date +%s)"
    $DIFF=$((DIFF - START))

    echo $DIFF,$HI >> $FILE

    sleep 4s
#tc qdisc add dev lo parent 1:12 netem delay 200ms
#don't really need latency, just bandwidth reduction

done

