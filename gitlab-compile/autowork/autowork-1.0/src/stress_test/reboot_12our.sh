#!/bin/bash
#Author:ShangJun

export LANG="zh_CN.UTF-8"
p=$(pwd)
pw="/home/tmpf"
if [ ! -e $pw ];then
	echo $p >$pw
else
	p=$(cat $pw)
fi
base=$(basename $0)
file="$p/$base"
tmpfile="$p/tmp"
t=`date +%s`
if ! grep "$base" /etc/rc.local >/dev/null;then
	sed -i '$ i sh '$file'' /etc/rc.local
fi
if [ `grep "timeout=-1" /boot/grub/grub.cfg | wc -l` -eq 2 ];then
	sed -i '81s/timeout=-1/timeout=0/' /boot/grub/grub.cfg
fi
#set -d "10 min" or "1 hour"
[ ! -e $tmpfile ] &&  echo `date +%s -d "12 hour"` >$tmpfile
c=`cat $tmpfile`
if [ $t -lt $c ];then
	sleep 120
	echo "reboot `date`" >> /var/log/reboot.log
	reboot
else
	rm -f $pw
	rm -f $tmpfile
	if grep "$base" /etc/rc.local >/dev/null;then
		sed -i '/'$base'/d' /etc/rc.local
	fi
fi
