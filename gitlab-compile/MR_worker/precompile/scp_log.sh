#!/bin/bash

#1为编译机  2为仓库机  ip  密码
ip1=192.168.6.168
ip2=192.168.6.168

passwd1=123456
passwd2=123456

#编译机log文件
compile_log=/opt/compile.log
#仓库机log文件
repertory_log=/opt/repertory.log

#本地log目录
local_dir=/home/git/gitlab/log/

#每隔多久拷贝一次log
time=5m

#判断是否安装expect插件
dpkg -l | grep -wq expect
if [ $? -ne 0 ];then
  echo "please install expect"
  exit
fi

while true
do
        expect -c "
                spawn scp root@$ip1:$compile_log $local_dir
        expect {
        \"*assword\" {set timeout 300; send \"$passwd1\r\";}
        \"yes/no\" {send \"yes\r\"; exp_continue;}
        }
        expect eof"

        expect -c "
                spawn scp root@$ip2:$repertory_log $local_dir
        expect {
        \"*assword\" {set timeout 300; send \"$passwd2\r\";}
        \"yes/no\" {send \"yes\r\"; exp_continue;}
        }
        expect eof"

        sleep $time
done
