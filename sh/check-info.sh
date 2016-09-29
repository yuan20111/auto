#!/bin/bash
time=`uname -v` 
pan=`df -h | grep /dev/sda | awk '{print $1}'`
utime=`tune2fs -l $pan | grep creat`

cpu=`grep "model name" /proc/cpuinfo | head -1 | awk -F : '{print $2}'`
mem=`free -h | grep Mem | awk '{print $2}'`
hostname=`dmidecode | grep "Product Name" | head -1| awk -F : '{print $2}'`

SerialNo=`hdparm -i /dev/sda | grep SerialNo | awk -F "SerialNo=" '{print $2}'`
SIZE=`df -kl|awk '{print $2,$3}'|sed '1d'|awk '{sum += $1};END {print sum}'`
IP=`ifconfig |  grep "192.168" | awk '{print $2}'`
MAC=`ifconfig | grep eth0 | awk '{print $5}'`
#SIZE=`df --total | grep total | awk '{print $2}'`


utime=${utime#*created:}
let SIZE=SIZE/1000/1000
HSIZE=`fdisk -l | head -n 2 | grep Disk | awk '{print $3 $4}'| awk -F, '{print $1}'`


###############
x=`xrandr | grep mm | awk -F ")" '{print $2}' | awk -F mm '{print $1}'`
y=`xrandr | grep mm | awk -F ")" '{print $2}' | awk '{print $3}'`
y=${y%mm}

let "z=x*x+y*y"
z=`echo "sqrt($z)" | bc` 
z=$(echo "$z/25.4+1" | bc) 
#echo $x mm $y mm  $z 


echo cpu型号:$cpu
echo 内存:$mem

echo 规格/型号：${hostname}
echo 系统生成时间：$time
echo 系统安装时间：$utime
echo 硬盘序列号：$SerialNo
echo 硬盘分区大小 ：$SIZE G  
echo 硬盘大小 ：$HSIZE 
echo IP  $IP
echo MAC: $MAC
echo 屏幕尺寸: $z 寸
