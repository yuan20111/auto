function hh() {
cat <<EOF
Invoke ". build/envsetup.sh" from your shell to add the following functions to your environment:
- croot:     Changes directory to the top of the tree.
- cmaster:   repo forall -c git checkout -b master remotes/m/master
- check:     Check the tools and dependencies to should be installed.
- getprepkg: Get raw iso and some deb packages such as wps.
- cclean:    Clean the workout dir excepte raw mint.iso and $PREAPP dir.
- m:         Build the package and clean the source dir in the current directory.
- mm:        Build the package and not clean the source dir in the current directory.
- mi:        Build and install the package and clean the source dir in the current directory.
- mos:       Build all and generate iso.
- mall:      Build all packages in $OSNAME and desktop dir, and then move these .deb .tar.gz .dsc .changes file to workout/app dir.
- uniso:     Export iso file to workout/out dir.
- mkiso:     Generate iso file into workout dir from workout/out file.
- runiso:    Run iso by kvm command.
- flashiso:  Flash iso by usb-creator-gtk command.
- cgrep:     Greps on all local C/C++ files.
- psgrep:    Greps on all local py js files.
- jgrep:     Greps on all local Java files.
- godir:     Go to the directory containing a file.
- hos:       show more help.

Look at the source to view more functions. The complete list is:
EOF
    T=$(gettop)
    local A
    A=""
    for i in `cat $T/build/envsetup.sh | sed -n "/^function /s/function \([a-z_]*\).*/\1/p" | sort`; do
      A="$A $i"
    done
    echo $A
}

function hos()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi

    cat $T/docs/repo_help.txt | more
}

function repo()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    
    $T/.repo/repo/repo $*

    if [ $# -eq 1 ] ; then
        if [ "$1" == "sync" ] ; then
            source $T/build/envsetup.sh
        fi
    fi
}

function resource()
{
    source $T/build/envsetup.sh
}

