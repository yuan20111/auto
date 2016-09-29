#!/bin/bash
log="/var/log/logs4" #s4 log position
rtcwake_time=90 #rtcwake time
sleep_time=20
touch $log
chmod 777 $log
NUM=$1
if [ "x$1x" = "xx" ]
then 
	echo "error : 请输入要休眠的次数 ........ "
	exit 1
fi
echo "系统将 进行 休眠  $1 次"
#这条测试S4挂起到磁盘

while [ $NUM -gt 0 ]
do
	cnum=`expr $1 - $NUM + 1`
	sync
	sync
	sleep $sleep_time
	echo "这将进行  第 $cnum 次, `date`"
	echo "这将进行  第 $cnum 次, `date`" >> $log
	rtcwake -m no -s $rtcwake_time
	pm-hibernate #MODIFY
	NUM=`expr $NUM - 1`
done

exit 0
