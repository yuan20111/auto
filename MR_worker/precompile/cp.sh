#!/bin/bash

expect -c "
        spawn scp $1 nfs@192.168.7.180:~/compile/
        expect {
                \"*assword\" {set timeout 30; send \"nfs123\r\";}
                \"yes/no\" {send \"yes\r\"; exp_continue;}
        }
        expect eof"

if [ $? -eq 0 ]; then
  echo "Succ: scp $1 successfully" >> /home/git/gitlab/log/gitlab_mr
  mv $1  /home/git/gitlab/precompile/backup/
else
  echo "Error: scp $1 failed" >> /home/git/gitlab/log/gitlab_mr
fi

exit
