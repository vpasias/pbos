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

cat > /home/iason/vms/l1s1.xml <<EOF
<network>
  <name>l1s1</name>
  <bridge name='l1s1' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

cat > /home/iason/vms/l1s2.xml <<EOF
<network>
  <name>l1s2</name>
  <bridge name='l1s2' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

cat > /home/iason/vms/l1s3.xml <<EOF
<network>
  <name>l1s3</name>
  <bridge name='l1s3' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

cat > /home/iason/vms/l2s1.xml <<EOF
<network>
  <name>l2s1</name>
  <bridge name='l2s1' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

cat > /home/iason/vms/l2s2.xml <<EOF
<network>
  <name>l2s2</name>
  <bridge name='l2s2' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

cat > /home/iason/vms/l2s3.xml <<EOF
<network>
  <name>l2s3</name>
  <bridge name='l2s3' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

virsh net-define /home/iason/vms/mgmt.xml && virsh net-autostart mgmt && virsh net-start mgmt
virsh net-define /home/iason/vms/l1s1.xml && virsh net-autostart l1s1 && virsh net-start l1s1
virsh net-define /home/iason/vms/l1s2.xml && virsh net-autostart l1s2 && virsh net-start l1s2
virsh net-define /home/iason/vms/l1s3.xml && virsh net-autostart l1s3 && virsh net-start l1s3
virsh net-define /home/iason/vms/l2s1.xml && virsh net-autostart l2s1 && virsh net-start l2s1
virsh net-define /home/iason/vms/l2s2.xml && virsh net-autostart l2s2 && virsh net-start l2s2
virsh net-define /home/iason/vms/l2s3.xml && virsh net-autostart l2s3 && virsh net-start l2s3

ip a && sudo virsh net-list --all && sudo ovs-vsctl show
