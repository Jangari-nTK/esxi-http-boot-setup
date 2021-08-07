#!/usr/bin/env bash

source vars

# Set temporary variables
IP_ADDR=`ip addr show dev $INTERFACE | grep "inet " | sed -r "s#.*inet (.*)/.*#\1#"`
BOOT_IMAGE_DIR=/var/www/html/$DIR_NAME
BOOT_CFG=$BOOT_IMAGE_DIR/efi/boot/boot.cfg
BOOT_PREFIX=http://$IP_ADDR/$DIR_NAME

# Install httpd
yum install -y httpd
firewall-cmd --add-service=http --permanent
firewall-cmd --reload
systemctl enable --now httpd

# Setup directory for boot image
mkdir /mnt/cdrom
mount /dev/cdrom /mnt/cdrom
mkdir $BOOT_IMAGE_DIR
cp -R /mnt/cdrom/* $BOOT_IMAGE_DIR
chmod -R 755 $BOOT_IMAGE_DIR
restorecon -Rv $BOOT_IMAGE_DIR

# Configure parameters in boot.cfg
sed -i "s#/##g" $BOOT_CFG
sed -i "s#prefix=#prefix=$BOOT_PREFIX#" $BOOT_CFG
sed -i "s#kernelopt=.*#kernelopt=ks=$BOOT_PREFIX/ks.cfg allowLegacyCPU=true#" $BOOT_CFG

# Copy ks.cfg
cp ks.cfg $BOOT_IMAGE_DIR/ks.cfg
