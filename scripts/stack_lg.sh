#!/bin/bash

set -m
speed=8000

if [ $# -eq 1 ]; then
    sn=$1
else
    echo "Usage: $0 SN"
    exit 1
fi

os_name=$(uname -v)
if [[ $os_name =~ 'Darwin' || $os_name =~ 'Ubuntu' ]]; then
    jlink_logger=JLinkRTTLogger
elif [[ $os_name =~ 'Microsoft' ]]; then
    jlink_logger=JLinkRTTLogger.exe
else
    echo "Current platform is ***MSYS2***"
fi

if [[ -z ${PATH_COMMANDER} ]]; then
    COMMANDER="/Applications/Simplicity Studio.app/Contents/Eclipse/developer/adapter_packs/commander/Commander.app/Contents/MacOS/commander"
else
    COMMANDER="${PATH_COMMANDER}/commander${suffix}"
fi

if [[ ! -f "${COMMANDER}" ]]; then
    echo "Error: Simplicity Commander not found at '${COMMANDER}'"
    echo "Use PATH_COMMANDER env var to override default path for Simplicity Commander."
    exit 1
fi

cmd_out=$("${COMMANDER}" device info -s $sn)
# echo "$cmd_out"
if [[ $cmd_out =~ 'ERROR' ]]; then
    echo "WRONG JLink Serial Number Given"
    exit 1
fi

# From the commander device info -s ${Serial Number} to get the input of device
# parameter for JLink GDB Server
# dev=$(echo ${cmd_out} | awk '{print $4}' | sed "s/P[0-9]*F/PxxxF/g" | sed "s/[GI][ML][0-9]*//g")
dev=$(echo ${cmd_out} | awk '{print $4}' | sed "s/P[0-9]*F/PxxxF/g" | sed "s/A[0-9]*F/AxxxF/g" | sed "s/[GI][ML][0-9]*//g")
# echo "$dev"

time=`date "+%Y-%m-%d-%H:%M:%S"`
log_file_path="$HOME/work/logs/rtt_logger/$time.log"
echo "* *********************************************************************************"
echo "* View Log:  tail -500F $log_file_path *"
echo "* *********************************************************************************"

$jlink_logger -Device $dev -If SWD -speed $speed -SelectEmuBySN $sn $log_file_path

# $jlink_logger -Device $dev -If SWD -speed $speed -SelectEmuBySN $sn $log_file_path
