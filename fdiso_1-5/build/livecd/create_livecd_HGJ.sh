#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
LIVECDPATH=$(cd "$(dirname $0)"; pwd)
. $LIVECDPATH/../set_version.sh
echo "$OSNAME, $OSPRODUCTVERSION, $OSPRODUCTTYPE,$OSBUILDVERSION, $OSVERSIONFULLNAME,  $OUTPATH"
isodir="$OSNAME"

SEED_NAME=`echo $OSNAME | sed 's/ //'`
SEED_NAME="$SEED_NAME.seed"
if [ ! "$OSBUILDVERSION" ] ; then
    echo Error: no OSBUILDVERSION env set.
    exit -1
fi
if [ ! "$OSPRODUCTTYPE" ] ; then
    echo Error: no OSPRODUCTTYPE env set.
    exit -1
fi
if [ ! "$OSPRODUCTVERSION" ] ; then
    echo Error: no OSPRODUCTVERSION env set.
    exit -1
fi
if [ ! "$OSVERSIONFULLNAME" ] ; then
    echo Error: no OSVERSIONFULLNAME env set.
    exit -1
fi

if [ ! -d $OUTPATH/"$isodir"/casper ] ; then
    mkdir -p $OUTPATH/"$isodir"/casper
    #echo error: there is no $isodir path
    #exit -1
fi

if [ ! -z $OUTPATH/"$isodir"/isolinux ] ; then
    rm -rf $OUTPATH/"$isodir"/isolinux
fi
mkdir $OUTPATH/"$isodir"/isolinux
if [ ! -z $OUTPATH/"$isodir"/preseed ] ; then
    rm -rf $OUTPATH/"$isodir"/preseed
fi
mkdir $OUTPATH/"$isodir"/preseed
if [ ! -z $OUTPATH/"$isodir"/.disk ] ; then
    rm -rf $OUTPATH/"$isodir"/.disk
fi
mkdir $OUTPATH/"$isodir"/.disk

cp $LIVECDPATH/files/isolinux/isolinux.bin $OUTPATH/"$isodir"/isolinux
cp $LIVECDPATH/files/isolinux/memtest86+-5.01.bin $OUTPATH/"$isodir"/isolinux/memtest
cp $LIVECDPATH/files/isolinux/vesamenu.c32 $OUTPATH/"$isodir"/isolinux
cp $LIVECDPATH/files/isolinux/splash.png $OUTPATH/"$isodir"/isolinux

# add by yuanjz 20151231 for EFI
cp -ra $LIVECDPATH/files/boot $OUTPATH/"$isodir"/
cp -ra $LIVECDPATH/files/EFI $OUTPATH/"$isodir"/

echo "zuo dbg ,create_livecd, FLAG_OEM=$FLAG_OEM"
cat <<EOF>$OUTPATH/"$isodir"/isolinux/isolinux.cfg 
default vesamenu.c32
timeout 100

menu background splash.png
menu title Welcome to $OSNAME "$OSPRODUCTVERSION $OSPRODUCTTYPE" 64-bit

menu color screen	37;40      #80ffffff #00000000 std
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #ffffffff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #ffDEDEDE #00000000 std
MENU HIDDEN
MENU HIDDENROW 8
MENU WIDTH 88
MENU MARGIN 15
MENU ROWS 5
MENU VSHIFT 7
MENU TABMSGROW 11
MENU CMDLINEROW 11
MENU HELPMSGROW 16
MENU HELPMSGENDROW 29

label live
EOF

echo "zuo dbg: beging EOF in if else"
if [ "$FLAG_OEM" = "OEM" ];then
  echo "  menu label Start $OSFULLNAME (OEM mode)" >> $OUTPATH/"$isodir"/isolinux/isolinux.cfg
  echo "zuo dbg ,create_livecd, run into oem way"
else
  echo "zuo dbg ,create_livecd, run into none oem way"
  echo "  menu label Start $OSFULLNAME" >> $OUTPATH/"$isodir"/isolinux/isolinux.cfg  
fi

echo "  kernel /casper/vmlinuz" >> $OUTPATH/"$isodir"/isolinux/isolinux.cfg

# nomodeset: 增加原因是，安装盘使用开源驱动在s3g显卡启动卡死。
# iommu=usedac：增加原因是，关于64位HGJ系统R5-340显卡驱动的适配问题，兆芯方给出的解决方案是：在grub.cfg文件的ro与quiet中间加入 iommu=usedac 项，即linux /boot/vmlinuz-3.19.0-cdos root=UUID=58fb2f09-df37-4835-9922-5e56a9c1e16e ro iommu=usedac quiet splash loglevel=3 $vt_handof 中红色标示部分。
# vga=791: 增加原因是：bug19808,集显下livecd光盘安装系统，光盘引导安装系统过程中有花屏现象，闪过，独显下也有此现象
if [ "$FLAG_OEM" = "OEM" ];then
  echo "  append  file=/cdrom/preseed/$SEED_NAME boot=casper oem-config/enable=true only-ubiquity initrd=/casper/initrd.lz nomodeset iommu=usedac vga=791  splash --" >> $OUTPATH/"$isodir"/isolinux/isolinux.cfg
else  
  echo "  append  file=/cdrom/preseed/$SEED_NAME boot=casper initrd=/casper/initrd.lz nomodeset iommu=usedac vga=791 splash --" >> $OUTPATH/"$isodir"/isolinux/isolinux.cfg
