#!/bin/bash
set -v

if [ "$#" -ne 2 ]; then
	echo "Incorrect usage."
	echo "Try ./throlle.sh <bandwidth> <latency>"
	exit 1
fi

#Remove the current rules
sudo tc qdisc del dev lo root

#Add new rules
sudo tc qdisc add dev lo root handle 1: htb default 12
sudo tc class add dev lo parent 1:1 classid 1:12 htb rate $1
sudo tc qdisc add dev lo parent 1:12 netem delay $2
