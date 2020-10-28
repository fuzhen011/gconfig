#!/bin/bash

# Get the path of the script file (its own path)
sh_path=$(
    cd $(dirname $0)
    pwd
)
gdb_log_file=gdb_log.txt
JLinkGDBServer_log_file=JLinkServerLog.txt
# Enable the job control otherwise the JLinkGDBServer process will be killed
# when sending CTRL+C to interrupt gdb
set -m
gdb_log_path=$sh_path/log/$gdb_log_file
gdbsv_log_path=$sh_path/log/$JLinkGDBServer_log_file

dev=STM32F103CB

nohup JLinkGDBServer -device $dev -endian little -if SWD -select usb=30000299 -log $gdb_log_path >$gdbsv_log_path 2>&1 &
GDBServer_PID=$!

echo "***********************************"
echo "* JLinkGDBServer PID = $GDBServer_PID      *"
echo "***********************************"
arm_gdb_exe=arm-none-eabi-gdb-py
$arm_gdb_exe -q --nh -iex "source $PATH_MY_SCRIPT/gdb/.gdbinit_arm" "$1" -ex "tar rem :2331"
# Clear
pid=$(ps -ef | grep $GDBServer_PID | grep -v "grep" | awk '{print $2}')
if [[ "" != $pid ]]; then
    kill -9 $GDBServer_PID
fi

exit 0
