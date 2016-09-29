#!/bin/bash
echo  ""
echo  "请问，这是未破坏现场的本机终端里吗? ［y/n］\c"
read answer

function get_log ()
{
	if [ "y" = "$answer" ]
	then
		#运行时间和平均负载
		uptime  > uptime.txt

		#内存信息
		free    > free.txt

		#进程信息
		pstree  > pstree.txt
		ps -aux > ps.txt

		{
			sleep 2
			pkill top
		} &
		top > top.txt

		sudo tar -czvf log.tar.gz free.txt uptime.txt ps.txt pstree.txt top.txt /var/log
		sudo  rm free.txt uptime.txt ps.txt pstree.txt top.txt

		#生成md5
		md5sum  log.tar.gz > log.tar.gz.md5

	elif [ "n" = "$answer" ]
	then
		sudo tar -czvf  log.tar.gz /var/log
		md5sum  log.tar.gz > log.tar.gz.md5
	fi
}
get_log
