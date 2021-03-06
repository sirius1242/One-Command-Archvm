#!/bin/bash

# some config variables
user='vm'
passwd='archlinux'
mname='Archlinux-vm'
tz='/Asia/Shanghai'
vbox='yes'
# packages which will install automatically in this script
pkglist="sudo git gcc vim zsh grub pkgfile oh-my-zsh-git zsh-syntax-highlighting openssh mlocate pikaur"

# script begin
timedatectl set-ntp true
#parted /dev/sda --script -- mklabel msdos
#parted /dev/sda -a optimal /dev/sda mkpart primary 0% 100%
parted -s -a optimal /dev/sda mklabel msdos -- mkpart primary ext4 1 -1
parted -a optimal /dev/sda set 1 boot on
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt
mkdir /mnt/boot
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
grep 'ustc' /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
cat << EOF | arch-chroot /mnt
ln -sf /usr/share/zoneinfo/$tz /etc/localtime
hwclock --systohc
sed -i '/#en_US.UTF-8/s/^#//g' /etc/locale.gen
sed -i '/#zh_CN.UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "$mname" >> /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$mname" >> /etc/hosts
echo -e '[archlinuxcn]\nServer = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch' >> /etc/pacman.conf
pacman -Syy
pacman -S archlinuxcn-keyring --noconfirm
pacman -S $pkglist --noconfirm
systemctl enable sshd
systemctl enable dhcpcd
sed -i '/GRUB_TIMEOUT/s/[0-9]/0/g' /etc/default/grub
grub-install --target=i386-pc --boot-directory=/boot --bootloader-id=grub /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
useradd -m -G wheel -s /usr/bin/zsh $user
[[ $vbox == 'yes' ]] && pacman -S virtualbox-guest-modules-arch virtualbox-guest-utils-nox --noconfirm && modprobe vboxsf && usermod -a -G vboxsf $user && systemctl enable vboxservice.service
echo "$passwd
$passwd" | passwd $user
echo '$user ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo
chsh -s /usr/bin/zsh
EOF
cp zshrc /mnt/home/$user/.zshrc
cp vimrc /mnt/home/$user/.vimrc
chown 1000:1000 /mnt/home/$user/.zshrc
chown 1000:1000 /mnt/home/$user/.vimrc
cp zshrc /mnt/root/.zshrc
cp vimrc /mnt/root/.vimrc
