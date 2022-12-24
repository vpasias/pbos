#!/bin/bash
#

cat > /home/iason/vms/mgmt.xml <<EOF
<network>
  <name>mgmt</name>
  <forward mode='nat'/>
  <bridge name='mgmt' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:ca'/>
  <ip address='192.168.20.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

cat > /home/iason/vms/ds1.xml <<EOF
<network>
  <name>ds1</name>
  <forward mode='nat'/>  
  <bridge name='ds1' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:cb'/>
  <ip address='192.168.21.1' netmask='255.255.255.0'>
  </ip>  
</network>
EOF

cat > /home/iason/vms/ds2.xml <<EOF
<network>
  <name>ds2</name>
  <forward mode='nat'/>    
  <bridge name='ds2' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:cc'/>
  <ip address='192.168.31.1' netmask='255.255.255.0'>
  </ip>    
</network>
EOF

cat > /home/iason/vms/ss1.xml <<EOF
<network>
  <name>ss1</name>
  <bridge name='ss1' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

cat > /home/iason/vms/ss2.xml <<EOF
<network>
  <name>ss2</name>
  <bridge name='ss2' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

virsh net-define /home/iason/vms/mgmt.xml && virsh net-autostart mgmt && virsh net-start mgmt
virsh net-define /home/iason/vms/ds1.xml && virsh net-autostart ds1 && virsh net-start ds1
virsh net-define /home/iason/vms/ds2.xml && virsh net-autostart ds2 && virsh net-start ds2
virsh net-define /home/iason/vms/ss1.xml && virsh net-autostart ss1 && virsh net-start ss1
virsh net-define /home/iason/vms/ss2.xml && virsh net-autostart ss2 && virsh net-start ss2

ip a && sudo virsh net-list --all && sudo ovs-vsctl show
