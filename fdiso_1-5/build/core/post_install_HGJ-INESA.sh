echo "Enter post_install: post_install_HGJ_INESA.sh"
sudo chroot $OUT/out/squashfs-root /bin/bash -c "mkdir -p /usr/local/nfsdrivers"
sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /usr/local/nfsdrivers;apt-get --allow-unauthenticated -y download s3-linux-graphics-driver-2d3d-only"
