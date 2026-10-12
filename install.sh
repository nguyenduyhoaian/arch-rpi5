set -e

read -p 'Host name:' HOSTNAME

BOOT='/dev/nvme0n1p1'
SWAP='/dev/nvme0n1p2'
ROOT='/dev/nvme0n1p3'
DATA='/dev/nvme0n1p4'
LinuxARM="$(pwd)/ArchLinuxARM.tar.gz"
LinuxRpi16k="$(pwd)/linux-rpi-16k.pkg.tar.xz"
SetupFile="$(pwd)/setup.sh"

lsblk

echo "BOOT=$BOOT"
echo "SWAP=$SWAP"
echo "ROOT=$ROOT"
echo "DATA=$DATA"

echo '-----Format disk------'
read -p 'Cannot be undone, Sure? (y/n)' Confirm
if [ "$Confirm" != 'y' ]; then
echo 'EXIT'
exit 1
fi

sudo mkfs.vfat -F32 "$BOOT"
sudo mkswap "$SWAP"
sudo mkfs.ext4 "$ROOT"
echo 'NO format DATA PARITION'

echo '------MOUNT DISK------------'
sudo mount --mkdir "$ROOT" /mnt/arch
sudo mount --mkdir "$BOOT" /mnt/arch/boot

echo '-------bsdtar and copy--------'
sudo bsdtar -xpf "$LinuxARM" -C /mnt/arch
sudo rm -rf /mnt/arch/boot/*
mkdir -p /tmp/rpi-kernel
tar -xf "$LinuxRpi16k" -C /tmp/rpi-kernel
sudo cp -rf /tmp/rpi-kernel/boot/* /mnt/arch/boot/
sudo rm -rf /tmp/rpi-kernel

echo '----Edit /mnt/arch/etc/fstab----'
ROOTPARTUUID=$(blkid -s PARTUUID -o value "$ROOT")
BOOTPARTUUID=$(blkid -s PARTUUID -o value "$BOOT")
SWAPPARTUUID=$(blkid -s PARTUUID -o value "$SWAP")
DATAPARTUUID=$(blkid -s PARTUUID -o value "$DATA")

ROOTTYPE=$(blkid -s TYPE -o value "$ROOT")
BOOTTYPE=$(blkid -s TYPE -o value "$BOOT")
SWAPTYPE=$(blkid -s TYPE -o value "$SWAP")
DATATYPE=$(blkid -s TYPE -o value "$DATA")

sudo tee /mnt/arch/etc/fstab <<< "PARTUUID=$BOOTPARTUUID /boot $BOOTTYPE rw,nosuid,nodev,noexec,relatime,fmask=0177,dmask=0077,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro 0 2"
sudo tee -a /mnt/arch/etc/fstab <<< "PARTUUID=$SWAPPARTUUID none $SWAPTYPE defaults 0 0"
sudo tee -a /mnt/arch/etc/fstab <<< "PARTUUID=$ROOTPARTUUID / $ROOTTYPE rw,relatime 0 1"
sudo tee -a /mnt/arch/etc/fstab <<< "PARTUUID=$DATAPARTUUID /data $DATATYPE rw,relatime 0 2"

echo '----Edit /mnt/arch/boot/cmdline.txt----'
ROOTPARTUUID=$(blkid -s PARTUUID -o value "$ROOT")
sudo tee /mnt/arch/boot/cmdline.txt <<< "root=PARTUUID=$ROOTPARTUUID rw rootwait console=serial0,115200 console=tty1 fsck.repair=yes" 

sudo tee /mnt/arch/etc/hostname <<< "$HOSTNAME"
sudo sed -i 's/#Color/Color/' /mnt/arch/etc/pacman.conf
sudo sed -i 's/ParallelDownloads = 5/ParallelDownloads = 10/' /mnt/arch/etc/pacman.conf
sudo sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/arch/etc/locale.gen
sudo tee /mnt/arch/etc/locale.conf <<< 'LANG=en_US.UTF-8'

sudo tee /mnt/arch/etc/pacman.d/mirrorlist <<< 'Server = http://ca.us.mirror.archlinuxarm.org/$arch/$repo'
sudo tee -a /mnt/arch/etc/pacman.d/mirrorlist <<< 'Server = http://fl.us.mirror.archlinuxarm.org/$arch/$repo'
sudo tee -a /mnt/arch/etc/pacman.d/mirrorlist <<< 'Server = http://nj.us.mirror.archlinuxarm.org/$arch/$repo'

echo '----Copy setup.sh to root----'

sudo cp "$SetupFile" /mnt/arch

echo '----Unmount----'
sync
sudo umount /mnt/arch/boot
sudo umount -R /mnt/arch
sudo rm -rf /mnt/arch

echo '---- Installation Finished----'



