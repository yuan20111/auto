#!/bin/bash

for((i=1;i<=255;i++));

do
	if [ ! -n "`ping 192.168.7.${i} -i 0.2 -c 1 | grep error`" ]; then
		    echo 通 192.168.7.$i
		    echo 通 192.168.7.$i >> `pwd`/ip-exist-info.txt
	  else
		    echo 空ip 192.168.7.$i 
		    echo 空ip 192.168.7.$i  >> `pwd`/ip-null-info.txt
	fi 


done
