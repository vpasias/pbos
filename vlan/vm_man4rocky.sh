#!/bin/bash
# vm_man.sh: VM image manipulation script.
#

VIRTC="/usr/bin/virt-customize"

# Check if the script is run by root.
if [ ${UID} -eq 0 ]
then
    echo "Error) Do not run this script as root."
    exit 1
fi

USAGE() {
    echo "Usage: $0 -f <qcow2_image_file> [-u <userid_to_add>] [-h <hostname>]" 1>&2
    exit 1
}
# Check arguments.
while getopts f:u:h: opt
do
    case "${opt}" in
        f)
            IMGFILE="${OPTARG}"
            ;;
        u)
            USERID="${OPTARG}"
            ;;
        h)
            HOSTN="${OPTARG}"
            ;;
        \?)
            USAGE
            exit 1
            ;;
    esac
done

# Check if virt-customize exists.
if [ ! -x ${VIRTC} ]
then
    echo "Error) There is no virt-customize commmand."
    exit 1
fi

# Check if all the necessary options got.
if [ x"$IMGFILE" == x ]
then
    USAGE
    exit 1
fi
# If $HOSTN is empty, set it to $IMGFILE without extension
if [ x"$HOSTN" == x ]
then
    HOSTN=$(basename "$IMGFILE" | cut -f1 -d'.')
fi
# Check if $IMGFILE exists.
if [ ! -f "$IMGFILE" ]
then
    echo "$IMGFILE does not exists."
    exit 1
fi

# Edit the following variables until "Do not edit below!!!"
# packages to install
IPKGS="less,sudo,vim,man-db,epel-release,bind-utils,telnet,curl,python3"
# packages to remove
RPKGS=""
# DNS server
DNSSERVER="8.8.8.8"
# Timezone
TIMEZONE="America/Denver"
# Do not edit below!!!

#    --uninstall ${RPKGS} \
#    --firstboot-command "dnf -y install sshpass" \
#    --install ${IPKGS} \
$VIRTC -a ${IMGFILE} \
    --hostname ${HOSTN} \
    --upload data/hosts:/etc/hosts \
    --upload /tmp/ifcfg-eth0:/etc/sysconfig/network-scripts/ifcfg-eth0 \
    --upload /tmp/ifcfg-eth1:/etc/sysconfig/network-scripts/ifcfg-eth1 \
    --upload /tmp/ifcfg-eth2:/etc/sysconfig/network-scripts/ifcfg-eth2 \
    --upload /tmp/ifcfg-eth3:/etc/sysconfig/network-scripts/ifcfg-eth3 \
    --ssh-inject ${USERID} \
    --firstboot-command "echo nameserver ${DNSSERVER} > /etc/resolv.conf" \
    --run-command "dnf -y remove cloud-init"
