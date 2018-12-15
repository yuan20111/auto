function mfdroot()
{

    echo "===Begin to debootstrap..."
    #[[ $EDITION == "GE" ]] && BASE_RELEASE_WEB=ftp://fdos2:fdos2123@192.168.8.102//mirror/archive.ubuntu.com/ubuntu/ || \
    BASE_RELEASE_WEB=ftp://fdos2:fdos2123@192.168.8.102//HGJ_baserepo/HGJ_baserepo/archive.ubuntu.com/ubuntu/     
    #BASE_RELEASE_WEB=http://124.16.141.172/cos3/ubuntu/
    sudo debootstrap --arch=${OSARCH} --no-check-gpg ${BASE_RELEASE} $ROOTFS ${BASE_RELEASE_WEB}  || return 1
    echo End debootstraping...
}

function mfdrootbuilder()
{
    if [ ! -d $OUT/out/squashfs-root ] ; then
        echo ERROR:out/squashfs-root dir has not exist.
        return 1
    fi
    echo "===开始按照清单安装-------------------------------------------------------"
    T=$(gettop)
    sudo mount --bind /dev $OUT/out/squashfs-root/dev
    sudo cp /etc/hosts $OUT/out/squashfs-root/etc/hosts
    sudo cp /etc/resolv.conf $OUT/out/squashfs-root/etc/resolv.conf
    if [ -f $T/build/core/list_badPostinstall ];then  
       pkgsname=""
       while read list
       do
           pkgsname="$pkgsname `echo $list | awk '{print $1}'`"
       done < $T/build/core/list_badPostinstall
         sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get install --yes --allow-unauthenticated $pkgsname"
         echo "===安装前，安装坏包：$pkgsname"
    fi 
    
   
    #开始仓库配置 
    echo "" | sudo tee  $OUT/out/squashfs-root/etc/apt/sources.list  #清空
    if [ $FLAG_TESTDEB == "TRUE" ];then
       cd $OUT/out/squashfs-root/tmp/
       sudo mkdir -p test_deb/{pool,dists/test/t1/binary-amd64/}
       for deb in ` find $OUT/test_deb/ -name *.deb `; do
           echo "test_deb:"$deb
           sudo cp $deb $OUT/out/squashfs-root/tmp/test_deb/pool/
       done
       cd test_deb
       dpkg-scanpackages -aamd64 pool | sudo tee dists/test/t1/binary-amd64/Packages
       echo "deb file:/tmp/test_deb test t1" | sudo tee  $OUT/out/squashfs-root/etc/apt/sources.list
       cd $OUT
    fi
    echo "zuo dbg:$PRODUCT"
    if [[ -n $PRODUCT ]];then
      pro=$PRODUCT
      pro_higher=${pro%-*}; 
      echo "zuo dbg:$pro,$pro_higher"
      while [ $pro_higher != $pro ];do 
	  echo "zuo dbg: prepare  source.list for product=$PRODUCT: $pro,$pro_higher"
          [[ -f $T/build/core/sources_$pro.list ]] || echo "Error: File sources_$pro.list  does not exit"
          cat $T/build/core/sources_$pro.list | sudo tee -a  $OUT/out/squashfs-root/etc/apt/sources.list
	  pro=$pro_higher 
          pro_higher=${pro%-*};
      done 
    fi
       
    cat  $T/build/core/sources_${EDITION}.list | sudo tee -a  $OUT/out/squashfs-root/etc/apt/sources.list
    cat  $T/build/core/sources_common.list | sudo tee -a  $OUT/out/squashfs-root/etc/apt/sources.list
    echo "===仓库配置结果是："
    cat $OUT/out/squashfs-root/etc/apt/sources.list
    #结束仓库配置 
    echo "zuo dbg, mfdrootbuilder: FLAG_OEM=$FLAG_OEM"
    #[ $FLAG_OEM == "OEM" ] && cat $T/build/core/sources.list_oem | sudo tee -a $OUT/out/squashfs-root/etc/apt/sources.list || echo "Error : [ $FLAG_OEM == "OEM" ]" 	#del by yuanjz for 64bit oem 20150811


    # 开始，根据软件清单安装软件

    sudo chroot $OUT/out/squashfs-root /bin/bash -c "mount none -t proc /proc"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "mount none -t sysfs /sys"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "mount none -t devpts /dev/pts"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y --force-yes update" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y -f --force-yes --purge upgrade" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dbus-uuidgen > /var/lib/dbus/machine-id"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg-divert --local --rename --add /sbin/initctl"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "ln -s /bin/true /sbin/initctl"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install --yes --allow-unauthenticated  --no-install-recommends libpam-systemd" || return 1
    
    
    pkgsname=""
    [ -f $T/build/core/filesystem.manifest ] || return 1
    for  list in `cat $T/build/core/filesystem.manifest $T/build/core/list_$EDITION`
    do
        pkgsname="$pkgsname `echo $list | awk '{print $1}'`"
    done 
    #一般，是GE的衍生版本， EDITION 变量不会赋值为DE。
    if [ -f $T/build/core/list_DE ] && [ $FLAG_DE == "DE" ];then
        while read list
        do
            pkgsname="$pkgsname `echo $list | awk '{print $1}'`"
        done < $T/build/core/list_DE
    fi
    
    #下面的程序，认为PRODUCT的定义符合要求
    if [[ -n $PRODUCT ]];then
      pro=$PRODUCT
      pro_higher=${pro%-*}; 
      while [[ $pro_higher != $pro ]];do 
	  echo "zuo dbg: prepare  pkg list for product=$PRODUCT: $pro,$pro_higher"
          [[ -f $T/build/core/list_$pro ]] || echo "Error: File list_$pro  does not exit"
          for list in `cat $T/build/core/list_$pro`
          do
             pkgsname="$pkgsname `echo $list | awk '{print $1}'`"
          done
	  pro=$pro_higher 
          pro_higher=${pro%-*};
      done 
    fi


    [ $FLAG_OEM == "OEM" ] && pkgsname="$pkgsname oem-config oem-config-debconf oem-config-gtk oem-config-remaster"
    [ $FLAG_OS == "DBL" ] && pkgsname="$pkgsname dualnet"
    echo "Following Packages will be installed:"
    echo $pkgsname

    sudo chroot $OUT/out/squashfs-root /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install --yes --allow-unauthenticated  --no-install-recommends  ${pkgsname}" || return 1
    
    echo "before Post install"
    cat $ROOTFS/etc/default/grub
    if [ -f $T/build/core/list_Postinstall ];then 
       pkgsname=""
       while read list
       do
           pkgsname="$pkgsname `echo $list | awk '{print $1}'`"
       done < $T/build/core/list_Postinstall
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install --yes --allow-unauthenticated  --no-install-recommends  ${pkgsname}" || return 1
    fi

   
    if [ -f $T/build/core/list_force ];then  #in fact only one:xserver-xorg-video-s3g
       pkgsname=""
       while read list
       do
           pkgsname="$pkgsname `echo $list | awk '{print $1}'`"
       done < $T/build/core/list_force
       if [[ $pkgsnameX != ""X ]];then
	 echo "start process packages defined in list_force "
         sudo chroot $OUT/out/squashfs-root /bin/bash -c "mkdir force_deb_install"
         sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd force_deb_install; apt-get download --yes --allow-unauthenticated $pkgsname"
         sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd force_deb_install; dpkg -i --force all *.deb"
         sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm -rf force_deb_install"
         kernel_version=`ls $OUT/out/squashfs-root/boot/vmlinuz* | xargs basename | cut -d '-' -f2-`
         echo "kernel version is :$kernel_version"
         sudo chroot $OUTPATH/squashfs-root /bin/bash -c "depmod $kernel_version" || return 1
       fi
    fi 
    echo "-----------apt-get autoremove, clean unnecessary dependency packages---------"
#    # autoremove is used to remove packages that were automatically installed to satisfy dependencies for other packages and are now no longer needed.
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y --force-yes autoremove" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y --force-yes clean" || return 1

    echo "===软件包全部安装完成"
#
#    #clean squashfs
  #  sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /etc/apt/preferences"
#
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /var/lib/dbus/machine-id"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /sbin/initctl"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg-divert --rename --remove /sbin/initctl"
 
 
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y --force-yes clean"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "umount -lf /proc"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "umount -lf /sys"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "umount -lf /dev/pts"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "exit"
    sudo umount  -l  $OUT/out/squashfs-root/dev
    return 0
}
function mosfd_log()
{
   mosfd |  tee  -a log
   log_key=`tail  -n 100 log  | grep "mkiso has finished." -A1 | tail -n1 | sed 's/^.*NFS_Desktop/NFS_Desktop/' | sed 's/\.iso//'`
   cp log log_$log_key
}
function mkiso_for_product() #产品
{
    if [ "$special_factory" = "lenovo" ]; then 
        mkiso_for_lenovo
    elif ["$special_factory" = "inesa"]; then
        mkiso_for_INESA
    elif ["$special_factory" = ""]; then
        mkiso_for_RETAIL
    fi
}

