#! /bin/bash  
# Filename:Replay.sh  

read -p "Please input the session filename: " filename  
logfile="$filename.timing.log"  
sesfile="$filename.session"  
if [ -e $sesfile ]; then  
	scriptreplay $logfile $sesfile  
	echo  
else  
	echo "$filename is NOT Exsit!"  
fi 
