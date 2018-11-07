#!/bin/bash

# some config variables
user='vm'
passwd='archlinux'
mname='Archlinux-vm'
tz='/Asia/Shanghai'

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
pacstrap /mnt base
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
pacman -S sudo git vim zsh grub pkgfile oh-my-zsh-git zsh-syntax-highlighting openssh --noconfirm
pacman -S virtualbox-guest-modules-arch virtualbox-guest-utils-nox --noconfirm
systemctl enable sshd
systemctl enable dhcpcd
grub-install --target=i386-pc --boot-directory=/boot --bootloader-id=grub /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
useradd -m -G wheel -s /usr/bin/zsh $user
echo "$passwd
$passwd" | passwd $user
echo '$user ALL=(ALL) ALL' | EDITOR='tee -a' visudo
echo '$user ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo
mkdir /home/$user/.ssh
chsh -s /usr/bin/zsh
EOF
cp zshrc /mnt/home/$user/.zshrc
cp vimrc /mnt/home/$user/.vimrc
cp zshrc /mnt/root/.zshrc
cp vimrc /mnt/root/.vimrc
