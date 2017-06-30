#!/bin/bash

if [ "$(whoami)" != "root" ] ;then 
	echo "[Permission denied] Usage: sudo $0"
	exit -1
fi

NAME=`lsb_release -d | awk -F : '{print $2}'`
NAME=`echo $NAME`
time=`uname -v` 

cpu=`grep "model name" /proc/cpuinfo | head -1 | awk -F : '{print $2}'`
mem=`free -h | grep Mem | awk '{print $2}'`
MEM=`echo ${mem%G}`
MEM=`echo $((${MEM//.*/+1}))`
hostname=`dmidecode | grep "Product Name" | head -1| awk -F : '{print $2}'`

SerialNo=`hdparm -i /dev/sda | grep SerialNo | awk -F "SerialNo=" '{print $2}'`
SIZE=`df -kl|awk '{print $2,$3}'|sed '1d'|awk '{sum += $1};END {print sum}'`
IP=`ifconfig |  grep "192.168" | awk '{print $2}'| awk -F : '{print $2}'`
MAC=`ifconfig  | head -1 | awk '{print $5}'`
#SIZE=`df --total | grep total | awk '{print $2}'`


pan=`df -h | grep /dev/sda | awk '{print $1}'`
utime=`tune2fs -l $pan | grep creat`
utime=`echo $utime | awk -F "created:" '{print $2}'`
let SIZE=SIZE/1000/1000
HSIZE=`fdisk -l 2>/devnull| head -n 2 | grep Disk | awk '{print $3 $4}'| awk -F, '{print $1}' `


###############
x=`xrandr | grep mm | awk -F ")" '{print $2}' | awk -F mm '{print $1}'`
y=`xrandr | grep mm | awk -F ")" '{print $2}' | awk '{print $3}'`
y=${y%mm}

let "z=x*x+y*y"
z=`echo "sqrt($z)" | bc` 
z=$(echo "$z/25.4+1" | bc) 
#echo $x mm $y mm  $z 

echo "######## 您的计算机基本信息如下  ###########"
echo ""
echo "操作系统名称    ： $NAME"
#echo "操作系统生成时间：$time"
echo "操作系统安装时间：$utime"
echo ""
echo "规格/型号       ：${hostname}"
echo "cpu型号         : $cpu"
echo "内存            :  ${MEM}G"
echo "实际使用内存    :  $mem"
echo "硬盘序列号      ： $SerialNo"
echo "当前硬盘分区大小： ${SIZE}G  "
echo "硬盘总大小      ： $HSIZE "
echo "IP 地址         ： $IP"
echo "MAC硬件地址     ： $MAC"
echo "屏幕尺寸        :  $z 英寸"
echo ""
