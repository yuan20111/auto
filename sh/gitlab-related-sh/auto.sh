#!/bin/bash - 
#===============================================================================
#
#          FILE:  auto.sh
# 
#         USAGE:  ./auto.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Guo,Xuequan (), xuequan@nfschina.com@nfschina.com
#       COMPANY: nfschina
#     COPYRIGHT: Copyright 2001-2015 nfschina Technology Co.,Ltd.
#       CREATED: 2015年09月14日 09时28分22秒 CST
#      REVISION:  ---
#===============================================================================
dir_turn_l(){
path_name=`ls /srv/ftp/fdos2015_repo/dev_nfs/pool/new_deb_08`
dir_turn=00
echo "--------------------------------"
cat src_name
echo "--------------------------------"

echo "--------------------------------"
ls *deb
echo "--------------------------------"
for dir in $path_name
do
        new_num=${dir:0-2:2}
                if [ $new_num -ge $dir_turn ]
        then
                dir_turn=$new_num
        fi
done

echo ---------------------------------
echo Debs_to_repo_1.5-dev-$dir_turn
echo ---------------------------------
}
dir_turn_l
./record.sh $dir_turn
./cp.sh $dir_turn