fi  

cat <<EOF >>$OUTPATH/"$isodir"/isolinux/isolinux.cfg
menu default
label xforcevesa
EOF
if [ "$FLAG_OEM" = "OEM" ];then
  echo "  menu label Start NFS  (OEM compatibility mode)" >> $OUTPATH/"$isodir"/isolinux/isolinux.cfg
else  
  echo "  menu label Start in compatibility mode" >> $OUTPATH/"$isodir"/isolinux/isolinux.cfg
fi  
echo "  kernel /casper/vmlinuz" >> $OUTPATH/"$isodir"/isolinux/isolinux.cfg
if [ "$FLAG_OEM" = "OEM" ];then
  echo "  append  file=/cdrom/preseed/$SEED_NAME boot=casper xforcevesa oem-config/enable=true only-ubiquity initrd=/casper/initrd.lz ramdisk_size=1048576 root=/dev/ram rw noapic noapci nosplash irqpoll --" >> $OUTPATH/"$isodir"/isolinux/isolinux.cfg
else  
  echo "  append  file=/cdrom/preseed/$SEED_NAME boot=casper xforcevesa nomodeset b43.blacklist=yes initrd=/casper/initrd.lz ramdisk_size=1048576 root=/dev/ram rw noapic noapci nosplash irqpoll --" >> $OUTPATH/"$isodir"/isolinux/isolinux.cfg
fi  
cat <<EOF >> $OUTPATH/"$isodir"/isolinux/isolinux.cfg
label check
  menu label Integrity check
  kernel /casper/vmlinuz
  append  boot=casper integrity-check initrd=/casper/initrd.lz quiet splash --
label memtest
  menu label Memory test
  kernel memtest
label local
  menu label Boot from local drive
  localboot 0x80
EOF

seed="# Enable extras.ubuntu.com.
#d-i	apt-setup/extras	boolean true
# Install the Ubuntu desktop.
#tasksel	tasksel/first	multiselect ubuntu-desktop
# On live DVDs, don't spend huge amounts of time removing substantial
# application packages pulled in by language packs. Given that we clearly
# have the space to include them on the DVD, they're useful and we might as
# well keep them installed.
#ubiquity	ubiquity/keep-installed	string icedtea6-plugin openoffice.org"
echo "$seed" > $OUTPATH/"$isodir"/preseed/$SEED_NAME

echo full_cd/single > $OUTPATH/"$isodir"/.disk/cd_type
echo $OSFULLNAME $OSPRODUCTVERSION $OSPRODUCTTYPE "$OSVERSIONFULLNAME" - Release \(`date +%Y%m%d`\) > $OUTPATH/"$isodir"/.disk/info
echo $OSFULLNAME $OSPRODUCTVERSION $OSPRODUCTTYPE "$OSVERSIONFULLNAME" - Release \(`date +%Y%m%d`\) > $OUTPATH/"$isodir"/.disk/mint4win
touch $OUTPATH/"$isodir"/.disk/release_notes_url
echo 423b762a-38e0-4f2d-8632-459f826c6699 > $OUTPATH/"$isodir"/.disk/casper-uuid-generic
echo 423b762a-38e0-4f2d-8632-459f826c6699 > $OUTPATH/"$isodir"/.disk/live-uuid-generic

#修改UEFI菜单和启动参数。
cat <<EOF>$OUTPATH/"$isodir"/boot/grub/grub.cfg
if loadfont /boot/grub/font.pf2 ; then
        set gfxmode=auto
        insmod efi_gop
        insmod efi_uga
        insmod gfxterm
        terminal_output gfxterm
fi

set menu_color_normal=white/black
set menu_color_highlight=black/light-gray

EOF

if [ "$FLAG_OEM" = "OEM" ];then
  echo "menuentry \"Start $OSFULLNAME (OEM mode)\"{" >> $OUTPATH/"$isodir"/boot/grub/grub.cfg
  echo "zuo dbg ,create_livecd, run into UEFI oem way"
else
  echo "zuo dbg ,create_livecd, run into UEFI way"
  echo "menuentry \"Start $OSFULLNAME \"{" >> $OUTPATH/"$isodir"/boot/grub/grub.cfg
fi
echo "    set gfxpayload=keep" >>$OUTPATH/"$isodir"/boot/grub/grub.cfg
if [ "$FLAG_OEM" = "OEM" ];then
   echo " linux /casper/vmlinuz  file=/cdrom/preseed/$SEED_NAME boot=casper oem-config/enable=true only-ubiquity nomodeset iommu=usedac  splash -- " >> $OUTPATH/"$isodir"/boot/grub/grub.cfg
else
   echo "    linux /casper/vmlinuz  file=/cdrom/preseed/$SEED_NAME boot=casper   nomodeset iommu=usedac  splash -- " >> $OUTPATH/"$isodir"/boot/grub/grub.cfg
fi
echo "    initrd  /casper/initrd.lz" >> $OUTPATH/"$isodir"/boot/grub/grub.cfg
echo '}' >>$OUTPATH/"$isodir"/boot/grub/grub.cfg


cat <<EOF>>$OUTPATH/"$isodir"/boot/grub/grub.cfg
menuentry "Check the integrity of the medium" {
        linux   /casper/vmlinuz  boot=casper integrity-check iso-scan/filename=${iso_path} splash --
        initrd  /casper/initrd.lz
}
EOF

cd -


