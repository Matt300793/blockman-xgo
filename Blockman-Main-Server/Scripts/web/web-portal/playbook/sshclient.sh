#!/bin/bash

if [ $# -lt 1 ]; then 
    echo "Usage $0 SERVICE_NAME [-l]"
    echo "ssh connect to service host, if the target you selected host exist"
    echo ""
    echo "optional arguments:"
    echo "-l, --tail-log=TAIL-LOG    tail service log from the remote host"
    echo ""
    exit 1
fi

./deployer.py ssh -s $1
if [[ $? == 0 ]]; then
    host=`cat .selected_host`

    if [ $2 == "-l" -o $2 == "--tail-log" ]; then
        ssh deploy@$host tail -100f /home/deploy/logs/supervisor/$1.log
    else
        ssh deploy@$host
    fi
fi