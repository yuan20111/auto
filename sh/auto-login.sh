#!/usr/bin/expect
set timeout 30
spawn ssh -l zhiyuan 192.168.7.171
expect "password:"
send "123\r"
expect "zhiyuan"
send "cd /mnt/isoRoom/zhiyuan\r"
interact 
