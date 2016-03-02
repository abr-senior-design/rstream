#!/bin/bash/
COUNTER=5
TYPE=(basic smart netflix bandwidth lowest highest)

$FILE=ASTREAM_LOGS/time_start.csv
touch $FILE

until [ $COUNTER -lt 0 ]; do
    python dash_client.py -p ${TYPE[COUNTER % 6]} &
    TIME="$(date +%s)"
    echo $TIME,${TYPE[COUNTER]} >> $FILE 
    sleep 1s
    let COUNTER-=1
done

wait

#pkill -f variable_tc.sh

#sudo tc qdisc del dev lo root
