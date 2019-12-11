#!/bin/bash
# set -x

if [ $# -ne 1 ]; then
    echo "**USAGE** $0 process_name"
else
    name=$1
fi

psret=$(ps -ef | grep $name | grep -v grep | grep -v killall | awk '{print $2}')

echo $psret

sudo kill -9 $psret
