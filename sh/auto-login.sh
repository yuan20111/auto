#!/usr/bin/expect
filename:auto-login.sh
func:自动输入密码，需要装export工具(替换 用户名、密码、IP，个性化操作)
usage:

set timeout 30
spawn ssh -l zhiyuan 192.168.7.171
expect "password:"
send "123\r"

expect "zhiyuan"
send "cd /mnt/isoRoom/zhiyuan\r"
interact 
