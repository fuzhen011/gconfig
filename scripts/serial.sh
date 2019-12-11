#!/bin/bash

if [ $# -eq 1 ]; then
    sn=$1
else
    echo "Usage: $0 serial_no"
fi

os_name=$(uname -v)

if [[ $os_name =~ 'Ubuntu' ]]; then
    acm_no=$(id_acm.sh $sn)
elif [[ $os_name =~ 'Darwin' ]]; then
    echo "NEED TO FINISH ON MACOS"
    exit 1
fi

minicom -c on -D $acm_no
