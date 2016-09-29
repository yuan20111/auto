#!/bin/bash

# $1 例子： http://192.168.8.102/desktop_2015/evince/merge_requests/12/
# git@nfsgitlab:desktop_2015/evince.git

group=`echo $1 | cut -d '/' -f4`
proj=`echo $1 | cut -d '/' -f5`
echo "INFO: git@nfsgitlab:$group/${proj}.git"

ssh nfs@192.168.7.244 "[[ -d compile/$proj ]] && rm -rf compile/$pro/*" 
ssh nfs@192.168.7.244 " mkdir -p compile/${proj}"
ssh nfs@192.168.7.244 "cd compile/${proj}/; git clone git@nfsgitlab:$group/${proj}.git"

debian_dir=`ssh nfs@192.168.7.244 "cd compile/; find . -type d -name debian"`
compile_dir=`ssh nfs@192.168.7.244 "cd compile/; cd $debian_dir;cd ..;pwd"`
deb_dir=`ssh nfs@192.168.7.244 "cd compile/;cd ${compile_dir};cd ..;pwd"`

ssh nfs@192.168.7.244 "cd ${compile_dir};sudo apt-get build-dep $proj"
ssh nfs@192.168.7.244 "cd ${compile_dir};pwd;dpkg-buildpackage"
ssh nfs@192.168.7.244 "ls ${deb_dir}/*\.deb"

if [[ $? -ne 0 ]];then 
  echo "===    Failed !"
else
 mkdir $proj
 cd $proj
 scp  nfs@192.168.7.244:$deb_dir/*.deb ./
 cd -
fi

