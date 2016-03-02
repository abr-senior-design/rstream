#!/bin/bash/

COUNTER=3
TYPE=(basic, smart, netflix, bandwidth, lowest, highest)
until [ $COUNTER -lt 0 ]; do
    python dash_client.py -p ${TYPE[COUNTER % 4]} &
    sleep 2s
    let COUNTER-=1
done
