#!/bin/bash
#
HOME=/mnt/extra/

cat > /mnt/extra/management.xml <<EOF
<network>
  <name>management</name>
  <forward mode='nat'/>
  <bridge name='virbr100' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:cd'/>
  <ip address='192.168.254.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.254.2' end='192.168.254.249'/>
      <host mac='52:54:00:8a:8b:c1' name='n1' ip='192.168.254.101'/>
      <host mac='52:54:00:8a:8b:c2' name='n2' ip='192.168.254.102'/>
      <host mac='52:54:00:8a:8b:c3' name='n3' ip='192.168.254.103'/>
      <host mac='52:54:00:8a:8b:c4' name='n4' ip='192.168.254.104'/>
      <host mac='52:54:00:8a:8b:c5' name='n5' ip='192.168.254.105'/>
      <host mac='52:54:00:8a:8b:c6' name='n6' ip='192.168.254.106'/>
      <host mac='52:54:00:8a:8b:c7' name='n7' ip='192.168.254.107'/>
      <host mac='52:54:00:8a:8b:c8' name='n8' ip='192.168.254.108'/>
      <host mac='52:54:00:8a:8b:c9' name='n9' ip='192.168.254.109'/>
    </dhcp>
  </ip>
</network>
EOF

cat > /mnt/extra/overlay.xml <<EOF
<network>
  <name>overlay</name>
  <bridge name="virbr101" stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

cat > /mnt/extra/storage.xml <<EOF
<network>
  <name>storage</name>
  <bridge name="virbr102" stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>  
</network>
EOF

cat > /mnt/extra/provider.xml <<EOF
<network>
  <forward mode='nat'/>
  <name>provider</name>
  <bridge name="virbr103" stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:9a:9b:cd'/>
  <ip address='172.16.100.1' netmask='255.255.255.0'>
  </ip>  
</network>
EOF

virsh net-define /mnt/extra/management.xml && virsh net-autostart management && virsh net-start management
virsh net-define /mnt/extra/overlay.xml && virsh net-autostart overlay && virsh net-start overlay
virsh net-define /mnt/extra/storage.xml && virsh net-autostart storage && virsh net-start storage
virsh net-define /mnt/extra/provider.xml && virsh net-autostart provider && virsh net-start provider

ip a && sudo virsh net-list --all

sleep 20

# Node 1
./kvm-install-vm create -c 6 -m 32768 -t centos8 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b virbr100 -T US/Eastern -M 52:54:00:8a:8b:c1 n1

# Node 2
./kvm-install-vm create -c 6 -m 32768 -t centos8 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b virbr100 -T US/Eastern -M 52:54:00:8a:8b:c2 n2

# Node 3
./kvm-install-vm create -c 6 -m 32768 -t centos8 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b virbr100 -T US/Eastern -M 52:54:00:8a:8b:c3 n3

# Node 4
./kvm-install-vm create -c 6 -m 32768 -t centos8 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b virbr100 -T US/Eastern -M 52:54:00:8a:8b:c4 n4

# Node 5
./kvm-install-vm create -c 6 -m 32768 -t centos8 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b virbr100 -T US/Eastern -M 52:54:00:8a:8b:c5 n5

# Node 6
./kvm-install-vm create -c 6 -m 32768 -t centos8 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b virbr100 -T US/Eastern -M 52:54:00:8a:8b:c6 n6

sleep 60

