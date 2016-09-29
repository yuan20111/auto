#!/bin/bash  

expect -c "
        spawn scp $1 mfq@192.168.7.230:~/compile/
  	expect {
    		\"*assword\" {set timeout 30; send \"1q2w3e\r\";}
    		\"yes/no\" {send \"yes\r\"; exp_continue;}
  	}
        expect eof"
exit