function setenv()
{
    os_product_type=
    os_build_version=
    iso_file_name=

    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi

    if [ $# -ne 4 ] && [ $# -ne 5 ];then
        echo "Usage: source ../build/envsetup.sh VERSION, for example source ../build/envsetup.sh '1.5' '0827' 'GE' '07', or source ../build/envsetup.sh '1.5' '0827' 'HGJ-OEM' '07' 'lenovo'".
        return 1
    fi    
    export version_iso="$@"
    echo $version_iso | grep -qi "OEM"  && export FLAG_OEM="OEM" export os_product_type="制造商"|| export FLAG_OEM="LIVE" export os_product_type="试用"
    echo $version_iso | grep -q "GE"  && export EDITION="GE" || export EDITION="HGJ"
    echo $version_iso | grep -q "PERSONAL"  && export os_product_type=$os_product_type"个人"
    #echo $version_iso | grep -q "\-DE"  && export FLAG_DE="DE" || export FLAG_DE="UNDE"
    #echo $version_iso | grep -qi "\-2os"  && export FLAG_OS="DBL" || export FLAG_OS="SGL"
    #echo $version_iso | grep -qi "\-testdeb"  && export FLAG_TESTDEB="TRUE" || export FLAG_TESTDEB="FALSE"
    
    #don't use sed s 
    if [ "$1" = "1.5" ]; then
        export os_build_version="15"
    elif [ "$1" = "2.0" ]; then
        export os_build_version="20"
    fi
    #master_version= echo "$1" | sed 's/\.//g'
    #export os_build_version=$master_version
    #echo "$os_build_version"
    #$master_version1="$os_build_version"".$2"
   
    export os_build_version=$os_build_version"."$2

    if [ "$EDITION" = "HGJ" ]; then
        export os_product_type="核高基$os_product_type"
        export os_build_version=$os_build_version".H"
    elif [ "$EDITION" = "GE" ]; then
        export os_build_version=$os_build_version".G"
    fi
    #elif [ "$EDITION" = "DEV" ]; then
    #    export os_build_version=$os_build_version".2"
    #fi
  
    if [ "$FLAG_OEM" = "OEM" ]; then
        export os_build_version=$os_build_version"O"
    else
        export os_build_version=$os_build_version"L"
    fi
    echo $version_iso | grep -q "PERSONAL"  && export os_build_version=$os_build_version"P"
    export os_product_type="$os_product_type版"

    export os_product_version="$1"
    export os_build_version=$os_build_version$4
    export os_product_type_en="$3"
    export special_factory="$5" 
    
    #echo "$os_build_version"
    type_file_name=`echo "$os_build_version" | sed 's/\./_/g'` 
    export iso_file_name="NFS_Desktop-64bit-"$type_file_name
    export ISOFILENAME=$iso_file_name".iso"
  
 
    echo "===========set env echo==========="
    echo "$EDITION"
    echo "$FLAG_OEM"
    echo "ostype = $os_product_type"
    echo "$special_factory"
    echo "iso_file_name = $ISOFILENAME"
    echo "===========set env finish==========="
    . $T/build/set_version.sh 
    . $T/build/core/build_fd.sh
    export OSARCH=amd64
    export BASE_RELEASE=trusty
    export BASE_RELEASE_WEB=http://192.168.160.169/cos3/ubuntu/

    export T
    export OUT=$T/workout
    export OUTPATH=$T/workout/out
    export ROOTFS=$OUT/out/squashfs-root
    export APPOUT=debsaved
    export PREAPP=preapp
    export BUILDOSDIRS="$OSNAME mint desktop"
    export REPODIRNAME=repository
    export REPOSITORY=$OUT/$REPODIRNAME
    export BUILDOSSTEP=$OUT/out/buildosstep
    export RAWSQUASHFSNAME=filesystem-linuxmint-15-cinnamon-32bit.squashfs
    export RAWSQUASHFSNAME_SRC=filesystem-zhoupeng-20140108.squashfs
    export ISOPATH=$OUT/$RAWSQUASHFSNAME
    export RAWSQUASHFSADDRESS=box@192.168.162.142:/home/box/Workspace/Public/$RAWSQUASHFSNAME
    export RAWPREAPPADDRESS=box@192.168.162.142:/home/box/Workspace/Public/app/
    if [[ $EDITION == "HGJ" ]];then
       export KERNEL_VERSION=3.19.0
       export KERNEL_VERSION_FULL=3.19.0-cdos
    elif [[ $EDITION == "GE" ]];then
       export KERNEL_VERSION=3.19.8
       export KERNEL_VERSION_FULL=3.19.8
    else
       unset KERNEL_VERSION
       echo "EDITION type error"
    fi
    unset PRODUCT  
    unset rel_type  
}

function addcompletions()
{
    local T dir f

    # Keep us from trying to run in something that isn't bash.
    if [ -z "${BASH_VERSION}" ]; then
        return 1
    fi

    # Keep us from trying to run in bash that's too old.
    if [ ${BASH_VERSINFO[0]} -lt 3 ]; then
        return 1
    fi

    dir="sdk/bash_completion"
    if [ -d ${dir} ]; then
        for f in `/bin/ls ${dir}/[a-z]*.bash 2> /dev/null`; do
            echo "including $f"
            . $f
        done
    fi
}

function gettop
{
    local TOPFILE=build/envsetup.sh
    if [ -n "$TOP" -a -f "$TOP/$TOPFILE" ] ; then
        echo $TOP
    else
        if [ -f $TOPFILE ] ; then
            # The following circumlocution (repeated below as well) ensures
            # that we record the true directory name and not one that is
            # faked up with symlink names.
            PWD= /bin/pwd
        else
            # We redirect cd to /dev/null in case it's aliased to
            # a command that prints something as a side-effect
            # (like pushd)
            local HERE=$PWD
            T=
            while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
                cd .. > /dev/null
                T=`PWD= /bin/pwd`
            done
            cd $HERE > /dev/null
            if [ -f "$T/$TOPFILE" ]; then
                echo $T
            fi
        fi
    fi
}

function croot()
{
    T=$(gettop)
    if [ "$T" ]; then
        cd $(gettop)
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function cmaster()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    
    repo forall -c git checkout -b master remotes/m/master
    repo forall -c git config push.default upstream
}

function checktools()
{
    command -v unsquashfs > /dev/null
    if [ ! $? == 0 ] ; then
        echo ERROR: squashfs-tools has not been installed.
        command -v reprepro > /dev/null
        if [ ! $? == 0 ] ; then
            echo ERROR: reprepro has not been installed.
        fi
        return 1
    fi
    command -v reprepro > /dev/null
    if [ ! $? == 0 ] ; then
        echo ERROR: reprepro has not been installed.
        return 1
    fi
    return 0
}

function check()
{
    checktools || return 1
    checkdepall || return 1
}

function checkdep()
{
    tmpstr=`dpkg-checkbuilddeps 2>&1`
    tmpres=$?
    echo $tmpstr | awk '{gsub(/\([^\(\)]*\)/, ""); print}'
    return $tmpres
}

function checkdepall()
{
    T=$(gettop)
    if [ "$T" ]; then
        CURDIR=$PWD
        echo check build dependencies and conflicts of all deb package
        echo
        for maindir in $BUILDOSDIRS
        do
            for dir in `ls $T/$maindir | sort`
            do
                if [ -d $T/$maindir/$dir ] ; then
                    cd $T/$maindir/$dir
                    echo checking dependencies of $dir
                    tmpstr=`dpkg-checkbuilddeps 2>&1`
                    tmpres=$?
                    echo $tmpstr | awk '{gsub(/\([^\(\)]*\)/, ""); print}'
                fi
            done 
        done
        echo
        echo Finish checking building deb packages
        cd $CURDIR
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function uniso()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ ! -e $OUT/out ] ; then
        mkdir -p $OUT/out
    fi
    checktools || return 1
    sudo sh $T/build/uniso.sh $ISOPATH $OUT/out || return 1
    sudo sh $T/build/livecd/create_livecd.sh $OUT/out || return 1
}

