Create Rocky Linux 8 Cloud Image

This is a guide to create Rocky Linux 8 cloud image.

Download Rocky Linux 8.5 minimal iso.:

# cd /mnt/extra/virt/images && curl -sLO http://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.5-x86_64-minimal.iso && ls -la && cd /mnt/extra/kvm-install-vm/pbos/rocky

Create root and rocky sha512 hash password using the following command:

### root password
# python3 -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'

### rocky password
# python3 -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'

Edit ks.cfg to put root and user password.:

rootpw --iscrypted <sha512_root_password>
user --name=rocky --iscrypted --password <sha512_user_password>

Run rocky_build.sh.

./rocky_build.sh

After installation is done, log in as a root:

localhost login: root
Password: <root-password-in-kickstart>

upgrade packages and reboot.:

# dnf -y update
# reboot

Log in again and install what you want.:

# dnf -y install cloud-utils-growpart curl epel-release python3 bind-utils
# dnf -y install openssh-server cloud-init sshpass

Configure cloud-init and set clex as default login user:

# vi /etc/cloud/cloud.cfg
...
ssh_pwauth: 1
...
system_info:
  default_user:
    name: rocky
    lock_passwd: false
    gecos: VIPNET User
    groups: [adm, systemd-journal]
    sudo: ["ALL=(ALL) ALL"]
    shell: /bin/bash

Enable sshd and cloud-init services.:

# systemctl enable cloud-init sshd

Run cleanup.sh inside the VM.:

# vi cleanup.sh  # copy text from cleanup.sh
# chmod +x cleanup.sh
# ./cleanup.sh

Exit the console.:

# rm -f cleanup.sh
# cat /dev/null > ~/.bash_history && history -c && shutdown -h now

Press CTRL+] to close VM console.

Run virt-sysprep for the VM domain.:

# virt-sysprep -d rocky-linux-8

Trim the image.:

# cd /mnt/extra/virt/images && mv rocky-8.5-x86_64-genericcloud.qcow2 rocky-8.5-x86_64-genericcloud.qcow2.new && \
qemu-img convert -O qcow2 rocky-8.5-x86_64-genericcloud.qcow2.new CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2

It shrank down from 5GiB to about 1.8GiB.
