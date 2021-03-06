#!/bin/bash
#

cat > /home/iason/vms/mgmt.xml <<EOF
<network>
  <name>mgmt</name>
  <forward mode='nat'/>
  <bridge name='mgmt' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:ca'/>
  <ip address='192.168.21.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

cat > /home/iason/vms/overlay.xml <<EOF
<network>
  <name>overlay</name>
  <forward mode='nat'/>
  <bridge name='overlay' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:cb'/>
  <ip address='192.168.23.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

cat > /home/iason/vms/external.xml <<EOF
<network>
  <name>external</name>
  <forward mode='nat'/>
  <bridge name='external' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:cc'/>
  <ip address='192.168.20.1' netmask='255.255.255.0'>
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
  <ip address='192.168.24.1' netmask='255.255.255.0'>
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
  <ip address='192.168.22.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

virsh net-define /home/iason/vms/external.xml && virsh net-autostart external && virsh net-start external
virsh net-define /home/iason/vms/mgmt.xml && virsh net-autostart mgmt && virsh net-start mgmt
virsh net-define /home/iason/vms/overlay.xml && virsh net-autostart overlay && virsh net-start overlay
virsh net-define /home/iason/vms/storage.xml && virsh net-autostart storage && virsh net-start storage
virsh net-define /home/iason/vms/provider.xml && virsh net-autostart provider && virsh net-start provider

ip a && sudo virsh net-list --all