function mkiso()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    umountdir
    if [ $# -gt 0 ] ; then
        sudo sh $T/build/mkiso.sh $OUT/out $OUT $1 || return 1
    else
        sudo sh $T/build/mkiso.sh $OUT/out $OUT || return 1
    fi
}

function mkiso_debug()
{
    if [ $# -lt 3 ] ; then
        echo You should execute this cmd with three param at least as follow:
        echo "mkiso_debug xxx.iso OUTPATH APPPATH"
        return 1
    fi

    if [ ! -d $2 ] ; then
        echo You should make sure the OUTPATH $1 is a dir
        return 1
    fi

    if [ ! -d $3 ] ; then
        echo You should make sure the APPPATH $2 is a dir
        return 1
    fi

    T=$(gettop)
    if [ ! "$T" ]; then
        echo "fail to locate the top of the tree.  Try setting TOP."
        return 1
    fi

    sudo sh $T/build/debug/installkdump.sh $2 $3 || return 1
    mkiso $1 || return 1
    sudo sh $T/build/debug/uninstallkdump.sh $2 $3 || return 1
}

function mkiso_oem()
{
    if [ $# -lt 3 ] ; then
        echo You should execute this cmd with three param at least as follow:
        echo "mkiso_oem xxx.iso OUTPATH APPPATH"
        return 1
    fi

    if [ ! -d $2 ] ; then
        echo You should make sure the OUTPATH $2 is a dir
        return 1
    fi

    if [ ! -d $3 ] ; then
        echo You should make sure the APPPATH $3 is a dir
        return 1
    fi

    T=$(gettop)
    if [ ! "$T" ]; then
        echo "fail to locate the top of the tree.  Try setting TOP."
        return 1
    fi

    sudo sh $T/build/oem/preoem.sh $2 $3 || return 1
    umountdir
    if [ $# -gt 0 ] ; then
        sudo sh $T/build/oem/mkiso_oem.sh $OUT/out $OUT $1 || return 1
    else
        sudo sh $T/build/oem/mkiso_oem.sh $OUT/out $OUT || return 1
    fi
    sudo sh $T/build/oem/postoem.sh $2 $3 || return 1
}




#Create link libudev.so.0 -> libudev.so.1
function createlink()
{
    paths=(
        "/lib/x86_64-linux-gnu/libudev.so.1" # Ubuntu, Xubuntu, Mint
        "/usr/lib64/libudev.so.1" # SUSE, Fedora
        "/usr/lib/libudev.so.1" # Arch, Fedora 32bit
        "/lib/i386-linux-gnu/libudev.so.1" # Ubuntu 32bit
    )
    for i in "${paths[@]}"
    do
        if [ -f $i ] ; then
        dirpath=$(dirname $i)
        if [ ! -e $dirpath/libudev.so.0 ] ; then
            sudo ln -sf "$i" $dirpath/libudev.so.0
        fi
        echo "create link succefull "
        break
        fi
    done
}



function getprepkg ()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -e $OUT ] ; then
            mkdir $OUT
        fi
        cd $(gettop)
        sh $T/build/core/getprepackage.sh $OUT $OUT/$PREAPP $RAWSQUASHFSADDRESS $RAWPREAPPADDRESS || return 1
        addrepository $OUT/$PREAPP/gir1.2-gtop-2.0_2.28.4-3_i386.deb || return 1
        addrepository $OUT/$PREAPP/libfcitx-qt5-0_0.1.1-2_i386.deb || return 1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function mountdir()
{
    if [ -e $OUT/out/squashfs-root/proc/mounts ] ; then
        sudo umount $OUT/out/squashfs-root/sys
        sudo umount $OUT/out/squashfs-root/dev/pts
        sudo umount $OUT/out/squashfs-root/dev
        sudo umount $OUT/out/squashfs-root/proc
    fi
    sudo mount -t devtmpf -o bind /dev $OUT/out/squashfs-root/dev || return 1
    sudo mount -t proc proc $OUT/out/squashfs-root/proc || return 1
    sudo mount none -t devpts $OUT/out/squashfs-root/dev/pts || return 1
    sudo mount none -t sysfs $OUT/out/squashfs-root/sys || return 1
}

function umountdir()
{
    RETVALUE=0
    sudo umount $OUT/out/squashfs-root/sys
    if [[ "$?" -ne "0" && "$?" -ne "1" ]] ; then
	$RETVALUE=2
    fi
    sudo umount $OUT/out/squashfs-root/dev/pts
    if [[ "$?" -ne "0" && "$?" -ne "1" ]] ; then
        $RETVALUE=2
    fi
    sudo umount $OUT/out/squashfs-root/dev
    if [[ "$?" -ne "0" && "$?" -ne "1" ]] ; then
        $RETVALUE=2
    fi
    sudo umount $OUT/out/squashfs-root/proc
    if [[ "$?" -ne "0" && "$?" -ne "1" ]] ; then
        $RETVALUE=2
    fi
    if [ -e $OUT/out/squashfs-root/repository ] ; then
        sudo umount $OUT/out/squashfs-root/repository
        if [[ "$?" -ne "0" && "$?" -ne "1" ]] ; then
            $RETVALUE=2
        fi
    fi
    return $RETVALUE
}

function cmove()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -f debian/rules ] ; then
            echo ERROR: No file debian/rules founded. Maybe this is not a debian package source dir.
            return 1
        fi
        isclean=1
        if [ $# -ge 1 ] ; then
            for i in "$@"
            do
    	    if [[ "$i" == "--built" ]] ; then
                    isclean=0
                fi
            done 
        fi
        dir=$(basename $PWD)
        maindir=$(basename $(dirname $PWD))
        if [ ! -d $OUT/$APPOUT/$maindir/$dir ] ; then
            mkdir -p $OUT/$APPOUT/$maindir/$dir || return 1
        fi
        for file in `ls ../ | sort`
        do
            if [ -f ../$file ] ; then
                if [ $isclean -eq 0 ] ; then
                    mv -f ../$file $OUT/$APPOUT/$maindir/$dir/ || return 1
                else
                    rm -f ../$file || return 1
                fi
            fi
        done 
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function cclean()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    echo Warning: These dirs or files in workout/ follow will be remove:

    CONDITION="N"
    dirclean=out
    if [ $# -ge 1 ] ; then
        for i in "$@"
        do
            if [[ "$i" == "-Y" || "$i" == "-y" ]] ; then
                CONDITION="Y"
	    elif [[ "$i" == "out" ]] ; then
                dirclean="out"
	    elif [[ "$i" == "app" ]] ; then
                dirclean="$APPOUT $REPODIRNAME"
	    elif [[ "$i" == "all" ]] ; then
                dirclean="out $APPOUT $REPODIRNAME"
	    else
                echo Error: unknown param $i
	        echo -y: You can ensure remove these above dirs or files -Y/-y
                echo out: You can remove only out dir
                echo app: You can remove $APPOUT $REPODIRNAME dir
                echo all: You can remove out $APPOUT $REPODIRNAME dir
                return
	    fi
        done 
    fi
    if [ $CONDITION == "N" ] ; then
        echo $OUT/ $dirclean
        read -p "Are you sure to remove these above dirs or files  Y/N:" answer
        CONDITION="$answer"
    fi

    if [[ "$CONDITION" == "Y" || "$CONDITION" == "y" ]] ; then
        echo Removing start...
        echo Umounting dir...
        umountdir 2>/dev/null
        mount | grep $OUT/out/squashfs-root
        sudo chattr -i $OUT/out/squashfs-root/etc/os-release
	if [ "$?" -eq "0" -o -e $OUT/out/squashfs-root/proc/mounts ] ; then
            echo "The device can not be umounted now... Please restart the computer and try it again!"
            echo move squashfs-root/dev+proc+sys to another tmpdir
            todeldir="bin boot etc home lib media mnt opt root run sbin selinux src tmp usr var"
            for dir in $todeldir
            do
                if [ -e $OUT/out/squashfs-root/$dir ] ; then
                    echo Deleting $OUT/out/squashfs-root/$dir ...
                    sudo rm -rf $OUT/out/squashfs-root/$dir
                fi
            done
            sudo rm -rf $OUT/out/"$OSNAME"
            cd $OUT/
            mv out out_$(date +%Y%m%d%H%M)

            #sudo fuser -k $OUT/out/squashfs-root
            #umountdir 2>/dev/null
            #mount | grep $OUT/out/squashfs-root
            #if [ "$?" -ne "0" ] ; then
            #    echo "The device can not be umounted now... Please restart the computer and try it again!"
            #    return 1
            #fi
	fi
        for dir in $dirclean
        do
            if [  -e $OUT/$dir ] ; then
                echo Deleting $OUT/$dir ...
                sudo rm -rf $OUT/$dir
            fi
        done
        echo Finished cleaning dir.
    else
        echo Removing is cancelled.
    fi
}

function ccleanout()
{
    cclean out
}

function addrepository()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -e $REPOSITORY/debian/conf ] ; then
            mkdir -p $REPOSITORY/debian/conf
        fi
        if [ ! -f $REPOSITORY/debian/conf/distributions ] ; then
            echo "Origin: Debian
Label: Debian
Codename: iceblue
Architectures: i386
Components: main" > $REPOSITORY/debian/conf/distributions
        fi
        reprepro -b $REPOSITORY/debian remove iceblue `dpkg -f $1 Package`
        reprepro -b $REPOSITORY/debian includedeb iceblue $1 || return 1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function listappinrep()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -e $REPOSITORY/debian/conf ] ; then
            mkdir -p $REPOSITORY/debian/conf
        fi
        if [ ! -f $REPOSITORY/debian/conf/distributions ] ; then
            echo "Origin: Debian
