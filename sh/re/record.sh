#! /bin/bash  
# Filename:Record.sh  

read -p "Please input the sesson filename you want to creat: " filename;  

sesfile="$filename.session"  
logfile="$filename.timing.log"  

if [ -e $sesfile ];then  
	echo "$sesfile is Exsit,Creat session file fault!";  
	read -p "If you want to reload the file? [Y/N]: " flag;  
	if [ "$flag" = "Y" ];then  
		rm $sesfile $logfile;  
		script -t 2> $logfile -a $sesfile;  
	else  
		echo "Nothing to do!";  
	fi  

else  
	script -t 2> $logfile -a $sesfile;  
fi   
