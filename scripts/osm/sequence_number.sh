#!/bin/bash

# $1 as --hour or --minute, $2 as timestamp
# return the latest sequence number

case $1 in
    # hour difference with Tue Jun 4 03:00:00 UTC 2019
    # sequence number=58940
    --hour)
    echo $[($2 - 1559617200)/3600 + 58940]
    ;;

    # minute difference with latest planet state file
    --minute)
    benchmark=benchmark
    curl https://planet.openstreetmap.org/replication/minute/state > $benchmark
    timeString=$(tail -1 $benchmark | tr -d 'timestamp=\\')
    timestamp=$(date -d "$timeString" +%s)
    seq=$(sed -n 2p $benchmark | tr -d "sequenceNumber=")
    rm $benchmark
    echo $[$seq - ($timestamp - $2)/60 - 1 ]
esac
