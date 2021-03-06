#!/bin/bash
#

export USERPW=gprm8350

git clone https://github.com/iorchard/robot4kvm.git && cd /home/iason/robot4kvm
python3 -m venv ~/.envs/robot
source ~/.envs/robot/bin/activate
pip install wheel
pip install robotframework
sudo sed -i 's/Debian/Rocky Linux/' /home/iason/robot4kvm/data/grub
cp -rf /home/iason/pbos/clab/vm_man4rocky.sh /home/iason/robot4kvm/scripts/vm_man4rocky.sh
chmod +x /home/iason/robot4kvm/scripts/vm_man4rocky.sh
cp -rf /home/iason/pbos/clab/setup_rocky.robot /home/iason/robot4kvm/setup_rocky.robot
cp -rf /home/iason/pbos/clab/vm_networks.sh .
chmod +x vm_networks.sh && ./vm_networks.sh
cp -rf /home/iason/pbos/clab/props.py.pbos /home/iason/robot4kvm/props.py
robot -d output setup_rocky.robot
sleep 30
for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" rocky@node-$i "uname -a"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "hostnamectl set-hostname node-$i --static"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "modprobe 8021q"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "modprobe bonding"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "lsmod | grep 8021q"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "lsmod | grep bonding"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo 8021q >> /etc/modules-load.d/8021q.conf"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo bonding >> /etc/modules"; done

### Bond configuration
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/clab/ifcfg-bond1 root@node-1:/etc/sysconfig/network-scripts/ifcfg-bond1
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/clab/ifcfg-bond1 root@node-2:/etc/sysconfig/network-scripts/ifcfg-bond1
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/clab/ifcfg-bond1 root@node-3:/etc/sysconfig/network-scripts/ifcfg-bond1

sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/clab/ifcfg-bond2 root@node-1:/etc/sysconfig/network-scripts/ifcfg-bond2
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/clab/ifcfg-bond2 root@node-2:/etc/sysconfig/network-scripts/ifcfg-bond2
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/clab/ifcfg-bond2 root@node-3:/etc/sysconfig/network-scripts/ifcfg-bond2

for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cp /etc/sysconfig/network-scripts/ifcfg-eth1 /tmp/ifcfg-eth1"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cp /etc/sysconfig/network-scripts/ifcfg-eth2 /tmp/ifcfg-eth2"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cp /etc/sysconfig/network-scripts/ifcfg-eth3 /tmp/ifcfg-eth3"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cp /etc/sysconfig/network-scripts/ifcfg-eth4 /tmp/ifcfg-eth4"; done

### Bond port configuration
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth1
NAME=bond-slave-eth1
MASTER=bond1
SLAVE=yes
EOF"; done

for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth2
NAME=bond-slave-eth2
MASTER=bond1
SLAVE=yes
EOF"; done

for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth3
NAME=bond-slave-eth3
MASTER=bond2
SLAVE=yes
EOF"; done

for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth4
NAME=bond-slave-eth4
MASTER=bond2
SLAVE=yes
EOF"; done

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

# provider 1 network configuration
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.10
ONBOOT=yes
VLAN=yes
DEVICE=bond1.10
BOOTPROTO=none
EOF"; done

# overlay network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.100
ONBOOT=yes
VLAN=yes
DEVICE=bond1.100
BOOTPROTO=none
IPADDR=192.168.23.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.100
ONBOOT=yes
VLAN=yes
DEVICE=bond1.100
BOOTPROTO=none
IPADDR=192.168.23.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.100
ONBOOT=yes
VLAN=yes
DEVICE=bond1.100
BOOTPROTO=none
IPADDR=192.168.23.203
NETMASK=255.255.255.0
EOF"

# rados GW network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.25.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.25.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.25.203
NETMASK=255.255.255.0
EOF"

# provider 2 network configuration
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.300
ONBOOT=yes
VLAN=yes
DEVICE=bond1.300
BOOTPROTO=none
EOF"; done

# storage network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond2
IPADDR=192.168.24.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond2
IPADDR=192.168.24.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond2
IPADDR=192.168.24.203
NETMASK=255.255.255.0
EOF"

for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "systemctl restart network"; done

for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" rocky@node-$i "ip a"; done

for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" rocky@node-$i "lsblk && uname -a"; done
