    echo "===************Post install begin:*******************"
   
    [[ $FLAG_TESTDEB = "TRUE" ]] &&  sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm -rf /tmp/test_deb/"
    
   # add by yuanjz 20151224  modify install lib64stdc++6:i386 error,目的是让用户安装lib64stdc++6:i386,因为i386和amd64的两个包在这个文件上冲突。 
    sudo rm -f $ROOTFS/usr/share/doc/libc6/changelog.Debian.gz

    echo "hide some desktop"
    echo "Hidden=true" | sudo  tee -a $ROOTFS/usr/share/applications/openjdk-7-policytool.desktop
 
    echo "rewrite desktop for libreoffice which is too big "
 
    sudo cp $T/build/release/tmpfiles/mdm/mdm.conf $ROOTFS/etc/mdm/ || return 1
    sudo cp  $T/build/release/ubiquity/eula  $ROOTFS/etc/linuxmint/eula    
    SEED_NAME=`echo $OSNAME | sed 's/ //'`
    if [ $FLAG_OEM = "OEM" ];then
        sudo cp  $T/build/release/ubiquity/cos.seed_oem  $OUTPATH/"$OSNAME"/preseed/"$SEED_NAME".seed
    else
        sudo cp  $T/build/release/ubiquity/cos.seed_livecd  $OUTPATH/"$OSNAME"/preseed/"$SEED_NAME".seed
    fi    
    
    echo "$OSFULLNAME $OSISSUE \\n \\l" | sudo tee $ROOTFS/etc/issue
    echo "$OSFULLNAME $OSISSUE \\n \\l" | sudo tee $ROOTFS/etc/issue.net

    [[ -z "$rel_type" ]] && rel_type="Only For Testing"
    codename=$(grep "new_deb_" $T/build/core/sources_common.list |awk '{print $4}' | sort | tail -n1)
    #说明：CODENAME的作用是表明各个版本和仓库之间的关系，用new_deb_01这样的字符串表示。
    echo "NAME=\"$OSNAME $OSPRODUCTVERSION\"
VERSION=\"$OSPRODUCTVERSION\"
BUILD_VERSION=\"$OSBUILDVERSION\"
ID=\"$OSNAME\"
CODENAME=\"$codename\"
ID_LIKE=debian
PRETTY_NAME=\"$OSFULLNAME $OSPRODUCTVERSION\"
OS_TYPE=\"$OSPRODUCTTYPE\"
VERSION_ID=\"$OSPRODUCTVERSION $OSPRODUCTTYPE\"
RELEASE_TYPE=\"$rel_type\"" | sudo tee $OUTPATH/squashfs-root/etc/os-release

    # /etc/linuxmint/info 属于mint-info包,升级时配置会被覆盖。所以决定从mint-info中去掉info文件。
    release_url="http://www.nfschina.com"    
    cat << EOF  | sudo tee $ROOTFS/etc/linuxmint/info
RELEASE="$OSPRODUCTVERSION $OSPRODUCTTYPE"
CODENAME="$codename"
EDITION="64-bit"
DESCRIPTION="NFS Desktop$OSPRODUCTVERSION"
DESKTOP=Gnome
TOOLKIT=GTK
NEW_FEATURES_URL="$release_url"
RELEASE_NOTES_URL="$release_url"
USER_GUIDE_URL="$release_url"
DISTRIB_ID="方德桌面"
GRUB_TITLE="方德桌面操作系统$OSPRODUCTVERSION $OSPRODUCTTYPE"
RELEASE_TYPE="$rel_type"
EOF
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "chattr +i /etc/os-release"

    # /etc/default/locale 不属于包，这样较好，升级时配置不会被覆盖。
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "locale-gen zh_CN.utf-8" 
    sudo chroot $OUT/out/squashfs-root  /bin/bash -c "echo 'LANG=\"zh_CN.utf-8\"' >> /etc/profile; echo 'export LANG'>> /etc/profile"
    sudo chroot $OUT/out/squashfs-root  /bin/bash -c "echo 'LANG=\"zh_CN.utf-8\"' > /etc/default/locale && echo 'LANGUAGE=\"zh_CN:zh\"' >> /etc/default/locale"
    
    sudo sed -i 's/UTC=yes/UTC=no/' $ROOTFS/etc/default/rcS
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime" 
    
    sudo sed -i 's/^DefaultSession=default.desktop/DefaultSession=cinnamon.desktop/g' $ROOTFS/usr/share/mdm/defaults.conf 
    sudo cp $T/build/release/trusted.gpg  $ROOTFS/etc/apt/ || return 1
    


#    sudo chroot $ROOTFS /bin/bash -c "apt-get -qq update " || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "update-initramfs -c -k $KERNEL_VERSION_FULL" || return 1
    sudo cp $OUT/out/squashfs-root/boot/vmlinuz-${KERNEL_VERSION_FULL} $OUT/out/"$OSNAME"/casper/vmlinuz || return 1
    sudo cp $OUT/out/squashfs-root/boot/initrd.img-${KERNEL_VERSION_FULL} $OUT/out/"$OSNAME"/casper/initrd.lz || return 1
    echo "方德桌面操作系统 1.5" | sudo tee $OUTPATH/"$OSNAME"/.disk/release_notes_url
    
    #在iso中放一些deb包，由安装程序安装部署到系统中。功能还没有实现（2016-05-11）
    sudo rsync -a $T/build/release/added_debS/  $OUTPATH/"$OSNAME"/

    #系统调试相关的 
    echo "kernel.sysrq=1" | sudo tee -a $ROOTFS/etc/sysctl.conf 		# add by yuanjz 20151204


    sudo sed -i '/exit 0/d' $ROOTFS/etc/rc.local
    cat << EOF | sudo tee -a  $ROOTFS/etc/rc.local

