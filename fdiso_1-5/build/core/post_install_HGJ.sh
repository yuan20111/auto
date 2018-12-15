echo "Enter post_install: post_install_HGJ.sh"
    # 原因?
    echo "GRUB_GFXPAYLOAD_LINUX=keep" | sudo tee -a  $OUT/out/squashfs-root/etc/default/grub
    echo "GRUB_GFXMODE=1024x768x32" | sudo tee -a  $OUT/out/squashfs-root/etc/default/grub
    
    # loglevel=3: 隐藏HGJ内核打印的一些信息
    # hibernate=nocompress: xiongke, 验证S4测试中 resume时的CRC32校验错的问题
    # panic=5 bug[0021470],Linux系统登录界面长按回车70秒或在密码输入框中重复93次输错密码可获得root权限. 添加panic=5,使输入密码错误5次自动重启系统。
    sudo sed -i  's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="panic=5 hibernate=nocompress /' $ROOTFS/etc/default/grub #放到前面
    sudo sed -i  's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& audit=0 loglevel=3/' $ROOTFS/etc/default/grub #放到尾部

    #
    sudo sed -ni '/#CDOS-3.19-kernel-specfic, more tests needed/,+2d;:go;1!{P;N;D};N;bgo' $ROOTFS/lib/udev/rules.d/42-usb-hid-pm.rules

    #联想要求，无线和usb鼠标能唤醒s3
    echo 'ACTION=="add",  SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03",ATTR{bInterfaceSubClass}=="01", ATTR{bInterfaceProtocol}=="02", TEST=="../power/wakeup", ATTR{../power/wakeup}="enabled" ' | sudo tee -a  $ROOTFS/lib/udev/rules.d/42-usb-hid-pm.rules

###################################################################
echo "Enter post_install: post_install_HGJ_INESA.sh"

sudo chroot $OUT/out/squashfs-root /bin/bash -c "mkdir -p /usr/local/nfsdrivers"
sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /usr/local/nfsdrivers;apt-get --allow-unauthenticated -y download s3-linux-graphics-driver-2d3d-only"


###################################################################
echo "Enter post_install: post_install_HGJ-LENOVO.sh"
#sudo chroot $OUT/out/squashfs-root /bin/bash -c "mkdir -p /usr/local/nfsdrivers"
sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /usr/local/nfsdrivers;apt-get --allow-unauthenticated -y download s3-linux-graphics-driver nvidia-346 fglrx fglrx-amdcccle fglrx-core fglrx-dev tl-wn725n backports-4.4.2-1 hotkey-init backports-20150903"

###################################################################
echo "Enter post_install: post_install_HGJ-LENOVO-PC.sh"

#因为s3g驱动的缺陷没有解决，联想要求屏蔽关机动画,研发负责人是黄明明
#sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm -f /etc/init/plymouth-shutdown.conf"

#将台式机屏幕亮度调节功能去除,因其本身在PC上不可用,黄明明,吕非
#sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm -rf /usr/share/cinnamon/applets/brightness@cinnamon.org"

###################################################################
echo "Enter post_install: post_install_HGJ-LENOVO-LAPTOP.sh"

###################################################################
#联想笔记本usb3.0插3.0接口，关机或者重启卡死，方案：卸载usb驱动
RMMODUSBFILE6=$OUT/out/squashfs-root//etc/rc6.d/S59rmmodusb
RMMODUSBFILE0=$OUT/out/squashfs-root//etc/rc0.d/S59rmmodusb
sudo touch $RMMODUSBFILE0; sudo chmod 777 $RMMODUSBFILE0
sudo touch $RMMODUSBFILE6; sudo chmod 777 $RMMODUSBFILE6
cat << EOF  | sudo tee  $RMMODUSBFILE0
#!/bin/bash
rmmod usb_storage
EOF
cat << EOF  | sudo tee  $RMMODUSBFILE6
#!/bin/bash
rmmod usb_storage
EOF