Label: Debian
Codename: iceblue
Architectures: i386
Components: main" > $REPOSITORY/debian/conf/distributions
        fi
        reprepro -b $REPOSITORY/debian list iceblue
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    
}

function uninstallmintdeb()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -e $OUT/out/squashfs-root ] ; then
            echo Error: No squashfs-root dir exist. Have you executed mos or uniso once?
            return 1
        fi
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --purge ubuntu-system-adjustments mint-mdm-themes mint-local-repository mint-meta-codecs mint-flashplugin mint-flashplugin-11 mint-meta-cinnamon mint-meta-core mint-search-addon mint-stylish-addon mintdrivers mint-artwork-cinnamon mintsources mintbackup mintstick mintwifi mint-artwork-gnome mint-artwork-common mint-backgrounds-olivia mintsystem mintwelcome mintinstall mintinstall-icons mintnanny mintupdate mintupload mint-info-cinnamon mint-common mint-mirrors mint-translations"
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --force-all --purge mint-themes mint-x-icons " || return 1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function uninstalldebbyapt()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ $# -lt 1 ] ; then
        echo Error: no debname param
        return 1
    fi
    if [ ! -e $OUT/out/squashfs-root ] ; then
        echo Error: No squashfs-root dir exist. Have you executed mos or uniso once?
        return 1
    fi
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get --ignore-missing --yes --force-yes purge $@" || return 1
}

