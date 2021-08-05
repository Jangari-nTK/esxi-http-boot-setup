IP_ADDR=`ip addr show dev ens192 | grep "inet " | sed -r "s#.*inet (.*)/.*#\1#"`
DIR_NAME=esxi70u2

mkdir /mnt/cdrom
mount /dev/cdrom /mnt/cdrom

BOOT_IMAGE_DIR=/var/www/html/$DIR_NAME
mkdir $BOOT_IMAGE_DIR
cp -R /mnt/cdrom/* $BOOT_IMAGE_DIR

chmod -R 755 $BOOT_IMAGE_DIR
restorecon -Rv $BOOT_IMAGE_DIR

BOOT_CFG=$BOOT_IMAGE_DIR/efi/boot/boot.cfg
sed -i "s#/##g" $BOOT_CFG

BOOT_PREFIX=http://$IP_ADDR/$DIR_NAME
sed -i "s#prefix=#prefix=$BOOT_PREFIX#" $BOOT_CFG
sed -i "s#kernelopt=.*#kernelopt=ks=$BOOT_PREFIX/efi/boot/ks.cfg allowLegacyCPU=true#" $BOOT_CFG

cp ks.cfg $BOOT_IMAGE_DIR/efi/boot/ks.cfg
