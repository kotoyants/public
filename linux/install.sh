#!/bin/bash

DISK_NAME="nvme0n1"
DEVICE="/dev/${DISK_NAME}"
DIR_STATUS="/tmp/arch-install"
SWAP_SIZE="16G"
HOSTNAME="slim"
ROOT_PASSWD="qwerty12345"
USER_NAME="none"
USER_PASSWD="qwerty12345"

set -e
mkdir -p ${DIR_STATUS}

info()  { echo -e "\e[1;34m[INFO]\e[0m  $*"; }
warn()  { echo -e "\e[1;33m[WARN]\e[0m  $*"; }
error() { echo -e "\e[1;31m[ERROR]\e[0m $*" >&2; exit 1; }


info "1. Disk partitioning"
if [ ! -f ${DIR_STATUS}/1 ]; then
  info "  wiping disk in 5 sec ..."
  sleep 5
  sgdisk --zap-all "$DEVICE"
  sgdisk \
    --new=1:0:+1M --typecode=1:ef02 \
    --new=2:0:+512M --typecode=2:ef00 \
    --new=3:0:-"$SWAP_SIZE" --typecode=3:8300 \
    --new=4:0:0 --typecode=4:8200 \
    "$DEVICE"
  partprobe "$DEVICE"
  info "Parition table"
  lsblk $DEVICE | tee ${DIR_STATUS}/1
else
  warn "Skip partitioning"
fi

info "2. Create filesystme"
if [ ! -f ${DIR_STATUS}/2 ]; then
  mkfs.fat -F32 ${DEVICE}p2
  mkfs.ext4 -F ${DEVICE}p3
  mkswap ${DEVICE}p4
  touch ${DIR_STATUS}/2
else
  warn "Skip filesystem creation"
fi

info "3. Mouting filesystems"
if [ ! -f ${DIR_STATUS}/3 ]; then
  mount ${DEVICE}p3 /mnt

  mkdir -p /mnt/mnt/efi
  mount ${DEVICE}p2 /mnt/mnt/efi
  mkdir -p /mnt/mnt/efi/efi/arch
  mkdir /mnt/boot
  mount -o bind /mnt/mnt/efi/efi/arch /mnt/boot

  touch ${DIR_STATUS}/3
else
  warn "Skip mounting filesystems"
fi

info "4. Install base"
if [ ! -f ${DIR_STATUS}/4 ]; then
  mkdir -p /mnt/etc
  echo "KEYMAP=us" > /mnt/etc/vconsole.conf

  pacman-key --init
  pacman-key --populate archlinux

  pacstrap /mnt base linux linux-firmware-intel

  echo "UUID=$(blkid -s UUID -o value ${DEVICE}p3)  /         ext4  rw,relatime    0 1" > /mnt/etc/fstab
  echo "UUID=$(blkid -s UUID -o value ${DEVICE}p4)  none      swap  defaults       0 0" >> /mnt/etc/fstab
  echo "UUID=$(blkid -s UUID -o value ${DEVICE}p2)                             /mnt/efi  vfat  rw,relatime    0 2" >> /mnt/etc/fstab
  echo "/mnt/efi/efi/arch                          /boot     none  defaults,bind  0 0" >> /mnt/etc/fstab

  touch ${DIR_STATUS}/4
else
  warn "Skip base install"
fi

info "5. Chroot"
if [ ! -f ${DIR_STATUS}/5 ]; then
  arch-chroot /mnt /bin/bash << EOF
  pacman -S --noconfirm intel-ucode
  
  sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
  locale-gen
  
  hostnamectl set-hostname $HOSTNAME
  timedatectl set-timezone Asia/Tbilisi
  systemctl enable systemd-timesyncd
  
  useradd -G wheel,users -m ${USER_NAME}
  echo "${USER_NAME}:${USER_PASSWD}" | chpasswd
  
  echo "root:${ROOT_PASSWD}" | chpasswd
  
  pacman -S --noconfirm efibootmgr
  efibootmgr -d ${DEVICE} -p 2 -c -L "Arch Linux" -l '\efi\arch\vmlinuz-linux' -u "root=UUID=$(blkid -s UUID -o value ${DEVICE}p3) rw initrd=\efi\arch\intel-ucode.img initrd=\efi\arch\initramfs-linux.img resume=UUID=$(blkid -s UUID -o value ${DEVICE}p4) quiet splash loglevel=3 console=tty2"
  
  sed -i '/^HOOKS=/ s/filesystems fsck/filesystems resume fsck/'
  
  pacman -S --noconfirm sudo
  echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel
  
  sed -i 's/#Color/Color/' /etc/pacman.conf

  # Ulils
  pacman -S --noconfirm xorg-server lightdm lightdm-gtk-greeter networkmanager network-manager-applet vim pulseaudio
  # Mate base
  pacman -S --noconfirm caja marco mate-control-center mate-desktop mate-icon-theme mate-menus mate-notification-daemon mate-panel mate-polkit mate-session-manager mate-settings-daemon mate-themes terminator
  # Mate additional
  pacman -S --noconfirm atril caja-image-converter caja-open-terminal caja-sendto caja-share caja-xattr-tags engrampa eom mate-applets mate-calc mate-media mate-power-manager mate-screensaver mate-system-monitor mate-utils mozo pluma
  # Desktop utils
  pacman -S --noconfirm parcellite mc networkmanager-openvpn dconf-editor pacman-contrib man openssh wget conky rdesktop nmap unrar htop gparted gnome-keyring bash-completion git rsync lsof ipcalc ncdu p7zip ntfs-3g gnu-netcat blueman
  # Fonts
  pacman -S --noconfirm terminus-font ttf-ubuntu-font-family ttf-dejavu ttf-baekmuk ttf-indic-otf font-tlwg
  # Desktop
  pacman -S --noconfirm chromium telegram-desktop flameshot mplayer libreoffice-still
EOF
  touch ${DIR_STATUS}/5
else
  warn "Skip chroot"
fi
