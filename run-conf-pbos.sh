#! /bin/sh

export LC_ALL=C
export LC_CTYPE="UTF-8",
export LANG="en_US.UTF-8"

# ---- PART ONE ------
# Configure SSH connectivity from 'deployment' - n1 to Target Hosts 

rm -f /home/ubuntu/.ssh/known_hosts
rm -f /home/ubuntu/.ssh/id_rsa
rm -f /home/ubuntu/.ssh/id_rsa.pub

echo 'run-conf.sh: Establish Connectivity'
ssh-keygen -q -t rsa -N "" -f /home/ubuntu/.ssh/id_rsa

sshpass -p kyax7344 ssh-copy-id -o StrictHostKeyChecking=no ubuntu@n1
sshpass -p kyax7344 ssh-copy-id -o StrictHostKeyChecking=no ubuntu@n2
sshpass -p kyax7344 ssh-copy-id -o StrictHostKeyChecking=no ubuntu@n3
sshpass -p kyax7344 ssh-copy-id -o StrictHostKeyChecking=no ubuntu@n4
sshpass -p kyax7344 ssh-copy-id -o StrictHostKeyChecking=no ubuntu@n5
sshpass -p kyax7344 ssh-copy-id -o StrictHostKeyChecking=no ubuntu@n6

echo 'run-conf.sh: Check Connectivity'

ssh -o StrictHostKeyChecking=no ubuntu@n1 "uname -a"
ssh -o StrictHostKeyChecking=no ubuntu@n2 "uname -a"
ssh -o StrictHostKeyChecking=no ubuntu@n3 "uname -a"
ssh -o StrictHostKeyChecking=no ubuntu@n4 "uname -a"
ssh -o StrictHostKeyChecking=no ubuntu@n5 "uname -a"
ssh -o StrictHostKeyChecking=no ubuntu@n6 "uname -a"

echo 'run-conf.sh: Establish Virtual Environment'

python3 -m venv ~/.envs/pbos

source ~/.envs/pbos/bin/activate

echo 'run-conf.sh: Install Ansible and dependencies'

python -m pip install -U pip
python -m pip install wheel
python -m pip install ansible pymysql openstacksdk

echo 'run-conf.sh: Install PBOS'
# https://github.com/iorchard/pbos-ansible

git clone https://github.com/iorchard/pbos-ansible.git && cd pbos-ansible

export MYSITE="pbos"
cp -a inventory/default inventory/$MYSITE
cp -a /home/ubuntu/pbos/hosts inventory/$MYSITE/hosts

sed "s/MYSITE/$MYSITE/" ansible.cfg.sample > ansible.cfg
./vault.sh

cp -a /home/ubuntu/pbos/vars.yml inventory/$MYSITE/group_vars/all/vars.yml

ansible -m ping all

ansible-galaxy role install --force --role-file requirements.yml

ansible-playbook site.yml

source ~/.bashrc

ceph -s && ceph health
openstack service list && openstack server list && openstack endpoint list && openstack catalog list && openstack image list && \
openstack flavor list && openstack network list && openstack subnet list && openstack project list && openstack port list && openstack user list && \
openstack network agent list && openstack hypervisor list && openstack volume list && openstack floating ip list

# Testing
# ./scripts/openstack_test.sh
# VM IP = 192.168.22.195
# ssh cirros@192.168.22.195
