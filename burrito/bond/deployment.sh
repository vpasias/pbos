#!/bin/bash
#

export USERPW=gprm8350

git clone https://github.com/iorchard/robot4kvm.git && cd /home/iason/robot4kvm
python3 -m venv ~/.envs/robot
source ~/.envs/robot/bin/activate
pip install wheel
pip install robotframework
sudo sed -i 's/Debian/Rocky Linux/' /home/iason/robot4kvm/data/grub
cp -rf /home/iason/pbos/burrito/bond/vm_man4rocky.sh /home/iason/robot4kvm/scripts/vm_man4rocky.sh
chmod +x /home/iason/robot4kvm/scripts/vm_man4rocky.sh
cp -rf /home/iason/pbos/burrito/bond/setup_rocky.robot /home/iason/robot4kvm/setup_rocky.robot
cp -rf /home/iason/pbos/burrito/bond/vm_networks.sh .
chmod +x vm_networks.sh && ./vm_networks.sh
cp -rf /home/iason/pbos/burrito/bond/props.py.pbos /home/iason/robot4kvm/props.py
robot -d output setup_rocky.robot
sleep 30
for i in {0..9}; do ssh -o "StrictHostKeyChecking=no" rocky@node-$i "uname -a"; done
for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "hostnamectl set-hostname node-$i --static"; done
for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "modprobe 8021q"; done
for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "modprobe bonding"; done
for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "lsmod | grep 8021q"; done
for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "lsmod | grep bonding"; done
for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo 8021q >> /etc/modules-load.d/8021q.conf"; done
for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo bonding >> /etc/modules"; done

### Bond configuration
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond1 root@node-0:/etc/sysconfig/network-scripts/ifcfg-bond1
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond1 root@node-1:/etc/sysconfig/network-scripts/ifcfg-bond1
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond1 root@node-2:/etc/sysconfig/network-scripts/ifcfg-bond1
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond1 root@node-3:/etc/sysconfig/network-scripts/ifcfg-bond1
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond1 root@node-4:/etc/sysconfig/network-scripts/ifcfg-bond1
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond1 root@node-5:/etc/sysconfig/network-scripts/ifcfg-bond1
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond1 root@node-6:/etc/sysconfig/network-scripts/ifcfg-bond1
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond1 root@node-7:/etc/sysconfig/network-scripts/ifcfg-bond1
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond1 root@node-8:/etc/sysconfig/network-scripts/ifcfg-bond1
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond1 root@node-9:/etc/sysconfig/network-scripts/ifcfg-bond1

sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond2 root@node-0:/etc/sysconfig/network-scripts/ifcfg-bond2
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond2 root@node-1:/etc/sysconfig/network-scripts/ifcfg-bond2
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond2 root@node-2:/etc/sysconfig/network-scripts/ifcfg-bond2
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond2 root@node-3:/etc/sysconfig/network-scripts/ifcfg-bond2
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond2 root@node-4:/etc/sysconfig/network-scripts/ifcfg-bond2
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond2 root@node-5:/etc/sysconfig/network-scripts/ifcfg-bond2
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond2 root@node-6:/etc/sysconfig/network-scripts/ifcfg-bond2
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond2 root@node-7:/etc/sysconfig/network-scripts/ifcfg-bond2
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond2 root@node-8:/etc/sysconfig/network-scripts/ifcfg-bond2
sshpass -p gprm8350 scp -o StrictHostKeyChecking=no /home/iason/pbos/bond/ifcfg-bond2 root@node-9:/etc/sysconfig/network-scripts/ifcfg-bond2

for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cp /etc/sysconfig/network-scripts/ifcfg-eth1 /tmp/ifcfg-eth1"; done
for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cp /etc/sysconfig/network-scripts/ifcfg-eth2 /tmp/ifcfg-eth2"; done
for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cp /etc/sysconfig/network-scripts/ifcfg-eth3 /tmp/ifcfg-eth3"; done
for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cp /etc/sysconfig/network-scripts/ifcfg-eth4 /tmp/ifcfg-eth4"; done

### Bond port configuration
for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth2
NAME=bond-slave-eth2
MASTER=bond1
SLAVE=yes
EOF"; done

