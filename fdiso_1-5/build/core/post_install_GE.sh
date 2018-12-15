echo "Enter post_install: post_install_GE.sh"
# 集成了 linux-crashdump ，调整一些参数
echo "===这个版本集成了kdump功能"
sudo sed -i 's/crashkernel=384M-2G:64M,2G-:128M/crashkernel=384M-:256M/g' $ROOTFS/etc/grub.d/10_linux
sudo sed -i 's/crashkernel=384M-:128M//g' $ROOTFS/etc/default/grub.d/kexec-tools.cfg
sudo sed -i 's/crashkernel=384M-:128M//g' $ROOTFS/etc/default/grub

sudo sed -i 's/USE_KDUMP=0/USE_KDUMP=1/' $ROOTFS/etc/default/kdump-tools
sudo sed -i 's/#KDUMP_CMDLINE_APPEND="irqpoll maxcpus=1 nousb"/KDUMP_CMDLINE_APPEND="irqpoll maxcpus=1 nousb text"/' $ROOTFS/etc/default/kdump-tools
