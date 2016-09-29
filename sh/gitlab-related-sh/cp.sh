#!/bin/bash 
dir=`pwd`
tar_dir=/srv/ftp/fdos2015_repo/dev_nfs/pool/new_deb_08/Debs_to_repo_1.5-dev-$1/

copy_deb(){
cd $dir
src_dir=`cat src_name`
begin_l=`echo $src_dir | sed 's/\(.\).*/\1/g'` 
cur_dir=${begin_l}/${src_dir} 
mkdir $cur_dir -p 
ls *deb
mv *deb $cur_dir
cp $begin_l $tar_dir -r
if [ $? -eq 0 ];then
	ls ${tar_dir}${cur_dir}/*
	sleep 1
	echo "Deb包拷贝成功
	"
	else
	echo Deb包拷贝失败,程序即将退出
	sleep 1
	exit
fi
cd $dir
if [ "$dir" != "/home/xuequan/xuequan" -a "$dir" != "/home/xuequan/xqguo" ]
then
        echo "当前路径不正确，即将退出"
        exit
fi
for i in *
do
	if [ "$i" != "cp.sh" -a "$i" !=  "auto.sh" -a "$i" != "record.sh" ];then
	rm $i -rf
	fi
done
}

change_power(){
        chgrp repo -R ${tar_dir}${cur_dir}
}

scanpackages(){
cd /srv/ftp/fdos2015_repo/dev_nfs

dpkg-scanpackages -a amd64 pool/new_deb_08 >GGG
echo "
        请认真比较扫描日志
"
diff GGG dists/dev/new_deb_08/binary-amd64/Packages | grep Filename

echo 是否覆盖日志，请输入y/n
read yn
if [ "$yn" == "y" ]
then
#        cp  GGG dists/dev/new_deb_08/binary-amd64/Packages
        diff GGG dists/dev/new_deb_08/binary-amd64/Packages | grep Filename

fi
cd $dir
}

main(){
if [ "$dir" != "/home/xuequan/xuequan" -a "$dir" != "/home/xuequan/xqguo" ]
then
        echo "当前路径不正确，即将退出"
        exit
fi
if [ $# -ne 1 ];then
	echo "example: ./cp.sh 03"
	exit
fi
        copy_deb
        change_power
        scanpackages

}
main $@

