#!/bin/bash

#32位编译机代码

func_return=0 		#函数运行结果

#调试方便，root运行，和普通用户用不同的路径
DBG=  #调试开关true或者空
RUNINGDIR=/home/nfs/autowork/git-runing               #运行目录,在这个目录下git clone代码，编译源码生成包
NOTEDIR=/home/nfs/compile
if [ $DBG ] ;then
	RUNINGDIR=~/git-runing               
	NOTEDIR=~/compile
fi

ADMIN_MAILIP=yuanzhiyuan@nfschina.com
ADMIN_MAILIP1=mingming@nfschina.com

#from loglevel message log
#loglevel=0, 1, 2, 3
message(){
	loglevel=2             #日志输出位置             
	case $loglevel in 
		0)
			;;
		1)
			[[ $1 ]] && echo ">>> $*"          #输出到终端
			;;
		2)
			[[ $1 ]] && echo ">>> $*"
			[[ $1 ]] && echo ">>> $*" >> $TMPLOG     #保存日志
			;;
		*)
			[[ $1 ]] && echo ">>> loglevel error"
			[[ $1 ]] && echo ">>> loglevel error" >> $TMPLOG 
			exit 3
			;;
	esac
}

#发送邮件通知管理员
auto_sendmail2admin(){
	func_return=1
	cat  $TMPLOG >> /tmp/content.txt
	{
		mail -A $NOTE  $NOTE  -s "编译出错，请您核查autowork流程" $ADMIN_MAILIP< $TMPLOG
		[ $DBG ] || mail -A $NOTE  $NOTE  -s "编译出错，请您核查autowork流程" $ADMIN_MAILIP1< $TMPLOG
	}&
}

#发送邮件通知管理员和作者
auto_sendmail2author(){
	func_return=1
	cat  $TMPLOG >> /tmp/content.txt
	[ $DBG ] ||	{	
		mail -A $NOTE  $NOTE  -s "编译出错，请您核查源码" $MAILIP < $TMPLOG
	}&
	{	
		mail -A $NOTE  $NOTE  -s "编译出错，已发送邮件请源码编写者核查" $ADMIN_MAILIP < $TMPLOG
		[ $DBG ] ||	mail -A $NOTE  $NOTE  -s "编译出错，已发送邮件请源码编写者核查" $ADMIN_MAILIP1 < $TMPLOG
	}&
}

