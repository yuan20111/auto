#!/bin/bash

deb_f(){
	echo  "生成Deb "
	echo "(双击Enter提交)： "

	while true
	do
		read a
		if [ "$a" == "" ];then
			echo "Deb包输入完毕！"
			break
		fi
		d_flag=`echo $a | grep ".deb"`
		if [ "$d_flag" != "" ];then
			b+="$a "
		else
			echo "输入的deb包名不对，请重新输入： "
		fi
	done

	deb_num=`echo $b| sed 's/\(deb\)/\1\n/g' | grep deb |wc -l`
	echo $deb_num

	for ((num=1;num<=deb_num;num++))
	do
		echo "$a" | awk -F " " '{print $'$num'}'
	done

	if [ $deb_num -eq 0 ];then
		echo 
		deb_f
	fi
}

handle_deb(){
	for ((num=1;num<=deb_num;num++))
	do
		value=`echo "$b" | awk -F " " '{print $'$num'}'`
		if [ $num -eq 1 ];then
			echo 
		fi
		echo -e -n "\t\t$value\n"
	done
}

write(){
	echo "

修 改 人 :	$modifier     
软 件 包 :	$package     
描    述 :	$description     
分    支 :	$branch     
修复 Bug :	$bug     
合并 Req :	$merge_req    
生成 Deb :	`handle_deb`"
}

display(){
	echo "
1.修 改 人 :	$modifier     
2.软 件 包 :	$package     
3.描    述 :	$description     
4.分    支 :	$branch     
5.修复 Bug :	$bug     
6.合并 Req :	$merge_req    
7.生成 Deb :	`handle_deb`"
}

modifier_f(){
	read -p "修改人 : " modifier
	echo "         $modifier"
}

package_f(){
	read -p "软件包 : " package
	echo "         $package"
}

description_f(){
	read -p "描  述 : " description
	echo "         $description"
}

branch_f(){
	read -p "分  支 : " branch
	echo "         $branch"
}

bug_f(){
	echo	"http://192.168.8.149/mantis/view.php?id=" 
	read -p "修复bug: " bug
	echo "         $bug"
}

merge_req_f(){
	read -p "合并Req: " merge_req
	echo "         $merge_req"
}


select_modify(){

	read -p "请输入您要修改的选项(1-7): " i
	if [ "$i" == "" ];then
		echo "        修改完成"
		continue
	fi

	case "$i" in
		1) modifier_f
			;;
		2) package_f
			;;
		3) description_f
			;;
		4) branch_f
			;;
		5) bug_f
			;;
		6) merge_req_f
			;;
		7) b=""
		   deb_f
			;;
		*) select_modify
			;;
	esac
}

main(){
	if [ $# -ne 1 ];then
	echo "usage  : ./record dir_num"
	echo "example: ./record 03"
	exit
	fi

	modifier_f
	package_f
	description_f
	branch_f
	bug_f
	merge_req_f
	deb_f

	display
	while [ "$flag"	!= "confirm" ]
	do
		read -p "Are you sure?	(y/n) " yn
		if [ "$yn" == "y" ];then
			flag=confirm
		else
			select_modify

		fi

		display
	done
	cp /srv/ftp/fdos2015_repo/dev_nfs/pool/new_deb_08/Debs_to_repo_1.5-dev-$1/dpkg_update.txt dpkg_update0.txt
	write >>dpkg_update0.txt
	diff /home/xuequan/xqguo/dpkg_update0.txt /srv/ftp/fdos2015_repo/dev_nfs/pool/new_deb_08/Debs_to_repo_1.5-dev-$1/dpkg_update.txt
	read -p "是否覆盖dpkg_update.txt? (y/n) " yon
	if [ "$yon" == "y" ];then
		cp /home/xuequan/xqguo/dpkg_update0.txt /srv/ftp/fdos2015_repo/dev_nfs/pool/new_deb_08/Debs_to_repo_1.5-dev-$1/dpkg_update.txt
	else
		echo "请手动复制合并信息(命令如下:)"
		echo "cp /home/xuequan/xqguo/dpkg_update0.txt /srv/ftp/fdos2015_repo/dev_nfs/pool/new_deb_08/Debs_to_repo_1.5-dev-$1/dpkg_update.txt"
		exit
	fi
}


main $@
