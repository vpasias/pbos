#!/bin/bash
#ISO_PATH="/mnt/extra/virt/images/Rocky-8.5-x86_64-minimal.iso"
#DISK_PATH="/mnt/extra/virt/images/rocky-8.5-x86_64-genericcloud.qcow2"
ISO_PATH="/home/iason/images/Rocky-8.5-x86_64-minimal.iso"
DISK_PATH="/home/iason/images/rocky-8.5-x86_64-genericcloud.qcow2"
DISK_SIZE=5
DISK_FORMAT="qcow2"
NET_BRIDGE="virbr0"

virt-install \
  --name rocky-linux-8 \
  --memory=1024 \
  --vcpus=1 \
  --os-type linux \
  --location ${ISO_PATH} \
  --disk path=${DISK_PATH},size=${DISK_SIZE},format=${DISK_FORMAT}  \
  --network bridge=${NET_BRIDGE} \
  --graphics=none \
  --os-variant=rhl8.0 \
  --console pty,target_type=serial \
  --initrd-inject ks.cfg \
  --extra-args "inst.ks=file:/ks.cfg console=tty0 console=ttyS0,115200n8"
