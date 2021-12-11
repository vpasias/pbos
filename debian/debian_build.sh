#!/bin/bash
ISO_PATH="/home/iason/images/debian-11.1.0-amd64-netinst.iso"
DISK_PATH="/home/iason/images/debian-11.1.0-amd64-genericcloud.qcow2"
DISK_SIZE=5
DISK_FORMAT="qcow2"
NET_BRIDGE="virbr0"

virt-install \
  --name debian-11 \
  --memory=1024 \
  --vcpus=1 \
  --os-type linux \
  --location ${ISO_PATH} \
  --disk path=${DISK_PATH},size=${DISK_SIZE},format=${DISK_FORMAT}  \
  --network bridge=${NET_BRIDGE} \
  --graphics=none \
  --os-variant=debian11 \
  --console pty,target_type=serial \
  --initrd-inject ks.cfg \
  --extra-args "inst.ks=file:/ks.cfg console=tty0 console=ttyS0,115200n8"
