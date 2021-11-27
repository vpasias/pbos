#!/bin/bash
#

cat > /home/iason/vms/mgmt.xml <<EOF
<network>
  <name>mgmt</name>
  <forward mode='nat'/>
  <bridge name='mgmt' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:ca'/>
  <ip address='192.168.200.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

cat > /home/iason/vms/admin.xml <<EOF
<network>
  <name>admin</name>
  <forward mode='nat'/>
  <bridge name='admin' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:cc'/>
  <ip address='192.168.254.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

cat > /home/iason/vms/storage.xml <<EOF
<network>
  <name>storage</name>
  <forward mode='nat'/>
  <bridge name='storage' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:cd'/>
  <ip address='192.168.250.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

cat > /home/iason/vms/provider.xml <<EOF
<network>
  <name>provider</name>
  <forward mode='nat'/>
  <bridge name='provider' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:ce'/>
  <ip address='192.168.230.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

virsh net-define /home/iason/vms/admin.xml && virsh net-autostart admin && virsh net-start admin
virsh net-define /home/iason/vms/mgmt.xml && virsh net-autostart mgmt && virsh net-start mgmt
virsh net-define /home/iason/vms/storage.xml && virsh net-autostart storage && virsh net-start storage
virsh net-define /home/iason/vms/provider.xml && virsh net-autostart provider && virsh net-start provider

ip a && sudo virsh net-list --all
