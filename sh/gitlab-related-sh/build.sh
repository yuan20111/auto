#!/bin/bash  
dir=`pwd`
prep_build(){
if [ "$dir" != "/home/nfs/xqguo"  -a "$dir" != "/home/nfs/xuequan" ];then
echo "当前路径不正确，将要退出"
exit
fi 

for i in *
do
if [ "$i" != "build.sh" ];then
rm $i -rf
fi
done 
} 

get_src(){
git clone $1
if [ $? -ne 0 ];then
echo "请检查克隆地址"
exit 2
fi 
}

build(){
path=`find . -print | grep debian/changelog$ |sed -n 1p`
path=${path:0:0-17}
echo "$path  --------"

cd $path
git branch
git checkout $1
if [ $? -ne 0 ];then
echo "切换分支失败"
exit 3
fi

cd $dir
path=`find . -print | grep debian/changelog$ |sed -n 1p`
path=${path:0:0-17}
echo "$path  --------"

cd $path
git branch
sleep 3
dpkg-buildpackage
if [ $? -eq 0 ];then
echo "打包成功"
else 
echo "打包失败"
cd $dir
fi
cd $dir
}

copy_deb(){
num=0
deb_num=`find $dir -print | grep deb$ | wc -l`
cat `find . -print | grep 'debian/control$'` | grep Source | awk -F " " '{print $2}' |sed -n 1p >src_name
file_src=`cat src_name`
if [ "$file_src" == "" ];then
echo "源码包名没有生成到src_name里,请查找原因"
sleep 3
fi
echo $deb_num
for deb in `find $dir -print | grep deb$` src_name
do
expect -c "
        spawn scp $deb xuequan@192.168.8.102:~/xqguo
        set timeout 30
        expect \"*password\"
        send    \"nfschina\r\"

        expect eof
        "
num=$[$num+1]
done
if [ $deb_num == $[$num-1] ];then
echo "Transmit is successful,Deb's number is $[$num-1]"
src_dir=`echo $1 | sed 's#.*\/\(.*\).git#\1#g'`
cd ${src_dir}
ls *deb
cd -
else
echo "Deb's number is error,Please check"
fi 
}

main(){
	if [ $# -eq 2 ];then
	echo start
	else
	echo "usage:. /build.sh git@xxx branch-name"
	exit
	fi
	prep_build
	get_src $1
	build $2
	copy_deb $1
}
main "$@"
