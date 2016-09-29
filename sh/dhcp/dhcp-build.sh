#!/bin/bash

###先确保在网卡服务已经开启//在bios里打开
#安装dhcp服务
sudo dpkg -i isc-dhcp-server*.deb
#配置DHCP网卡
sed  -i 's/INTERFACES=""/INTERFACES="eth0"/g' /etc/default/isc-dhcp-server
#改配置文件
(
cat <<EOF
ddns-update-style none;
option domain-name "tagpt.mtn";
default-lease-time 14400;
#最小租约14400秒=4小时
max-lease-time 36000;
#最大租约36000秒=10小时
subnet 192.168.7.0 netmask 255.255.255.0 {
#IP地址起止范围
range 192.168.7.190 192.168.7.199;
option subnet-mask 255.255.255.0;
#子网掩码 255.255.255.0
option routers 192.168.7.254;
#默认网关 192.168.7.254
option broadcast-address 192.168.7.255;
#广播地址 192.168.7.255                                                     
}
EOF
) >/etc/dhcp/dhcpd.conf
#重启服务
sudo service isc-dhcp-server restart

#现场使用
sudo  ifconfig eth0 192.168.7.110 netmask 255.255.255.0
sudo route add default gw 192.168.7.254

if [ ! -n "`ping 192.168.7.190 -i 0.2 -c 10 | grep error`" ]; then
	echo 
	echo 通 192.168.7.190
	echo 
else
	echo 不通 192.168.7.190 
fi 

