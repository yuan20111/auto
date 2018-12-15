#!/bin/bash
log="/var/log/logs3"
rtcwake_time=90 #休眠到唤醒的间隔时间
sleep_time=20	#唤醒之后到下一次s3的间隔时间
touch $log
chmod 777 $log
NUM=$1
if [ "x$1x" = "xx" ]
then 
	echo "error : 请输入要挂起的次数 ........ "
	exit 1
fi
echo "系统将 进行 挂起  $1 次"
#这条测试S3挂起到磁盘

while [ $NUM -gt 0 ]
do
	cnum=`expr $1 - $NUM + 1`
	sync
	sync
	sleep $sleep_time
	echo "这将进行  第 $cnum 次, `date`" 
	echo "这将进行  第 $cnum 次, `date`" >>$log
	rtcwake -m no -s $rtcwake_time
	pm-suspend #MODIFY
	NUM=`expr $NUM - 1`
done

exit 0
