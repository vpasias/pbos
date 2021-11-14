#! /bin/sh

#export LC_ALL=C
unset LC_ALL
export LC_ALL='en_US.utf8'
export LC_CTYPE="UTF-8",
export LANG="en_US.UTF-8"

# ---- PART ONE ------
# Configure SSH connectivity from 'deployment' - n1 to Target Hosts 

rm -f /home/rocky/.ssh/known_hosts
rm -f /home/rocky/.ssh/id_rsa
rm -f /home/rocky/.ssh/id_rsa.pub

echo 'run-conf.sh: Establish Connectivity'
ssh-keygen -q -t rsa -N "" -f /home/rocky/.ssh/id_rsa

sshpass -p gprm8350 ssh-copy-id -o StrictHostKeyChecking=no rocky@n1
sshpass -p gprm8350 ssh-copy-id -o StrictHostKeyChecking=no rocky@n2
sshpass -p gprm8350 ssh-copy-id -o StrictHostKeyChecking=no rocky@n3
sshpass -p gprm8350 ssh-copy-id -o StrictHostKeyChecking=no rocky@n4
sshpass -p gprm8350 ssh-copy-id -o StrictHostKeyChecking=no rocky@n5
sshpass -p gprm8350 ssh-copy-id -o StrictHostKeyChecking=no rocky@n6

echo 'run-conf.sh: Check Connectivity'

ssh -o StrictHostKeyChecking=no rocky@n1 "uname -a"
ssh -o StrictHostKeyChecking=no rocky@n2 "uname -a"
ssh -o StrictHostKeyChecking=no rocky@n3 "uname -a"
ssh -o StrictHostKeyChecking=no rocky@n4 "uname -a"
ssh -o StrictHostKeyChecking=no rocky@n5 "uname -a"
ssh -o StrictHostKeyChecking=no rocky@n6 "uname -a"

echo 'run-conf.sh: Establish Virtual Environment'

python3 -m venv ~/.envs/pbos

source ~/.envs/pbos/bin/activate

echo 'run-conf.sh: Install Ansible and dependencies'

python -m pip install -U pip
python -m pip install wheel
python -m pip install ansible pymysql openstacksdk

echo 'run-conf.sh: Clone PBOS repository'
# https://github.com/iorchard/pbos-ansible

git clone https://github.com/iorchard/pbos-ansible.git && cd pbos-ansible

export MYSITE="pbos"
cp -a inventory/default inventory/$MYSITE
cp -a /home/rocky/pbos/hosts-rocky inventory/$MYSITE/hosts

sed "s/MYSITE/$MYSITE/" ansible.cfg.sample > ansible.cfg

echo 'run-conf.sh: Set passwords'
./vault.sh

cp -a /home/rocky/pbos/vars-rocky.yml inventory/$MYSITE/group_vars/all/vars.yml

echo 'run-conf.sh: Check connectivity'
ansible -m ping all

echo 'run-conf.sh: Install PBOS'
ansible-galaxy role install --force --role-file requirements.yml

ansible-playbook site.yml
