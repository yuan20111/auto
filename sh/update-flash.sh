#! /bin/bash
plugindir=/usr/lib/firefox-addons/plugins
readmefile=${plugindir}/readme.txt
flashpluginfile=${plugindir}/libflashplayer.so

getNewVersion(){
	rm -f index.html*
	wget http://www.adobe.com/software/flash/about/
	if [ $? -ne 0 ] ;then
		echo "wget failed, network problem"
		exit 1
	fi
	version=$(grep -A1 "Firefox - NPAPI (Extended Support Release)" index.html | tail -1 |sed 's/<[^>]*>//g' | tr -d '\r')

	#除去version前后的空格
	version=$(echo "$version")
	echo $version

}

getCurVersion(){
	version=$(grep "Version" readme.txt|awk -F" " '{print $2}')
	#除去version前后的空格
	echo $version
}

updatePlugin()
{
	#判断系统是32位还是64位
	if [ "$(getconf WORD_BIT)" = "32" ] && [ $(getconf LONG_BIT) = "64" ] ; then
		wordbit=x86_64
	else
		wordbit=i386
	fi
	wget https://fpdownload.adobe.com/get/flashplayer/pdc/$1/install_flash_player_11_linux.$wordbit.tar.gz
	if [ $? -ne 0 ] ;then
		echo "wget failed, network problem"
		exit 1
	fi
	tar zxvf install_flash_player_11_linux.$wordbit.tar.gz
	if [ $? -ne 0 ] ;then
		echo "tar failed, install_flash_player_11_linux.$wordbit.tar.gz not download"
		exit 1
	fi
	rm -rf LGPL usr install_flash_player_11_linux.$wordbit.tar.gz
}

cd $plugindir
#获取最近flash插件版本 
newVersion=$(getNewVersion)
echo "newVersion=${newVersion}111"

#检测原flash插件是否存在
if [ -f $readmefile ] && [ -f $flashpluginfile ];then
	echo "file readme.txt and libflashplayer.so exists"
else
	if [ "$1" == "test" ] ; then
		echo "flashplupdate"
	else 
		updatePlugin $newVersion
	fi
fi

#判断原flash插件版本是否为最新版本
curVersion=$(getCurVersion)
echo "curVersion=${curVersion}222"
if [ "$newVersion" = "$curVersion" ] ;then
	echo "newVersion == curVersion"
else
	if [ "$1" == "test" ] ; then
		echo "flashplupdate"
	else
		echo "curVersion is old, need to update!"
		updatePlugin $newVersion
	fi
fi

