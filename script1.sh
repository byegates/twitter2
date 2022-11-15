#!/usr/bin/env zsh

# Initial setups
# Testing or real key name
KEY_NAME="multipass-ssh-key"
# KEY_NAME="multitest-ssh-key"
KEY_FILE=~/.ssh/$KEY_NAME


CLOUD_INIT=cloud-init
# CLOUD_INIT=test-init
INIT_FILE=~/.ssh/$CLOUD_INIT.yaml

# test vs real VM name
VM_NAME=lts2204
# VM_NAME=test2204



# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'




echo ''
echo "${magenta}START!!!${clear}"
echo ''

# create the folder only if it doesn't exist
mkdir -p ~/.ssh

# create ssh key, without override existing, below 2 liens are the same, only keeping 1
echo ""
echo "Creating SSH KEY, if exists, will skip (not overwrite)"
echo ""
# echo "n"|ssh-keygen -C ubuntu -b 2048 -t rsa -f $KEY_FILE -q -N ""
ssh-keygen -C ubuntu -b 2048 -t rsa -f $KEY_FILE -q -N "" <<< n
echo ""
echo ""
echo "SSH-KEY created(or existing) ${cyan}$KEY_FILE${clear} & ${cyan}$KEY_FILE.pub${clear} will be used"


# Generate cloud-init.yaml config file
echo ""
echo "⚠️  Creating ${magenta}$INIT_FILE${clear} config file⚠️"
PUBKEY=$(cat $KEY_FILE.pub)
echo ""

cat > $INIT_FILE <<- EOM
users:
  - default
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
    - $PUBKEY
EOM


echo ""
echo "${magenta}$INIT_FILE${clear} ${green}created${clear}(😄?) as below:"
echo ""

cat $INIT_FILE # ${green}${clear}
echo ""

echo ""
echo "⚠️  Launching a new VM with version ubuntu 22.04LTS, named ${cyan}$VM_NAME${clear}, using $INIT_FILE ⚠️"
echo ""

# NODE=test2204b;multipass stop $NODE;multipass delete $NODE;multipass purge
echo "${green}multipass${clear} stop ${cyan}$VM_NAME${clear}"
echo ''
multipass stop $VM_NAME
echo "${green}multipass${clear} delete ${cyan}$VM_NAME${clear}"
echo ''
multipass delete $VM_NAME
echo "${green}multipass${clear} purge"
echo ''
multipass purge
echo "${green}multipass${clear} launch ${magenta}22.04${clear} --name ${cyan}$VM_NAME${clear} --cloud-init ${cyan}$INIT_FILE${clear}"
echo ''
multipass launch 22.04 --name $VM_NAME --cloud-init $INIT_FILE

echo ''
echo "👀 your running Virtual Machines:"
nodes_list=$(multipass list)
echo $nodes_list
ip_addr=$(echo $nodes_list | grep "$VM_NAME " | grep -oE '\d+\.\d+\.\d+\.\d+')

echo ''
echo 'Use below command:'
echo ''
echo "'${magenta}ssh${clear} ubuntu@${green}$ip_addr${clear} -i ${cyan}$KEY_FILE${clear} -o StrictHostKeyChecking=no'"
echo ''
echo 'to connect to the virtual machine you just created!🏅️'

echo ''
echo "Mounting your home folder to ${magenta}/home/ubuntu/Home${clear} on Virtual Node: ${cyan}$VM_NAME${clear}"
multipass mount $HOME $VM_NAME:Home

echo ''
echo "${green}END!!!${clear}🏅️🏅️🏅"
echo ''
