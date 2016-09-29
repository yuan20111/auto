#!/bin/bash

#TODAY=`date +%Y%m%d%H%M%S`
#DAY_1_AGO=`date -d "$TODAY 1 days ago" +%Y%m%d`

read -p "输入你定时的时间(格式为时:分:秒):" ntime
#set ntime 15:40:30

while true
echo $?
do
	now=`date +%H:%M:%S`
	echo $now
	sleep 1
	clear
	if [ "$ntime" == "$now" ];then
		for (( i=0;i<10;i++))
		do
			echo -n "*"
			sleep 1
		done
		break
	fi
done

echo
echo "时间到了"
echo $?
