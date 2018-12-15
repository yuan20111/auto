#/bin/bash
echo "$@"
export OSNAME="NFS Desktop"
export OSFULLNAME="NFS Desktop Operating System"
export OSISSUE=`date +%F`
export OSNAMEZH="方德桌面"
export OSFULLNAMEZH="方德桌面操作系统"
export OSPRODUCTVERSION="$os_product_version"
export OSBUILDVERSION="$os_build_version"
export OSPRODUCTTYPEZH="$os_product_type"
export OSPRODUCTTYPE="$os_product_type_en"
export OSVERSIONNAME=
export OSVERSIONFULLNAME="NFS $OSPRODUCTVERSION $OSPRODUCTTYPE"
export OSRELEASEURL=release_URL
echo "OSVERSION=$OSPRODUCTVERSION $OSPRODUCTTYPE $OSBUILDVERSION ===$OSVERSIONFULLNAME===,when set version"
