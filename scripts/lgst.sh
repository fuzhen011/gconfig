#!/bin/bash

sn=68000009
cmd_jlink=JLinkExe
dev=STM32F103CB
port=8351

# nohup $cmd_jlink -autoconnect 1 -Device $dev -If JTAG -jtagconf -1,-1 -speed 4000 -SelectEmuBySN $sn -RTTTelnetPort $port >/dev/null 2>&1 &
nohup $cmd_jlink -autoconnect 1 -Device $dev -If SWD -speed 4000 -SelectEmuBySN $sn -RTTTelnetPort $port >/dev/null 2>&1 &
jlink_pid=$!
sleep 1
echo "***********************************"
echo "* JLink PID = $jlink_pid           *"
echo "* RTT to 127.0.0.1, PORT = $port  *"
echo "***********************************"
telnet 127.0.0.1 $port

# Clear
pid=$(ps -ef | grep $jlink_pid | grep -v "grep" | awk '{print $2}')
if [[ "" != $pid ]]; then
    kill -9 $jlink_pid
fi
