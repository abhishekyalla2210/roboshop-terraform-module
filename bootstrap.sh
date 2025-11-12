#!/bin/bash


sudo dnf install ansible -y
component=$1

REPO_URL=https://github.com/abhishekyalla2210/ansible-roboshop-roles-tf.git

REPO_DIR=/opt/roboshop/ansible
ANSIBLE_DIR=ansible-roboshop-roles-tf

mkdir -p $REPO_DIR
mkdir -p /var/log/roboshop
touch ansible.log

cd $REPO_DIR

if [ -d $ANSIBLE_DIR ]; then
    cd $ANSIBLE_DIR
    git pull
else
    git clone $REPO_URL
    cd $ANSIBLE_DIR
fi
 
ansible-playbook -e MYSQL_ROOT_PASSWORD='Roboshop@1' -e component=$component  main.yaml