function uninstalldeb()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ $# -lt 1 ] ; then
        echo Error: no debname param
        return 1
    fi
    if [ ! -e $OUT/out/squashfs-root ] ; then
        echo Error: No squashfs-root dir exist. Have you executed mos or uniso once?
        return 1
    fi
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --purge $@" || return 1
}

function installdebonline()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ $# -lt 1 ] ; then
        echo Error: no debname param
        return 1
    fi
    if [ ! -e $OUT/out/squashfs-root ] ; then
        echo Error: No squashfs-root dir exist. Have you executed mos or uniso once?
        return 1
    fi
    deblist=""
    debnum=`echo $@ | wc -w`
    if [ $debnum -gt 1 ] ; then
        for name in $@
        do
            while read line
            do
                if [ "$name" == "$line" ] ; then
                    continue 2
                fi
            done < $T/build/core/ignorepackage
            deblist=`echo $deblist $name`
            echo $deblist
        done
    else
        deblist="$@"
    fi
    echo These deb package $deblist will be installed in $OUT/out/squashfs-root
    mountdir || return 1

    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get update" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get install -y --force-yes --reinstall $deblist" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get clean" || return 1
    echo `echo $deblist | wc -w` package\(s\) has been installed.

    umountdir || return 1
}

function installdebtolocal()
{
    installdeb --root / $*
}