#解析gitlab服务器发来的txt文件
get_note(){
    message "begining get $NOTE info"

    if [ ! -f $NOTE ]; then  #判断变量未定义
        message "get note error ! note is not exist..."
    fi  
    local NOTEHEAD=`cat $NOTE | head -1`  #分    支 : git@nfsgitlab:desktop_2015/paredid.git master
    GITIP=`echo "$NOTEHEAD" | awk -F ": " '{print $2}' | awk '{print $1}' ` 
    branch=${NOTEHEAD##* }
    proj=`echo ${GITIP##*/} | awk -F ".git" '{print $1}'`                                                                                                         
    message "NOTEHEAD: $NOTEHEAD"
    message "GITIP   : $GITIP"
    message "branch  : $branch"
    message "project : $proj"
    SRCMARGE=`echo ${NOTE##*/} | awk -F '.txt' '{print $1}'`
    message "SRCMARGE : $SRCMARGE"
    MAILIP=`grep "邮    箱 :" $NOTE | awk -F ': ' '{print $2}'`
    message "MAILIP  : $MAILIP"
}

#获取该合并请求的源码
get_src(){
	#检查proj是否已经存在/ 检查$proj === $src_name
	message "begining get source code."
	cd $RUNINGDIR
	if [ -d $SRCMARGE ]; then
		message "rmoveing has exist $SRCMARGE..."
		rm $SRCMARGE -rf
	else
		mkdir -p $SRCMARGE
		[ $? -eq 0 ] && message "mkdir $SRCMARGE" || message "mkdir $SRCMARGE error !"
		cd $SRCMARGE
	fi
	
	message "begining clone $proj code."
	git clone $GITIP
	if [ $? -ne 0 ];then
		message " git clone error! please check git ip ($GITIP)"
	fi
}

#copy生成物到nfs-deb-32
copy_deb(){
	message "begining copy  deb"
	#日志信息。包信息
	[ ! -d "$DESTDIR/$SRCMARGE" ] && mkdir -p "$DESTDIR/$SRCMARGE"  #创建cp deb 目录
	local dpkgnote=$DESTDIR/$SRCMARGE/dpkg-note.txt
	echo " " > $dpkgnote #note前加空行，使note格式清晰
	grep -v "编译参数" $NOTE | grep -v "邮    箱 :" >> $dpkgnote
	echo "生成 Deb :" >> $dpkgnote

	local flag=0
	local SRCDEB=`find $RUNINGDIR/$SRCMARGE -print | grep deb$ | grep -v udeb$`
	local DEBNUM=`find $RUNINGDIR/$SRCMARGE -print | grep deb$ | grep -v udeb$ | wc -l`
	for deb in $SRCDEB; do
		cp $deb $DESTDIR/$SRCMARGE && let flag+=1
		echo "    	   ${deb##*/}" >> $dpkgnote
		[ "$?" -ne "0" ] && message "copy error!" 
	done
	echo " " >> $dpkgnote #note后加空格，使格式清晰
	if [ "$flag" == "$DEBNUM" ]; then
		message "copy success!!"
		[ $DBG ] && echo "编译$SRCMARGE.txt成功" >> ~/autowork.log  || echo "编译$SRCMARGE.txt成功" >>  $AUTOWOTKLOG
	fi
	cp $TMPLOG $DESTDIR/$SRCMARGE

}

#构建包
build(){
	message "begining build deb，copy deb and log to $DESTDIR/$SRCMARGE"
	local DPKGPATH=`find $RUNINGDIR/$SRCMARGE -print | grep debian/changelog$ |sed -n 1p`
	if [  "$DPKGPATH"=="" ];then
		DPKGPATH=${DPKGPATH:0:0-17}
	else 
		 message "build error! cann't find changelog" && auto_sendmail2admin
	fi  
	
	cd $DPKGPATH  #切换路径到有debian文件夹的那一层,进行切分支编译
	git branch
	git checkout $branch
	if [ $? -ne 0 ];then
		message "git chechout error!" && auto_sendmail2admin && return
	fi  
	
	local SRCCTL=`find $DPKGPATH -print | grep 'debian/control$'`
	local src_name=`grep Source $SRCCTL | awk '{print $2}'`
	message "src name : $src_name"
	dpkg-buildpackage  
	local state=$?
	local mail_state=0
	message "build state is $state"
    
	#编译状态的不同处理
	case $state in 
		0)		#编译状态为0,编译成功
			message "dpkg-buildpackage success"
			;;
		1)		#警告
			message "dpkg-buildpackage success,has walling"
			;;
		2)		#代码错误
			message "dpkg-buildpackage error,please check code"
			auto_sendmail2author && mail_state=1
			;;
		3)		#依赖不足，或者依赖冲突，目前只考虑依赖不足。
			message "Deoence is error.begining auto got it"
			sudo apt-get build-dep $src_name -y --force-yes  
			dpkg-buildpackage
			[ $? -eq 0 ] && message "Dependence is satisfied" || message "state3"
			;;
		255)	#基本上是change格式错误
			message "dpkg-buildpackage error,please check code,such as debian/changelog format....<<<  hi boy or girl, please look here"
			auto_sendmail2author && mail_state=1
			;;
		*)
			;;
	esac
	
	#编译生成deb包，则build成功，然后执行拷贝，build失败，发送邮件
	ls ../*.deb                                  
	if [ $? -eq 0 ];then
		message "build success!"
		copy_deb
	else 
		message "build error!" 
		[ $DBG ] && echo "编译$SRCMARGE.txt失败,编译状态$state" >> ~/autowork.log  || echo "编译$SRCMARGE.txt失败,编译状态$state" >>  $AUTOWOTKLOG
		[ $mail_state -eq 1 ] && return  #邮件状态，防止邮件重复发送.
		auto_sendmail2admin
	fi  
}

clean(){
	message "removeing $RUNINGDIR/$SRCMARGE..." #清除git-runing下的本次对应源码文件夹
	rm -rf $RUNINGDIR/$SRCMARGE
	message "removeing $NOTE..."                #删除gitlab发来的原始的编译note
	rm -rf $NOTE
	message "removeing $TMPLOG..."              #删除/tmp/下的中间文件
	rm -rf $TMPLOG
 
}

#检查软件分支，确定生成的包拷贝的位置
check_copydir(){
    case $branch in  
        master)											#主分支
            DESTDIR=$DESTDIR/master                    
            ;;  
        lenovo_notebook)								#联想笔记本
            DESTDIR=$DESTDIR/lenovo_notebook
            ;;  
        INESA)											#仪电
            DESTDIR=$DESTDIR/INESA 
            ;;  
        *)  
            message "$DESTDIR is default output dir"		#其他分支包，默认放在nfs-deb-32
            ;;  
    esac
    message "$DESTDIR is  output dir now"
    [ ! -d $DESTDIR ] && mkdir -p "$DESTDIR" 

}

#初始化环境，编译单个note的入口程序,
init(){
	message "begining Compile and pre compile"
	[ $DBG ] && DESTDIR=~/nfs-deb-32  || DESTDIR=/home/nfs/autowork/nfs-deb-32                #产出物
	[ ! -d $DESTDIR ] && mkdir -p "$DESTDIR"  #创建~/nfs-deb-32
	
	cd $NOTEDIR
	PWD=`pwd`
	for x in  `ls *.txt| sed "s:^:$PWD/: "`
	do
		message ">>$x"
		[ $DBG ] && echo "开始编译${x##*/}" >> ~/autowork.log  || echo "开始编译${x##*/}" >>  $AUTOWOTKLOG
		NOTE=$x
		get_note
		[ $DBG ] || check_copydir
		#func_return标志位，如果已经发送邮件就不再执行获取源码和编译
		[ $func_return -eq 0 ] && get_src
		[ $func_return -eq 0 ] && build
		func_return=0
		clean
	done
	message "Compile and pre compile success!"
}