virsh list --all && brctl show && virsh net-list --all

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo dnf update -y"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i 'echo "root:gprm8350" | sudo chpasswd'; done
for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i 'echo "rocky:gprm8350" | sudo chpasswd'; done
for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"; done
for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo systemctl restart sshd"; done
for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo rm -rf /root/.ssh/authorized_keys"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo hostnamectl set-hostname n$i --static"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo chmod -x /etc/motd.d/*"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i 'cat << EOF | sudo tee /etc/motd.d/01-custom
****************************WARNING****************************************
UNAUTHORISED ACCESS IS PROHIBITED. VIOLATORS WILL BE PROSECUTED.
***************************************************************************
EOF'; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo chmod +x /etc/motd.d/01-custom"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "cat << EOF | sudo tee /etc/modprobe.d/kvm.conf
options kvm_intel nested=1
EOF"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo modprobe -r kvm_intel && sudo modprobe -a kvm_intel"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo mkdir -p /etc/systemd/system/networking.service.d"; done
for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "cat << EOF | sudo tee /etc/systemd/system/networking.service.d/reduce-timeout.conf
[Service]
TimeoutStartSec=15
EOF"; done

#for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo rm -rf /etc/sudoers.d/90-cloud-init-users && sudo touch /etc/sudoers.d/90-cloud-init-users && sudo chmod 644 /etc/sudoers.d/90-cloud-init-users"; done
#for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i 'sudo sh -c "echo 'Defaults:rocky !requiretty' > /etc/sudoers.d/90-cloud-init-users"'; done
#for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i 'sudo sh -c "echo '%rocky ALL=(ALL) ALL' >> /etc/sudoers.d/90-cloud-init-users"'; done
#for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "echo 'Defaults:rocky !requiretty' | sudo tee -a /etc/sudoers.d/90-cloud-init-users"; done
#for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "echo '%rocky ALL=(ALL) ALL' | sudo tee -a /etc/sudoers.d/90-cloud-init-users"; done
#for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "cat << EOF | sudo tee /etc/sudoers.d/90-cloud-init-users
#Defaults:rocky !requiretty
#%rocky ALL=(ALL) ALL
#EOF"; done
#for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo chmod 440 /etc/sudoers.d/90-cloud-init-users"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo dnf makecache && sudo dnf install epel-release -y && sudo dnf makecache"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo dnf install -y git vim net-tools wget curl bash-completion iperf3 mtr traceroute netcat sshpass socat python3 python3-simplejson xfsprogs jq virtualenv"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo dnf install systemd-timesyncd -y && sudo systemctl unmask systemd-timesyncd.service && sudo systemctl enable systemd-timesyncd.service && sudo systemctl restart systemd-timesyncd.service && sudo timedatectl set-ntp on"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo modprobe -v xfs && sudo grep xfs /proc/filesystems && sudo modinfo xfs"; done

for i in {1..6}; do virsh shutdown n$i; done && sleep 10 && virsh list --all && for i in {1..6}; do virsh start n$i; done && sleep 10 && virsh list --all

sleep 30

for i in {1..6}; do qemu-img create -f qcow2 vbdnode1$i.qcow2 120G; done
for i in {1..6}; do qemu-img create -f qcow2 vbdnode2$i.qcow2 120G; done
for i in {1..6}; do qemu-img create -f qcow2 vbdnode3$i.qcow2 120G; done

for i in {1..6}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode1$i.qcow2 -t vdb n$i; done
for i in {1..6}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode2$i.qcow2 -t vdc n$i; done
for i in {1..6}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode3$i.qcow2 -t vdd n$i; done

#for i in {1..6}; do virsh attach-interface --domain n$i --type network --source overlay --model e1000 --mac 02:00:aa:0a:01:1$i --config --live; done
#for i in {1..6}; do virsh attach-interface --domain n$i --type network --source storage --model e1000 --mac 02:00:aa:0a:02:1$i --config --live; done
#for i in {1..6}; do virsh attach-interface --domain n$i --type network --source provider --model e1000 --mac 02:00:aa:0a:03:1$i --config --live; done

for i in {1..6}; do virsh attach-interface --domain n$i --type network --source overlay --model virtio --mac 02:00:aa:0a:01:1$i --config --live; done
for i in {1..6}; do virsh attach-interface --domain n$i --type network --source storage --model virtio --mac 02:00:aa:0a:02:1$i --config --live; done
for i in {1..6}; do virsh attach-interface --domain n$i --type network --source provider --model virtio --mac 02:00:aa:0a:03:1$i --config --live; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "cat << EOF | sudo tee /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.254.101  n1
192.168.254.102  n2
192.168.254.103  n3
192.168.254.104  n4
192.168.254.105  n5
192.168.254.106  n6
192.168.254.107  n7
192.168.254.108  n8
192.168.254.109  n9
EOF"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "cat << EOF | sudo tee /etc/sysctl.d/60-lxd-production.conf
fs.inotify.max_queued_events=1048576
fs.inotify.max_user_instances=1048576
fs.inotify.max_user_watches=1048576
vm.max_map_count=262144
kernel.dmesg_restrict=1
net.ipv4.neigh.default.gc_thresh3=8192
net.ipv6.neigh.default.gc_thresh3=8192
net.core.bpf_jit_limit=3000000000
kernel.keys.maxkeys=2000
kernel.keys.maxbytes=2000000
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
net.ipv6.conf.all.forwarding=1
EOF"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo sysctl --system"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "#echo vm.swappiness=1 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p"; done

for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth0"; done
for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth1"; done
for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth2"; done
for i in {1..6}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth3"; done

### eth0
ssh -o "StrictHostKeyChecking=no" rocky@n1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c1
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c2
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c3
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c4
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c5
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c6
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

### eth1
ssh -o "StrictHostKeyChecking=no" rocky@n1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
BOOTPROTO=static
HWADDR=02:00:aa:0a:01:11
IPADDR=192.168.255.11
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
BOOTPROTO=static
HWADDR=02:00:aa:0a:01:12
IPADDR=192.168.255.12
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
BOOTPROTO=static
HWADDR=02:00:aa:0a:01:13
IPADDR=192.168.255.13
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
BOOTPROTO=static
HWADDR=02:00:aa:0a:01:14
IPADDR=192.168.255.14
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
BOOTPROTO=static
HWADDR=02:00:aa:0a:01:15
IPADDR=192.168.255.15
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
BOOTPROTO=static
HWADDR=02:00:aa:0a:01:16
IPADDR=192.168.255.16
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

### eth2
ssh -o "StrictHostKeyChecking=no" rocky@n1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2
BOOTPROTO=static
HWADDR=02:00:aa:0a:02:11
IPADDR=192.168.250.11
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2
BOOTPROTO=static
HWADDR=02:00:aa:0a:02:12
IPADDR=192.168.250.12
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2
BOOTPROTO=static
HWADDR=02:00:aa:0a:02:13
IPADDR=192.168.250.13
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2
BOOTPROTO=static
HWADDR=02:00:aa:0a:02:14
IPADDR=192.168.250.14
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2
BOOTPROTO=static
HWADDR=02:00:aa:0a:02:15
IPADDR=192.168.250.15
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2
BOOTPROTO=static
HWADDR=02:00:aa:0a:02:16
IPADDR=192.168.250.16
NETMASK=255.255.255.0
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

### eth3
ssh -o "StrictHostKeyChecking=no" rocky@n1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth3
DEVICE=eth3
BOOTPROTO=none
HWADDR=02:00:aa:0a:03:11
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth3
DEVICE=eth3
BOOTPROTO=none
HWADDR=02:00:aa:0a:03:12
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth3
DEVICE=eth3
BOOTPROTO=none
HWADDR=02:00:aa:0a:03:13
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth3
DEVICE=eth3
BOOTPROTO=none
HWADDR=02:00:aa:0a:03:14
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth3
DEVICE=eth3
BOOTPROTO=none
HWADDR=02:00:aa:0a:03:15
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

ssh -o "StrictHostKeyChecking=no" rocky@n6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth3
DEVICE=eth3
BOOTPROTO=none
HWADDR=02:00:aa:0a:03:16
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

for i in {1..6}; do virsh shutdown n$i; done && sleep 90 && virsh list --all && for i in {1..6}; do virsh start n$i; done && sleep 90 && virsh list --all
