#!/bin/bash


# To generate the SSH Key
ssh-keygen -t rsa -N ""  -f /root/.ssh/id_rsa


# UPDATE & UPGRADE
yum update -y
yum upgrade -y
yum install wget -y
yum install git -y

# INSTALLING ANSIBLE PACKAGES
yum install epel-release -y
yum install ansible -y
sed -i -r 's/#host_key_checking = False/host_key_checking = False/' /etc/ansible/ansible.cfg
mv /etc/ansible/hosts /etc/ansible/hosts.org
echo "[Controller]" > /etc/ansible/hosts
echo "10.194.100.11 ansible_ssh_user=centos" >> /etc/ansible/hosts
echo "[Storage]" >> /etc/ansible/hosts
echo "10.194.100.12 ansible_ssh_user=centos" >> /etc/ansible/hosts
echo "[Compute]" >> /etc/ansible/hosts
echo "10.194.100.13 ansible_ssh_user=centos" >> /etc/ansible/hosts


# INSTALLING TERRAFORM PACKAGES
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform


# PULLING TERRAFORM FILES FROM GIT FOR CREATING EC2 VMs
mkdir /EC2Instance/
cd /EC2Instance/
git clone https://github.com/manish5133/ec2serversterraform.git
cd ec2serversterraform/
sed -i -r 's/access_key = ""/access_key = "ChangeHere"/' /EC2Instance/ec2serversterraform/provider.tf
sed -i -r 's%secret_key = ""%secret_key = "ChangeHere"%' /EC2Instance/ec2serversterraform/provider.tf
terraform init
terraform plan
terraform apply


# Update Hostname in All Servers
echo -ne '\n' "[ALLSERVER]" >> /etc/ansible/hosts
echo -ne '\n' "10.194.100.11 hostname=Controller" >> /etc/ansible/hosts
echo -ne '\n' "10.194.100.12 hostname=Storage" >> /etc/ansible/hosts
echo -ne '\n' "10.194.100.13 hostname=Compute" >> /etc/ansible/hosts


# Run Ansible Script to set hostname
ansible-playbook hostnamechange.yml  
