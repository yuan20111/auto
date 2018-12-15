#!/bin/bash
set -e
usage(){
	echo "Usage: $0 pathof_local_cabage pathof_targetdir"
	echo "      例如： $0 ~/0602_to_0806 /media/hmm/iso"
	echo "其中pathof_local_cabage(~/0602_to_0806)应为 conf  latest_debs  update.txt 结构"
}
[ "x$1" == "x" ] && echo "error: 缺少参数" && usage && exit 1
[ "x$2" == "x" ] && echo "error: 缺少参数2" && usage && exit 1
echo " "
localcab=$1
targetdir=$2
echo "仓库:$localcab"
echo "目标文件夹:$targetdir"
[ "x`ls $targetdir`" != "x" ] && echo "error: 未清空$targetdir,请手动清空。" && exit 1

sourcecab=`ls $localcab`
[ "x`echo $sourcecab | grep conf  -w `" == "x" ] && echo "error：$localcab中不存在conf文件夹,请参考以前的仓库" && exit 1
[ "x`echo $sourcecab | grep latest_debs  -w `" == "x" ] && echo "error：$localcab中不存在latest_debs文件夹,请参考以前的仓库" && exit 1
[ "x`echo $sourcecab | grep update.txt  -w `" == "x" ] && echo "error：$localcab中不存在update.txt文件,请参考以前的仓库" && exit 1
echo "1.配置distribution..."
sleep 1
vi $localcab/conf/distributions
targetcab=$targetdir/OfflineUpgrade/offline_upgrade/between_old_and_new
sudo mkdir $targetcab -p
sudo cp $localcab/conf $targetcab  -r
sleep 1
echo "完成!"

echo "2.创建仓库树..."
sleep 1
sudo reprepro  -Vb  $targetcab  export
sleep 1
echo "完成！"

echo "3.复制并扫描仓库..."
sleep 1
list=`find $localcab/latest_debs -name "*.deb"`
for it in $list;do
	sudo reprepro -Vb $targetcab includedeb pub $it; 
done
sleep 1
echo "完成！"

echo "4.复制用户所需的脚本和文档..."
sleep 1
sudo cp ../for_client/* $targetdir/OfflineUpgrade
sudo cp $localcab/update.txt $targetcab
sudo vi $targetcab/update.txt
sleep 1
echo "完成！ $targetdir 可以交付用户使用,请测试。"