if [ -f /tmp/tmp.sh ]; then
        rm -rf /tmp/tmp.sh
fi

cat << EO >/tmp/tmp.sh
#!/bin/sh
service apache2 start
service nfs-antivirus-daemon start
which oem-config-firstboot >/dev/null 2>&1
if [ \\\$? = 0 ];then
        while [ ! -f /var/lib/ureadahead/pack ]
        do
                sleep 1
        done
        rm -rf /var/lib/ureadahead/pack
fi
rm -rf /tmp/tmp.sh
EO

if [ -f /etc/rc2.d/S20nfs-antivirus-daemon ]; then
        mv /etc/rc2.d/S20nfs-antivirus-daemon /etc/rc2.d/K20nfs-antivirus-daemon
fi
if [ -f /etc/rc3.d/S20nfs-antivirus-daemon ]; then
        mv /etc/rc3.d/S20nfs-antivirus-daemon /etc/rc3.d/K20nfs-antivirus-daemon
fi
if [ -f /etc/rc4.d/S20nfs-antivirus-daemon ]; then
        mv /etc/rc4.d/S20nfs-antivirus-daemon /etc/rc4.d/K20nfs-antivirus-daemon
fi
if [ -f /etc/rc5.d/S20nfs-antivirus-daemon ]; then
        mv /etc/rc5.d/S20nfs-antivirus-daemon /etc/rc5.d/K20nfs-antivirus-daemon
fi
if [ -f /etc/rc2.d/S91apache2 ]; then
        mv /etc/rc2.d/S91apache2 /etc/rc2.d/K09apache2
fi
if [ -f /etc/rc3.d/S91apache2 ]; then
        mv /etc/rc3.d/S91apache2 /etc/rc3.d/K09apache2
fi
if [ -f /etc/rc4.d/S91apache2 ]; then
        mv /etc/rc4.d/S91apache2 /etc/rc4.d/K09apache2
fi
if [ -f /etc/rc5.d/S91apache2 ]; then
        mv /etc/rc5.d/S91apache2 /etc/rc5.d/K09apache2
fi

sh /tmp/tmp.sh &
exit 0
EOF

    # add by yuanjz 20160217 for wenbing s3s4  ，目的是利于分析问题
    echo "*               soft    core            100000" | sudo tee -a $ROOTFS/etc/security/limits.conf
#grub，配置

    sudo sed -i '/set gfxmode=\${GRUB_GFXMODE}/a\  set gfxpayload=keep' $ROOTFS/etc/grub.d/00_header
    # 设定三个参数： 
    #GRUB_CMDLINE_LINUX: 启动系统的基本参数
    #GRUB_CMDLINE_EXTRA：在10_linux等脚本动态地根据系统环境调整，默认为空。
    #GRUB_CMDLINE_LINUX_DEFAULT：quit、splash等

    # iommu=usedac: 对于16年联想台式机中amd显卡，联想提供的一个驱动程序需要这个参数，负责人贺春妮. GE版本也需要支持。
    #
    sudo sed -i  's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="iommu=usedac /' $ROOTFS/etc/default/grub
    # 如果recordfail=1, 仍然自动倒计时启动系统
    echo "GRUB_RECORDFAIL_TIMEOUT=10" | sudo tee -a $ROOTFS/etc/default/grub 

    #当conf-hooks.d中没有配置文件设置FRAMEBUFFER=y时，framebuffer 和 plymouth 这两个hook就会被mkinitramfs忽略，最终导致plymouth没有集成到initrd、启动较晚、启动黑屏时间长的问题。 crptsetup这个包设置了这个变量，但是oem-config会删除这个包。
    echo "FRAMEBUFFER=y" | sudo tee $ROOTFS/usr/share/initramfs-tools/conf-hooks.d/nfs    
    # 
    source $T/build/core/post_install_${EDITION}.sh

    if [ -n $PRODUCT ];then
      unset pro
      for it in `echo $PRODUCT | sed 's/-/ /g'`
      do 
         [[ -n $pro ]] && pro="$pro-$it" || pro=$it
         if ! [[ -f $T/build/core/post_install_$pro.sh ]];then  
               echo "Error: File post_install_$pro  does not exit"
               continue
         fi
	 echo "zuo dbg: running product post_install: $pro"
         if [[ $pro != $EDITION ]];then
            source $T/build/core/post_install_$pro.sh
         fi
      done
    fi
    sudo chroot $OUT/out/squashfs-root /bin/bash -c  "update-grub2" || return 1

    #下面的需要调整，不同的版本应该使用不同的仓库配置
    sudo cp $T/build/release/sources_outward.list $ROOTFS/etc/apt/sources.list.d/official-package-repositories.list 
#    || sudo cp $T/build/release/sources_${EDITION}.list $ROOTFS/etc/apt/sources.list.d/official-package-repositories.list
    sudo rm $ROOTFS/etc/apt/sources.list 
    #请不要在下面添加内容
    echo "***************Postinstall finished*******************"
