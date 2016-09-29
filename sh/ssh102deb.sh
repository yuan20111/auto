#!/usr/bin/expect

set timeout 30
set user zhiyuan
set ip 192.168.8.102
set passwd zhiyuan
set folder /srv/ftp/fdos2015_repo/dev_nfs/pool/new_deb_08

spawn ssh -l $user $ip 
expect "password:"
send "$passwd\r"
sleep 1
expect "*" 
send "bash\r"
expect "*" 
send "cd $folder\r"
interact 
