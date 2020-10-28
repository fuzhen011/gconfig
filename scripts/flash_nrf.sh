#!/bin/bash

sn=683439112

if [ $# -eq 1 ]; then
    sn=$1
fi

echo "Flashing $sn **************************************"
nrfjprog -e -f NRF52 -s $sn && nrfjprog --program build/zephyr/zephyr.hex -f NRF52 -s $sn && nrfjprog --reset -f NRF52 -s $sn
echo "Done... **************************************"
