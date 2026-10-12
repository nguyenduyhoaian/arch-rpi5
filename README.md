# Install Arch Linux ARM on raspberry pi 5

Download ARMv8 Raspberry Pi 3/4 from:
http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz
then rename to ArchLinuxARM.tar.gz

Download https://archlinuxarm.org/packages/aarch64/linux-rpi-16k
then rename to linux-rpi-16k.pkg.tar.xz

sudo apt install libarchive-tools
cd arch-rpi5
bash install.sh

reboot to arch, log in as root user
bash /setup.sh