function installdeb()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    rootdir=$OUT/out/squashfs-root
    if [ $# -gt 2 ] ; then
        if [ "$1" == "--root" ] ; then
            if [ "$2" == "/" ] ; then
                rootdir=
            else
                rootdir=$2
            fi
            shift 2
        fi
    fi
    if [ $# -lt 1 ] ; then
        echo Error: no debname param
        return 1
    fi
    if [ ! -e $rootdir/ ] ; then
        echo Error: No squashfs-root dir exist. Have you executed mos or uniso once?
        return 1
    fi
    deblist=""
    debnum=`echo $@ | wc -w`
    if [ $debnum -gt 1 ] ; then
        for name in $@
        do
            while read line
            do
                if [ "$name" == "$line" ] ; then
                    continue 2
                fi
            done < $T/build/core/ignorepackage
            deblist=`echo $deblist $name`
        done
    else
        deblist="$@"
    fi
    echo These deb package $deblist will be installed in $rootdir/
    localrepo=$rootdir/repository
    if [ -e $localrepo ] ; then
        sudo umount $localrepo
    else
        sudo mkdir $localrepo
    fi
    sudo mount --bind $REPOSITORY $localrepo
    if [ "$rootdir/" == "/" ] ; then
        mountdir || return 1
    fi

    mkdir -p $rootdir/tmp/apt/root/
    mkdir -p $rootdir/tmp/apt/root/state
    mkdir -p $rootdir/tmp/apt/root/cache
    mkdir -p $rootdir/tmp/apt/root/etc
    mkdir -p $rootdir/tmp/apt/root/etc/preferences.d
    mkdir -p $rootdir/tmp/apt/root/var/log/apt/
    echo "deb file:///repository/debian iceblue main" > $rootdir/tmp/apt/root/etc/sources.list
    sudo chroot $rootdir/ /bin/bash -c "sudo apt-get update -o Dir=/tmp/apt/root/ -o Dir::State=state -o Dir::Cache=cache -o Dir::Etc=etc -o Dir::Etc::sourcelist=sources.list -o APT::Get::List-Cleanup=0" || return 1
    sudo chroot $rootdir/ /bin/bash -c "sudo apt-get install -y --force-yes --reinstall -o Dir=/tmp/apt/root/ -o Dir::State=state -o Dir::Cache=cache -o Dir::Etc=etc -o Dir::Etc::sourcelist=sources.list -o APT::Get::List-Cleanup=0 $deblist" || return 1
    echo `echo $deblist | wc -w` package\(s\) has been installed.
    sudo rm -rf $rootdir/tmp/apt

    sudo umount $localrepo
    sudo rmdir $localrepo
    if [ "$rootdir/" == "/" ] ; then
        umountdir
    fi
}

function installdeball()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    ISONLINE=0
    for i in "$@"
    do
        if [ "$i" == "--online" ] ; then
            ISONLINE=1
        fi
    done
    deblist=""
    for line in `listappinrep | cut -f 2 -d ' ' | sort`
    do
       deblist=`echo $deblist $line` 
    done
    if [ $ISONLINE -eq 0 ] ; then
        installdeb $deblist || return 1
    else
        installdebonline $deblist || return 1
    fi
}

