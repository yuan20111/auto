#!/bin/bash  

flags=1

while [ 1 ];do

viewperfguiip=`ps -ef | grep "viewperf-gui" | grep -v grep | awk '{print $2}'`
{
	sleep 2
	pkill top 
} & 
top > speviewperftop-$flags.log
date >> speviewperftop-$flags.log

date >speviewperf-mem-$flags.log
cat /proc/$viewperfguiip/status >speviewperf-mem-$flags.log

date >speviewperf-free-$flags.log
free -h >speviewperf-free-$flags.log
echo "--------------------------------------------------------------" >> speviewperf-free-$flags.log
free >> speviewperf-free-$flags.log
sleep 7200
let flags=flags+1
done
