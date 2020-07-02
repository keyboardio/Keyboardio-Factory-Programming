echo "/dev/mmcblk1p1 	/mnt/flasher vfat " >> /etc/fstab
mkdir /mnt/flasher
apt-get install libipc-run-perl avrdude

cp script.service /etc/systemd/system
systemctl mask getty@tty1.service
systemctl enable script.service