function runiso()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    echo
    i=0
    for file in `ls $OUT/ | grep iso | sort`
    do
        echo -    $i : $file
        ((i++))
    done 
    echo You can choose one iso as above to run by kvm.
    read -p "Enter number:" no
    i=0
    for file in `ls $OUT/ | grep iso | sort`
    do
        if [ "$i" == "$no" ] ; then
            echo ======
            echo Tips: After kvm running, you can press any key to continue. 
            echo ======
            echo command: kvm -m 512 -cdrom ${OUT}/$file -boot order=d
            kvm -m 512 -cdrom ${OUT}/$file -boot order=d &
            break
        fi
        ((i++))
    done 
}

function flashiso()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    echo

    command -v usb-creator-gtk > /dev/null
    if [ ! $? == 0 ] ; then
        echo Error: usb-creator-gtk is not installed. You can install it by enter the follow command.
        echo sudo apt-get install usb-creator-gtk
        return 1
    fi

    creator_version=`dpkg -s usb-creator-gtk | grep Version | cut -d ' ' -f 2`
    if [ $creator_version \< "0.2.47.2" ] ; then
        if [ $# -eq 0 ] || [ ! $1 == "-f" ] ; then
            echo Error: the version of usb-creator-gtk is less than 0.2.47.2, so maybe you will get core dump error when executing.
            echo You can ignore this check with -f param.
            echo Or you can update it now with the following command.
            echo sudo apt-get install usb-creator-gtk
            return 1
        fi
    fi

    i=0
    for file in `ls $OUT/ | grep iso | sort`
    do
        echo -    $i : $file
        ((i++))
    done
    echo You can choose one iso as above to flash by usb-creator-gtk.
    read -p "Enter number:" no
    i=0
    for file in `ls $OUT/ | grep iso | sort`
    do
        if [ "$i" == "$no" ] ; then
            echo ======
            echo command: usb-creator-gtk -i ${OUT}/$file -n
            usb-creator-gtk -i ${OUT}/$file -n
            break
        fi
        ((i++))
    done
}

