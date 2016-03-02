#!/bin/bash/

#bash variable_tc.sh &

COUNTER=3
TYPE=(basic, smart, netflix, bandwidth, lowest, highest)
until [ $COUNTER -lt 0 ]; do
    python dash_client.py -p ${TYPE[COUNTER % 6]} &
    sleep 1s
    let COUNTER-=1
done

wait
#pkill -f variable_tc.sh

#sudo tc qdisc del dev lo root
