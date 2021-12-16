#!/bin/bash
#
HOME=/mnt/extra/

cat > /mnt/extra/mgmt.xml <<EOF
<network>
  <name>mgmt</name>
  <forward mode='nat'/>
  <bridge name='mgmt' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:ca'/>
  <ip address='192.168.20.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.20.200' end='192.168.20.249'/>
      <host mac='52:54:00:8a:8b:c1' name='node-1' ip='192.168.20.201'/>
      <host mac='52:54:00:8a:8b:c2' name='node-2' ip='192.168.20.202'/>
      <host mac='52:54:00:8a:8b:c3' name='node-3' ip='192.168.20.203'/>
      <host mac='52:54:00:8a:8b:c4' name='node-4' ip='192.168.20.204'/>
      <host mac='52:54:00:8a:8b:c5' name='node-5' ip='192.168.20.205'/>
      <host mac='52:54:00:8a:8b:c6' name='node-6' ip='192.168.20.206'/>
      <host mac='52:54:00:8a:8b:c7' name='node-7' ip='192.168.20.207'/>
      <host mac='52:54:00:8a:8b:c8' name='node-8' ip='192.168.20.208'/>
      <host mac='52:54:00:8a:8b:c9' name='node-9' ip='192.168.20.209'/>
    </dhcp>
  </ip>
</network>
EOF

cat > /mnt/extra/ds1.xml <<EOF
<network>
  <name>ds1</name>
  <forward mode='nat'/>  
  <bridge name='ds1' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:cb'/>
  <ip address='192.168.22.1' netmask='255.255.255.0'>
  </ip>  
</network>
EOF

cat > /mnt/extra/ds2.xml <<EOF
<network>
  <name>ds2</name>
  <forward mode='nat'/>    
  <bridge name='ds2' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:cc'/>
  <ip address='192.168.26.1' netmask='255.255.255.0'>
  </ip>    
</network>
EOF

cat > /mnt/extra/ss1.xml <<EOF
<network>
  <name>ss1</name>
  <bridge name='ss1' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

cat > /mnt/extra/ss2.xml <<EOF
<network>
  <name>ss2</name>
  <bridge name='ss2' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

virsh net-define /mnt/extra/mgmt.xml && virsh net-autostart mgmt && virsh net-start mgmt
virsh net-define /mnt/extra/ds1.xml && virsh net-autostart ds1 && virsh net-start ds1
virsh net-define /mnt/extra/ds2.xml && virsh net-autostart ds2 && virsh net-start ds2
virsh net-define /mnt/extra/ss1.xml && virsh net-autostart ss1 && virsh net-start ss1
virsh net-define /mnt/extra/ss2.xml && virsh net-autostart ss2 && virsh net-start ss2

ip a && sudo virsh net-list --all

sleep 20

# Node 1
./kvm-install-vm create -c 6 -m 32768 -d 120 -t debian10 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c1 node-1

# Node 2
./kvm-install-vm create -c 6 -m 32768 -d 120 -t debian10 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c2 node-2

# Node 3
./kvm-install-vm create -c 6 -m 32768 -d 120 -t debian10 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c3 node-3

sleep 60

virsh list --all && brctl show && virsh net-list --all

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo apt update -y && sudo apt upgrade -y && sudo apt install gcc-8-base -y"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo mv /etc/apt/sources.list /etc/apt/old-sources.list"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "cat << EOF | sudo tee /etc/apt/sources.list
deb http://deb.debian.org/debian/ bullseye main contrib non-free
deb-src http://deb.debian.org/debian/ bullseye-updates main contrib non-free
deb http://security.debian.org/debian-security bullseye-security main
deb-src http://security.debian.org/debian-security bullseye-security main
deb http://ftp.debian.org/debian bullseye-backports main contrib non-free
EOF"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo apt update -y && sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade --install-recommends -y"; done
for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo apt update -y && sudo DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef -y --allow-downgrades --allow-remove-essential --allow-change-held-packages --install-recommends full-upgrade"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i 'echo "root:gprm8350" | sudo chpasswd'; done
for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i 'echo "debian:gprm8350" | sudo chpasswd'; done
for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"; done
for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config"; done
for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo systemctl restart sshd"; done
for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo rm -rf /root/.ssh/authorized_keys"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo hostnamectl set-hostname node-$i --static"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo apt update -y && sudo apt-get install -y git vim net-tools wget curl bash-completion apt-utils iperf iperf3 mtr traceroute netcat sshpass socat python3 python3-simplejson xfsprogs locate jq gcc-8-base"; done
for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo apt-get install -y cloud-guest-utils dnsutils cloud-init python3-venv virtualenv mdadm"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo mkdir -p /storage && sudo groupadd rabbitmq"; done