function pid()
{
   local EXE="$1"
   if [ "$EXE" ] ; then
       local PID=`adb shell ps | fgrep $1 | sed -e 's/[^ ]* *\([0-9]*\).*/\1/'`
       echo "$PID"
   else
       echo "usage: pid name"
   fi
}

case `uname -s` in
    Darwin)
        function sgrep()
        {
            find -E . -name .repo -prune -o -name .git -prune -o  -type f -iregex '.*\.(c|h|cpp|S|java|xml|sh|mk)' -print0 | xargs -0 grep --color -n "$@"
        }

        ;;
    *)
        function sgrep()
        {
            find . -name .repo -prune -o -name .git -prune -o  -type f -iregex '.*\.\(c\|h\|cpp\|S\|java\|xml\|sh\|mk\)' -print0 | xargs -0 grep --color -n "$@"
        }
        ;;
esac

function jgrep()
{
    find . -name .repo -prune -o -name .git -prune -o  -type f -name "*\.java" -print0 | xargs -0 grep --color -n "$@"
}

function psgrep()
{
    find . -name .repo -prune -o -name .git -prune -o  -type f \( -name '*.py' -o -name '*.js' \) -print0 | xargs -0 grep --color -n "$@"
}

function cgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.h' \) -print0 | xargs -0 grep --color -n "$@"
}


case `uname -s` in
    Darwin)
        function mgrep()
        {
            find -E . -name .repo -prune -o -name .git -prune -o  -type f -iregex '.*/(Makefile|Makefile\..*|.*\.make|.*\.mak|.*\.mk)' -print0 | xargs -0 grep --color -n "$@"
        }

        function treegrep()
        {
            find -E . -name .repo -prune -o -name .git -prune -o -type f -iregex '.*\.(c|h|cpp|S|java|xml)' -print0 | xargs -0 grep --color -n -i "$@"
        }

        ;;
    *)
        function mgrep()
        {
            find . -name .repo -prune -o -name .git -prune -o -regextype posix-egrep -iregex '(.*\/Makefile|.*\/Makefile\..*|.*\.make|.*\.mak|.*\.mk)' -type f -print0 | xargs -0 grep --color -n "$@"
        }

        function treegrep()
        {
            find . -name .repo -prune -o -name .git -prune -o -regextype posix-egrep -iregex '.*\.(c|h|cpp|S|java|xml)' -type f -print0 | xargs -0 grep --color -n -i "$@"
        }

        ;;
esac


function godir () {
    if [[ -z "$1" ]]; then
        echo "Usage: godir <regex>"
        return 1
    fi
    T=$(gettop)
    if [[ ! -f $T/filelist ]]; then
        echo -n "Creating index..."
        (cd $T; find . -wholename ./out -prune -o -wholename ./.repo -prune -o -type f > filelist)
        echo " Done"
        echo ""
    fi
    local lines
    lines=($(\grep "$1" $T/filelist | sed -e 's/\/[^/]*$//' | sort | uniq))
    if [[ ${#lines[@]} = 0 ]]; then
        echo "Not found"
        return 1
    fi
    local pathname
    local choice
    if [[ ${#lines[@]} > 1 ]]; then
        while [[ -z "$pathname" ]]; do
            local index=1
            local line
            for line in ${lines[@]}; do
                printf "%6s %s\n" "[$index]" $line
                index=$(($index + 1))
            done
            echo
            echo -n "Select one: "
            unset choice
            read choice
            if [[ $choice -gt ${#lines[@]} || $choice -lt 1 ]]; then
                echo "Invalid choice"
                continue
            fi
            pathname=${lines[$(($choice-1))]}
        done
    else
        pathname=${lines[0]}
    fi
    cd $T/$pathname
}

if [ "x$SHELL" != "x/bin/bash" ]; then
    case `ps -o command -p $$` in
        *bash*)
            ;;
        *)
            echo "WARNING: Only bash is supported, use of other shell would lead to erroneous results"
            ;;
    esac
fi
setenv $@
addcompletions
echo "提示：发行版本请执行：mkiso_for_product"
rm log >/dev/null 2>&1 