#function mkiso_for_lenovo_PC() #联想
#{
#    export PRODUCT="HGJ-LENOVO-PC"
#    echo "===开始制作联想台式机HGJ版本" | tee log
#    iso_for_lenovo
#}
#function mkiso_for_lenovo_laptop() #联想
#{
#    export PRODUCT="HGJ-LENOVO-LAPTOP"
#    echo "===开始制作联想笔记本HGJ版本" | tee log
#    iso_for_lenovo
#}

function mkiso_for_lenovo() #联想
{
    export PRODUCT="HGJ-LENOVO"
    export rel_type="OEM-LENOVO"
    echo "===开始制作联想HGJ版本" | tee log 
    mosfd_log
}

function mkiso_for_INESA()  # 上海仪电
{
    export PRODUCT="HGJ-INESA-MINIBOX"
    export rel_type="OEM-INESA"
    echo "===开始制作上海仪电HGJ版本" | tee log
    mosfd_log
}
function mkiso_for_RETAIL()  # 零售版本
{
    export rel_type="RETAIL"
    echo "===开始制作零售版本" | tee log
    mosfd_log
}

function mosfd()
{
    
    export BUILDOSDIRS="mint desktop"
    BUITSTEP=0
    if [ -e $BUILDOSSTEP ] ; then
        BUITSTEP=`cat $BUILDOSSTEP`
        if [ "$BUITSTEP" -gt 0 ] 2>/dev/null ; then
            BUITSTEP=$BUITSTEP
        else
            BUITSTEP=0
        fi
    fi

    T=$(gettop)
    if [ "$T" ]; then
        #Install zh_CN deb and Input Method deb.
        OUTPATH="$OUT/out"
        APPPATH=$OUT/$PREAPP

        if [ ! -e $OUT/out ] ; then
            mkdir -p $OUT/out
        else
            touch $BUILDOSSTEP 2>/dev/null
            if [ $? -ne 0 ] ; then
                Group=`groups $USER | cut -d ' ' -f 1`
                sudo chown $Group.$USER $OUT/out
            fi
        fi

        if [ $BUITSTEP -le 20 ] ; then
            echo 20 >$BUILDOSSTEP
            checktools || return 1
            createlink || return 1
            #mall || return 1
        fi

        if [ $BUITSTEP -le 23 ] ; then
            echo 23 >$BUILDOSSTEP
            mfdroot || return 1
	fi 
        echo "===debootstrap finished"
        if [ $BUITSTEP -le 25 ] ; then
            echo 25 >$BUILDOSSTEP
            mfdrootbuilder || return 1
        fi
	echo "===mfdrootbuilder finished"
        if [ $BUITSTEP -le 28 ] ; then
            echo 28 >$BUILDOSSTEP
            if [[ $EDITION == "GE" ]]; then
 		 sudo -E sh $T/build/livecd/create_livecd_GE.sh $OUT/out || return 1
            elif [[ $EDITION == "HGJ" ]];then 
                 sudo -E sh $T/build/livecd/create_livecd_HGJ.sh $OUT/out || return 1
            else
               echo "Error: EDITION is $EDITION "
	       return 1
            fi
        fi
	echo "===create_livecd.sh finished"

	# 其他关于livecd的内容

        mountdir || return 1


        #fix some bugs by change files directly.
        if [ $BUITSTEP -le 140 ] ; then
            echo 140 >$BUILDOSSTEP
            echo change casper username and hostname
            sudo sed -i 's/mint/$OSNAME/' $OUTPATH/squashfs-root/etc/casper.conf
            echo "$OSFULLNAME $OSISSUE \\n \\l" | sudo tee $OUTPATH/squashfs-root/etc/issue
        fi


        if [ $BUITSTEP -le 195 ] ; then
            echo 195 >$BUILDOSSTEP
#	    post_install || return 1
            source $T/build/core/post_install.sh
	    fi
        umountdir || return 1
        NOWTIME=`date +%Y%m%d%H%M`
        #iso_name=`echo "$OSNAME" | sed 's/ /_/'`
        #ISONAME="$iso_name-64bit-$NOWTIME"
        #export ISOFILENAME="$ISONAME.iso"
        export ISOFILENAME=$iso_file_name".iso"
                            
        if [ $BUITSTEP -le 200 ] ; then
            echo 200 >$BUILDOSSTEP
            if [ ! -d $OUTPATH/squashfs-root/usr/share/"$OSNAME" ] ; then
                sudo  mkdir -p $OUTPATH/squashfs-root/usr/share/"$OSNAME"/
            fi
            echo source $NOWTIME | sudo tee $OUTPATH/squashfs-root/usr/share/"$OSNAME"/buildtime
            mkiso "$ISOFILENAME" || return 1
	    sudo isohybrid -u "$ISOFILENAME"
        fi
        echo Finish building "$OSFULLNAME".
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
    echo "生成这个iso的脚本状态如下："
    git status | head -n1  
    git log -n1
    git diff
} 
