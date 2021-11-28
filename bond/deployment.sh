#!/bin/bash
#

export USERPW=gprm8350

git clone https://github.com/iorchard/robot4kvm.git && cd /home/iason/robot4kvm
python3 -m venv ~/.envs/robot
source ~/.envs/robot/bin/activate
pip install wheel
pip install robotframework
sudo sed -i 's/Debian/Rocky Linux/' /home/iason/robot4kvm/data/grub
cp -rf /home/iason/pbos/bond/vm_man4rocky.sh /home/iason/robot4kvm/scripts/vm_man4rocky.sh
chmod +x /home/iason/robot4kvm/scripts/vm_man4rocky.sh
cp -rf /home/iason/pbos/bond/setup_rocky.robot /home/iason/robot4kvm/setup_rocky.robot
cp -rf /home/iason/pbos/bond/vm_networks.sh .
chmod +x vm_networks.sh && ./vm_networks.sh
cp -rf /home/iason/pbos/bond/props.py.pbos /home/iason/robot4kvm/props.py
robot -d output setup_rocky.robot
sleep 30
for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@node-$i "uname -a"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "hostnamectl set-hostname node-$i --static"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "modprobe 8021q"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "modprobe bonding"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "lsmod | grep 8021q"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "lsmod | grep bonding"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo 8021q >> /etc/modules-load.d/8021q.conf"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo bonding >> /etc/modules"; done

### Bond configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 'cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1
ONBOOT=yes
DEVICE=bond1
Type=Bond
BOOTPROTO=none
BONDING_MASTER=yes
BONDING_OPTS="mode=4 miimon=100 lacp_rate=1"
EOF'

### VLAN configuration
# API network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.5
ONBOOT=yes
VLAN=yes
DEVICE=bond1.5
BOOTPROTO=none
IPADDR=192.168.21.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.5
ONBOOT=yes
VLAN=yes
DEVICE=bond1.5
BOOTPROTO=none
IPADDR=192.168.21.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.5
ONBOOT=yes
VLAN=yes
DEVICE=bond1.5
BOOTPROTO=none
IPADDR=192.168.21.203
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.5
ONBOOT=yes
VLAN=yes
DEVICE=bond1.5
BOOTPROTO=none
IPADDR=192.168.21.204
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.5
ONBOOT=yes
VLAN=yes
DEVICE=bond1.5
BOOTPROTO=none
IPADDR=192.168.21.205
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.5
ONBOOT=yes
VLAN=yes
DEVICE=bond1.5
BOOTPROTO=none
IPADDR=192.168.21.206
NETMASK=255.255.255.0
EOF"

# overlay network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.10
ONBOOT=yes
VLAN=yes
DEVICE=bond1.10
BOOTPROTO=none
IPADDR=192.168.23.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.10
ONBOOT=yes
VLAN=yes
DEVICE=bond1.10
BOOTPROTO=none
IPADDR=192.168.23.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.10
ONBOOT=yes
VLAN=yes
DEVICE=bond1.10
BOOTPROTO=none
IPADDR=192.168.23.203
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.10
ONBOOT=yes
VLAN=yes
DEVICE=bond1.10
BOOTPROTO=none
IPADDR=192.168.23.204
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.10
ONBOOT=yes
VLAN=yes
DEVICE=bond1.10
BOOTPROTO=none
IPADDR=192.168.23.205
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.10
ONBOOT=yes
VLAN=yes
DEVICE=bond1.10
BOOTPROTO=none
IPADDR=192.168.23.206
NETMASK=255.255.255.0
EOF"

# rados GW network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.20
ONBOOT=yes
VLAN=yes
DEVICE=bond1.20
BOOTPROTO=none
IPADDR=192.168.25.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.20
ONBOOT=yes
VLAN=yes
DEVICE=bond1.20
BOOTPROTO=none
IPADDR=192.168.25.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.20
ONBOOT=yes
VLAN=yes
DEVICE=bond1.20
BOOTPROTO=none
IPADDR=192.168.25.203
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.20
ONBOOT=yes
VLAN=yes
DEVICE=bond1.20
BOOTPROTO=none
IPADDR=192.168.25.204
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.20
ONBOOT=yes
VLAN=yes
DEVICE=bond1.20
BOOTPROTO=none
IPADDR=192.168.25.205
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.20
ONBOOT=yes
VLAN=yes
DEVICE=bond1.20
BOOTPROTO=none
IPADDR=192.168.25.206
NETMASK=255.255.255.0
EOF"

# provider network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.30
ONBOOT=yes
VLAN=yes
DEVICE=bond1.30
BOOTPROTO=none
IPADDR=192.168.22.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.30
ONBOOT=yes
VLAN=yes
DEVICE=bond1.30
BOOTPROTO=none
IPADDR=192.168.22.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.30
ONBOOT=yes
VLAN=yes
DEVICE=bond1.30
BOOTPROTO=none
IPADDR=192.168.22.203
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.30
ONBOOT=yes
VLAN=yes
DEVICE=bond1.30
BOOTPROTO=none
IPADDR=192.168.22.204
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.30
ONBOOT=yes
VLAN=yes
DEVICE=bond1.30
BOOTPROTO=none
IPADDR=192.168.22.205
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.30
ONBOOT=yes
VLAN=yes
DEVICE=bond1.30
BOOTPROTO=none
IPADDR=192.168.22.206
NETMASK=255.255.255.0
EOF"

for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "systemctl restart network"; done

for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" rocky@node-$i "ip a"; done

for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" rocky@node-$i "lsblk && uname -a"; done