#for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo apt-get install ntp ntpdate -y && sudo timedatectl set-ntp on"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo modprobe -v xfs && sudo grep xfs /proc/filesystems && sudo modinfo xfs && sudo mkdir -p /etc/apt/sources.list.d"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo chmod -x /etc/update-motd.d/*"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i 'cat << EOF | sudo tee /etc/update-motd.d/01-custom
#!/bin/sh
echo "****************************WARNING****************************************
UNAUTHORISED ACCESS IS PROHIBITED. VIOLATORS WILL BE PROSECUTED.
*********************************************************************************"
EOF'; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" ubuntu@node-$i "sudo chmod +x /etc/update-motd.d/01-custom"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" ubuntu@node-$i "cat << EOF | sudo tee /etc/modprobe.d/qemu-system-x86.conf
options kvm_intel nested=1
EOF"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo mkdir -p /etc/systemd/system/networking.service.d"; done
for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "cat << EOF | sudo tee /etc/systemd/system/networking.service.d/reduce-timeout.conf
[Service]
TimeoutStartSec=15
EOF"; done

for i in {1..3}; do virsh shutdown node-$i; done && sleep 10 && virsh list --all && for i in {1..3}; do virsh start node-$i; done && sleep 10 && virsh list --all

sleep 30

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo apt update -y"; done

for i in {1..3}; do qemu-img create -f qcow2 vbdnode1$i 120G; done
for i in {1..3}; do qemu-img create -f qcow2 vbdnode2$i 120G; done
for i in {1..3}; do qemu-img create -f qcow2 vbdnode3$i 120G; done

for i in {1..3}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode1$i.qcow2 -t sda node-$i; done
for i in {1..3}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode2$i.qcow2 -t sdb node-$i; done
for i in {1..3}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode3$i.qcow2 -t sdc node-$i; done

for i in {1..3}; do virsh attach-interface --domain node-$i --type network --source ds1 --model virtio --mac 02:00:aa:0a:01:1$i --config --live; done
for i in {1..3}; do virsh attach-interface --domain node-$i --type network --source ds2 --model virtio --mac 02:00:aa:0a:02:1$i --config --live; done
for i in {1..3}; do virsh attach-interface --domain node-$i --type network --source ss1 --model virtio --mac 02:00:aa:0a:03:1$i --config --live; done
for i in {1..3}; do virsh attach-interface --domain node-$i --type network --source ss2 --model virtio --mac 02:00:aa:0a:04:1$i --config --live; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "cat << EOF | sudo tee /etc/hosts
127.0.0.1 localhost
192.168.20.201  node-1
192.168.20.202  node-2
192.168.20.203  node-3
192.168.20.204  node-4
192.168.20.205  node-5
192.168.20.206  node-6
192.168.20.207  node-7
192.168.20.208  node-8
192.168.20.209  node-9
# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "cat << EOF | sudo tee /etc/sysctl.d/60-lxd-production.conf
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
EOF"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "sudo sysctl --system"; done

for i in {1..3}; do ssh -o "StrictHostKeyChecking=no" debian@node-$i "#echo vm.swappiness=1 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p"; done

for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "modprobe 8021q"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "modprobe bonding"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "lsmod | grep 8021q"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "lsmod | grep bonding"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo 8021q >> /etc/modules-load.d/8021q.conf"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo bonding >> /etc/modules"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo configfs >> /etc/modules"; done

ssh -o "StrictHostKeyChecking=no" debian@node-1 "cat << EOF | sudo tee /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
allow-hotplug eth0
iface eth0 inet dhcp
    mtu 9000
    
allow-hotplug eth1
auto eth1
iface eth1 inet static
    address 192.168.255.11/24
    mtu 9000
    
allow-hotplug eth2
auto eth2
iface eth2 inet static
    address 192.168.250.11/24
    mtu 9000
allow-hotplug eth3
auto eth3
iface eth3 inet manual
    mtu 9000    
source /etc/network/interfaces.d/*.cfg
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@node-1 "cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    ens3:
      dhcp4: true
      dhcp6: false
    ens10:
      dhcp4: false
      dhcp6: false
    ens11:
      dhcp4: false
      dhcp6: false
    ens12:
      dhcp4: false
      dhcp6: false
    ens13:
      dhcp4: false
      dhcp6: false      
  bonds:
    bond1:
      dhcp4: true
      interfaces:
        - ens10
        - ens11
      parameters:
        mode: active-backup
        primary: ens10
    bond2:
      dhcp4: true
      interfaces:
        - ens12
        - ens13
      addresses: [192.168.24.201/24]          
      parameters:
        mode: active-backup
        primary: ens12
  vlans:
    vlan5:
      id: 5
      link: bond1
      addresses: [192.168.21.201/24]
    vlan10:
      id: 10
      link: bond1
      addresses: [192.168.23.201/24]
    vlan20:
      id: 20
      link: bond1
      addresses: [192.168.25.201/24]
    vlan30:
      id: 30
      link: bond1
EOF"

for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo 'Defaults:debian !requiretty' > /etc/sudoers.d/debian"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "echo '%debian ALL=(ALL) ALL' >> /etc/sudoers.d/debian"; done
for i in {1..3}; do sshpass -p gprm8350 ssh -o "StrictHostKeyChecking=no" root@node-$i "chmod 440 /etc/sudoers.d/debian"; done

for i in {1..3}; do virsh shutdown node-$i; done && sleep 10 && virsh list --all && for i in {1..3}; do virsh start node-$i; done && sleep 10 && virsh list --all
