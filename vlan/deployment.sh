#!/bin/bash
#

export USERPW=gprm8350

git clone https://github.com/iorchard/robot4kvm.git && cd /home/iason/robot4kvm
python3 -m venv ~/.envs/robot
source ~/.envs/robot/bin/activate
pip install wheel
pip install robotframework
sudo sed -i 's/Debian/Rocky Linux/' /home/iason/robot4kvm/data/grub
cp -rf /home/iason/pbos/vlan/vm_man4rocky.sh /home/iason/robot4kvm/scripts/vm_man4rocky.sh
chmod +x /home/iason/robot4kvm/scripts/vm_man4rocky.sh
cp -rf /home/iason/pbos/setup_rocky.robot /home/iason/robot4kvm/setup_rocky.robot
cp -rf /home/iason/pbos/vlan/vm_networks.sh .
chmod +x vm_networks.sh && ./vm_networks.sh
cp -rf /home/iason/pbos/vlan/props.py.pbos /home/iason/robot4kvm/props.py
robot -d output setup_rocky.robot
sleep 10
for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@node-$i "uname -a"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "hostnamectl set-hostname node-$i --static"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "modprobe 8021q"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "lsmod | grep 8021q"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo 8021q >> /etc/modules-load.d/8021q.conf"; done

# overlay network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.10
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.10
BOOTPROTO=static
IPADDR=192.168.210.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.10
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.10
BOOTPROTO=static
IPADDR=192.168.210.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.10
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.10
BOOTPROTO=static
IPADDR=192.168.210.203
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.10
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.10
BOOTPROTO=static
IPADDR=192.168.210.204
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.10
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.10
BOOTPROTO=static
IPADDR=192.168.210.205
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.10
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.10
BOOTPROTO=static
IPADDR=192.168.210.206
NETMASK=255.255.255.0
EOF"

# rados GW network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.20
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.20
BOOTPROTO=static
IPADDR=192.168.220.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.20
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.20
BOOTPROTO=static
IPADDR=192.168.220.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.20
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.20
BOOTPROTO=static
IPADDR=192.168.220.203
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.20
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.20
BOOTPROTO=static
IPADDR=192.168.220.204
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.20
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.20
BOOTPROTO=static
IPADDR=192.168.220.205
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1.20
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
DEVICE=eth1.20
BOOTPROTO=static
IPADDR=192.168.220.206
NETMASK=255.255.255.0
EOF"

for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "systemctl restart network"; done

for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" rocky@node-$i "ip a"; done

for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" rocky@node-$i "lsblk && uname -a"; done
