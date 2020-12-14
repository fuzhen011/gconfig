#!/bin/bash

# *****************************************************************
#
# *****************************************************************

# *****************************************************************
# https://www.segger.com/products/debug-probes/j-link/technology/cpus-and-devices/overview-of-supported-cpus-and-devices/#DeviceList
# https://www.segger.com/downloads/supported-devices.php
#
# Supported device list:
# BGM111A256V2 BGM113A256V2
# EFR32BG12PxxxF1024 EFR32BG13PxxxF512 EFR32BG1PxxxF256
# EFR32BG21AxxxF1024 EFR32BG21BxxxF1024
# EFR32BG21AxxxF768 EFR32BG21BxxxF768
# EFR32BG21AxxxF512 EFR32BG21BxxxF512
# EFR32MG21AxxxF1024 EFR32MG21MxxxF1024
# EFR32MG21AxxxF768 EFR32MG21MxxxF768
# EFR32MG21AxxxF512 EFR32MG21MxxxF512
#
# EFR32BG22CxxxF352 EFR32BG22CxxxF512
# EFR32MG22CxxxF352 EFR32MG22CxxxF512
# *****************************************************************

# *****************************************************************
# Example: gb.sh 440053190 xxx.axf
# sn=440053190, pro_name=gateway
# *****************************************************************

os_name=$(uname -v)
gdb_log_file=gdb_log.txt
JLinkGDBServer_log_file=JLinkServerLog.txt
speed=8000
reflash=0

if [ $# -eq 2 ]; then
    sn=$1
    elf_path=$2
elif [ $# -eq 3 ]; then
    sn=$1
    elf_path=$2
    reflash=$3
elif [ $# -eq 4 ]; then
    sn=$1
    elf_path=$2
    reflash=$3
    dev=$4
else
    echo "**USAGE**: $0 [JLink Serial Number] [ELF/AXF FILE Path] [Erase & Flash](Optional)"
    echo "************************************************************************************"
    echo "Help: This script will use JLink GDB Server to connect to the device with serial   *"
    echo "number @{param1}, then use arm-none-eabi-gdb to load the file @{param2} to debug   *"
    echo "the target remotely. The third parameter @{param3} is optional, if present, any    *"
    echo "value great than 1 will erase and flash the device before debugging, value 1 will  *"
    echo "only flash the device without mass erase.                                          *"
    echo "************************************************************************************"
    exit 2
fi

if [[ $os_name =~ 'Darwin' || $os_name =~ 'Ubuntu' ]]; then
    echo "Current platform is ***MacOS Or Ubuntu***"
    suffix=""
# elif [[ $os_name =~ 'Microsoft' ]]; then
else
    echo "Current platform is ***WSL Or MSYS2***"
    suffix=".exe"
fi

JLinkGDBServer_exe="JLinkGDBServer${suffix}"

# Specify the gdb executable, use the one ends with py to enable the python script [GEF]
# arm_gdb_exe=arm-none-eabi-gdb
arm_gdb_exe=arm-none-eabi-gdb-py
# arm_gdb_exe=/home/zhfu/Downloads/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-gdb
# arm_gdb_exe=/home/zhfu/work/SimplicityStudio_v4/developer/toolchains/gnu_arm/7.2_2017q4/bin/arm-none-eabi-gdb

# use PATH_COMMANDER env var to override default path for Simplicity Commander
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

if [ ! -f "$elf_path" ]; then
    echo "**WONNG** Parameter: $elf_path FILE Doesn't Exit!"
    exit 2
elif [[ "$elf_path" == *elf* ]]; then
    bin_file=$(echo "${elf_path}" | sed "s/\.elf/\.hex/g")
elif [[ "$elf_path" == *axf* ]]; then
    bin_file=$(echo "${elf_path}" | sed "s/\.axf/\.hex/g")
else
    echo "FILE with **Wrong** Extension"
fi

# If not specified the part number, try detecting it from commander info
if [ $# -ne 4 ]; then
    cmd_out=$("${COMMANDER}" device info -s $sn)
    if [[ $cmd_out =~ 'ERROR' ]]; then
        echo "WRONG JLink Serial Number Given [$sn]"
        exit 1
    fi
    # From the commander device info -s ${Serial Number} to get the input of device
    # parameter for JLink GDB Server
    dev=$(echo ${cmd_out} | awk '{print $4}' | sed "s/P[0-9]*F/PxxxF/g" | sed "s/A[0-9]*F/AxxxF/g" | sed "s/[GI][ML][0-9]*//g" | sed "s/B[0-9]*F/BxxxF/g" )
fi
echo "Device - ${dev}"

# Get the path of the script file (its own path)
sh_path=$(
    cd $(dirname $0)
    pwd
)

# Enable the job control otherwise the JLinkGDBServer process will be killed
# when sending CTRL+C to interrupt gdb
set -m

mkdir -p $sh_path/log
echo "******************************************************************************************"
echo ${dev}
echo "GDBServer Output will be written to |--> $sh_path/log/$JLinkGDBServer_log_file"
echo "GDB log will be written to          |--> $sh_path/log/$gdb_log_file"
echo "View LOG -> 'tail -200f \${FILE_PATH}'"
echo "******************************************************************************************"

gdb_log_path=$sh_path/log/$gdb_log_file
gdbsv_log_path=$sh_path/log/$JLinkGDBServer_log_file

if [ $reflash -gt 1 ]; then
    "${COMMANDER}" device masserase -s $sn
    "${COMMANDER}" flash "$bin_file" -s $sn
elif [ $reflash -eq 1 ]; then
    "${COMMANDER}" flash "$bin_file" -s $sn
fi

nohup JLinkGDBServer -device $dev -endian little -if SWD -select usb=$sn -speed $speed -log $gdb_log_path >$gdbsv_log_path 2>&1 &
GDBServer_PID=$!
echo "***********************************"
echo "* JLinkGDBServer PID = $GDBServer_PID      *"
echo "***********************************"
$arm_gdb_exe -q --nh -iex "source $PATH_MY_SCRIPT/gdb/.gdbinit_arm" "$elf_path" -ex "tar rem :2331"
# Clear
pid=$(ps -ef | grep $GDBServer_PID | grep -v "grep" | awk '{print $2}')
if [[ "" != $pid ]]; then
    kill -9 $GDBServer_PID
fi

exit 0