#过滤器，当note存在,只保留desktop组的note文件。
check_group(){
	if [ $(ls $NOTEDIR/*.txt | wc -l) -gt 1 ];then   #编译note数大于1,分开处理是因为，同目录下grep单个文件，不会显示绝对路径
		for x in `grep "分    支 :" $NOTEDIR/*txt | grep  "git@nfsgitlab:$GRPIP" | awk -F ":分    支" '{print $1}'`; do
			echo "-------------$x"
			mv $x $RUNINGDIR 
		done
	elif [ $(ls $NOTEDIR/*.txt | wc -l) -eq 1 ];then  #编译note数等于1
		if [ "$(grep "分    支 :" $NOTEDIR/*txt | grep  "git@nfsgitlab:$GRPIP" | awk -F ":分    支" '{print $1}')" != "" ]; then 
			echo "-------------"
			mv  $NOTEDIR/*.txt $RUNINGDIR
		fi
	fi  
}

#监控txt文件,如果有编译note，则处理，没有就每过5秒监控一次。
monitor(){
	rm -rf $RUNINGDIR
	[ ! -d $RUNINGDIR ] && mkdir -p "$RUNINGDIR"  #创建运行目录git-runing
	[ ! -d $NOTEDIR ] && mkdir -p "$NOTEDIR"  #创建/home/nfs/compile
	TMPLOG=/tmp/git-autowork.log
	AUTOWOTKLOG=/home/nfs/autowork/nfs-deb-32/autowork.log 
	while [ True ];do
		#编包最外层入口
		ls $NOTEDIR/*.txt
		if [ $? -eq 0 ];then  #编译note存在
			local now=`date +%H:%M:%S`
			[ $DBG ] && echo "$now 发现>>> $(ls $NOTEDIR/*.txt)<<<" >> ~/autowork.log  || echo "发现>>> $(ls $NOTEDIR/*.txt)<<<" >>  $AUTOWOTKLOG
			#过滤器,此处数组控制编哪个组的包。
			GRPIPD=("bugteam")
			for i in ${GRPIPD[@]};do
				GRPIP=$i
				echo "-----------------$GRPIP"
				check_group 
			done
			ls $NOTEDIR/*.txt
			if [ $? -eq 0 ]; then
				[ $DBG ] && echo "删除不合要求的>>> $(ls $NOTEDIR/*.txt)<<<" >> ~/autowork.log  || echo "删除不合要求的>>> $(ls $NOTEDIR/*.txt)<<<" >>  $AUTOWOTKLOG
				rm -rf $NOTEDIR/*.txt 
			fi
			mv $RUNINGDIR/*.txt $NOTEDIR 

			rm -rf $TMPLOG  
			init
		else
			sleep 5
			message "没有note文件，持续监控中..."
		fi
	done   
}
monitor





