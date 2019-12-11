#!/bin/bash
 
if [ $# -eq 1 ]; then
	sn=$1
else
	sn=440034833
fi

dev_count=`ls /dev/ttyACM* | wc -l`
# echo "dev_count = ${dev_count}"

dev=1
while(( $dev<=$dev_count ))
do
	ret=`ls /dev/ttyACM* | awk "NR==$dev{print}" | xargs udevadm info -a --name | grep $sn`
	if [ $ret ]; then
		echo `ls /dev/ttyACM* | awk "NR==$dev{print}"`
		break
	fi
	let "dev++"
done
