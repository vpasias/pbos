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
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" rocky@node-$i "ip a"; done
for i in {1..6}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" rocky@node-$i "lsblk && uname -a"; done
