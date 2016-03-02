#!/bin/bash/
COUNTER=3
TYPE=(basic smart netflix bandwidth lowest highest)

touch time_start.csv 
TIME="$(date +%s)"
echo $TIME,${TYPE[$((COUNTER % 6))]} >> time_start.csv 

until [ $COUNTER -lt 0 ]; do
    python dash_client.py -p ${TYPE[COUNTER % 6]} &
    sleep 1s
    let COUNTER-=1
done

wait

#pkill -f variable_tc.sh

#sudo tc qdisc del dev lo root