for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth3
NAME=bond-slave-eth3
MASTER=bond1
SLAVE=yes
EOF"; done

### Management (API-keepalived) network configuration
### Provider 1 (main) network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-0 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond1

IPADDR=192.168.21.200
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond1

IPADDR=192.168.22.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond1

IPADDR=192.168.22.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond1

IPADDR=192.168.22.203
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-4 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond1

IPADDR=192.168.22.204
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-5 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond1

IPADDR=192.168.22.205
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-6 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond1

IPADDR=192.168.22.206
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-7 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond1

IPADDR=192.168.22.207
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-8 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond1

IPADDR=192.168.22.208
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-9 "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-bond1

IPADDR=192.168.22.209
NETMASK=255.255.255.0
EOF"

### overlay network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-0 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.100
ONBOOT=yes
VLAN=yes
DEVICE=bond1.100
BOOTPROTO=none
IPADDR=192.168.23.200
NETMASK=255.255.255.0
EOF"

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

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.100
ONBOOT=yes
VLAN=yes
DEVICE=bond1.100
BOOTPROTO=none
IPADDR=192.168.23.204
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.100
ONBOOT=yes
VLAN=yes
DEVICE=bond1.100
BOOTPROTO=none
IPADDR=192.168.23.205
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.100
ONBOOT=yes
VLAN=yes
DEVICE=bond1.100
BOOTPROTO=none
IPADDR=192.168.23.206
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-7 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.100
ONBOOT=yes
VLAN=yes
DEVICE=bond1.100
BOOTPROTO=none
IPADDR=192.168.23.207
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-8 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.100
ONBOOT=yes
VLAN=yes
DEVICE=bond1.100
BOOTPROTO=none
IPADDR=192.168.23.208
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-9 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.100
ONBOOT=yes
VLAN=yes
DEVICE=bond1.100
BOOTPROTO=none
IPADDR=192.168.23.209
NETMASK=255.255.255.0
EOF"

### storage & rados GW network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-0 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.24.200
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.24.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.24.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.24.203
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.24.204
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.24.205
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.24.206
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-7 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.24.207
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-8 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.24.208
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-9 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.200
ONBOOT=yes
VLAN=yes
DEVICE=bond1.200
BOOTPROTO=none
IPADDR=192.168.24.209
NETMASK=255.255.255.0
EOF"

### provider 2 network configuration
sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-0 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.300
ONBOOT=yes
VLAN=yes
DEVICE=bond1.300
BOOTPROTO=none
IPADDR=192.168.25.200
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.300
ONBOOT=yes
VLAN=yes
DEVICE=bond1.300
BOOTPROTO=none
IPADDR=192.168.25.201
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.300
ONBOOT=yes
VLAN=yes
DEVICE=bond1.300
BOOTPROTO=none
IPADDR=192.168.25.202
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.300
ONBOOT=yes
VLAN=yes
DEVICE=bond1.300
BOOTPROTO=none
IPADDR=192.168.25.203
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.300
ONBOOT=yes
VLAN=yes
DEVICE=bond1.300
BOOTPROTO=none
IPADDR=192.168.25.204
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.300
ONBOOT=yes
VLAN=yes
DEVICE=bond1.300
BOOTPROTO=none
IPADDR=192.168.25.205
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.300
ONBOOT=yes
VLAN=yes
DEVICE=bond1.300
BOOTPROTO=none
IPADDR=192.168.25.206
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-7 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.300
ONBOOT=yes
VLAN=yes
DEVICE=bond1.300
BOOTPROTO=none
IPADDR=192.168.25.207
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-8 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.300
ONBOOT=yes
VLAN=yes
DEVICE=bond1.300
BOOTPROTO=none
IPADDR=192.168.25.208
NETMASK=255.255.255.0
EOF"

sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-9 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1.300
ONBOOT=yes
VLAN=yes
DEVICE=bond1.300
BOOTPROTO=none
IPADDR=192.168.25.209
NETMASK=255.255.255.0
EOF"

for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "systemctl restart network"; done

for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" rocky@node-$i "ip a"; done

for i in {0..9}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" rocky@node-$i "lsblk && uname -a"; done
