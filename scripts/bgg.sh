#!/bin/bash
# bggrep - grep key word in the bg repo

bg_stack_loc=/home/zhfu/work/super/protocol/bluetooth

if [ $# -eq 1 ];then
	grep -r -n $1 $bg_stack_loc | grep -v Binary | grep -v ncp_mesh
else
	echo "Usage: $0 word_to_grep"
	exit 1
fi
