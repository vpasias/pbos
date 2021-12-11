#!/bin/bash
#
# Takes standard Ubuntu 20.04 cloudimg and creates VM configured with cloud-init
# 
# uses snapshot and increases size of root filesystem so base image not affected
# inserts cloud-init user, network, metadata into disk
# then uses cloud-init to configure OS
#
set -x

# image should be downloaded from ubuntu site
os_variant="ubuntu20.04"
baseimg=focal-server-cloudimg-amd64.img
if [ ! -f ~/images/$baseimg ]; then
  echo "ERROR did not find ~/images/$baseimg"
  echo "Doing download...."
  wget https://cloud-images.ubuntu.com/focal/current/$baseimg -O ~/images/$baseimg
  echo ""
  echo "$baseimg downloaded now.  Run again"
  exit 2
fi


hostname=ubuntu-2004

snapshot=$hostname-snapshot-cloudimg.qcow2
seed=$hostname-seed.img
# vnc|none
graphicsType=none


# create working snapshot, increase size to 5G
sudo rm $snapshot
qemu-img create -b ~/images/$baseimg -f qcow2 $snapshot 5G
qemu-img info $snapshot

# insert metadata into seed image
echo "instance-id: $(uuidgen || echo i-abcdefg)" > $hostname-metadata
cloud-localds -v --network-config=network_config_static.cfg $seed cloud_init.cfg $hostname-metadata

# ensure file permissions belong to kvm group
sudo chmod 666 $baseimg
sudo chmod 666 $snapshot
sudo chown $USER:kvm $snapshot $seed

# create VM using libvirt
virt-install --name $hostname \
  --virt-type kvm --memory 2048 --vcpus 2 \
  --boot hd,menu=on \
  --disk path=$seed,device=cdrom \
  --disk path=$snapshot,device=disk \
  --graphics $graphicsType \
  --os-type Linux --os-variant $os_variant \
  --network network:default \
  --console pty,target_type=serial \
  --extra-args "console=tty0 console=ttyS0,115200n8"
