set -e

echo '----locale-gen----'
locale-gen

echo '----timedatectl setup----'
timedatectl
timedatectl set-ntp true
timedatectl set-timezone Asia/Ho_Chi_Minh
timedatectl

echo '----pacman-key setup----'
pacman-key --init
pacman-key --populate archlinuxarm

echo '----pacman -Rn linux-aarch64 uboot-raspberrypi----'
pacman -Rn --noconfirm linux-aarch64 uboot-raspberrypi

echo '----Install new packages----'
pacman -Syu --noconfirm --overwrite "/boot/*" linux-rpi-16k sudo bash-completion plasma-meta ufw networkmanager konsole dolphin gwenview kate firefox zram-generator fcitx5-configtool

echo '----zram-generator setup----'
sudo tee /etc/systemd/zram-generator.conf <<< '[zram0]' 
sudo tee -a /etc/systemd/zram-generator.conf <<< 'zram-size=4096'

echo '----Delete default alarm account----'
userdel -r alarm

echo '----Edit /etc/sudoers----'
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo '----Enable services----'
systemctl enable NetworkManager plasmalogin.service bluetooth.service ufw.service
ufw enable

read -p 'Create new user account, input user name:' name
useradd -m -G wheel -s /bin/bash "$name"
echo "Change password for account ' $name '"
passwd "$name"
echo '----Setup finish!----'
exit
