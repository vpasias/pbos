#!/bin/bash
#

cat /etc/os-release
uname -a
dnf -y install cloud-utils-growpart curl epel-release 
dnf -y install python3 bind-utils
dnf -y install openssh-server cloud-init sshpass python3-cryptography
dnf install -y net-tools wget curl bash-completion iperf3 mtr traceroute netcat socat python3-simplejson xfsprogs jq virtualenv redhat-lsb-core mdadm
#dnf install -y qemu-kvm

echo "configfs" >> /etc/modules
update-initramfs -u
systemctl daemon-reload

mkdir -p /etc/motd.d

cat << EOF | tee /etc/motd.d/01-custom
****************************WARNING****************************************
UNAUTHORISED ACCESS IS PROHIBITED. VIOLATORS WILL BE PROSECUTED.
***************************************************************************
EOF

chmod +x /etc/motd.d/01-custom

cat << EOF | tee /etc/modprobe.d/kvm.conf
options kvm_intel nested=1
EOF

modprobe -r kvm_intel
modprobe -a kvm_intel

mkdir -p /etc/systemd/system/networking.service.d

cat << EOF | tee /etc/systemd/system/networking.service.d/reduce-timeout.conf
[Service]
TimeoutStartSec=15
EOF

modprobe -v xfs
grep xfs /proc/filesystems
modinfo xfs

groupadd rabbitmq
