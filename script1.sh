#!/usr/bin/env zsh

# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'

printf "\n${magenta}START!! ${clear}️ ⚠️ ⚠️ ⚠️ \n\n"

# testing file names
KEY_NAME=multipass-ssh-key
CLOUD_INIT=cloud-init
VM_NAME=lts2204
script=script2

if [ $# -gt 0 ]; then
  VM_NAME=$1
fi
if [ $# -gt 1 ]; then
  script=$2
fi
printf "${green} KEY_NAME${clear}: ${cyan}$KEY_NAME${clear}\n"
printf "${green}INIT_NAME${clear}: ${cyan}$CLOUD_INIT${clear}\n"
printf "${green}  VM_NAME${clear}: ${cyan}$VM_NAME${clear}\n"
printf "${green}   Script${clear}: ${cyan}$script${clear}\n"
INIT_FILE=$CLOUD_INIT.yaml

# create the folder only if it doesn't exist
mkdir -p ~/.ssh

# create ssh key, without override existing, below 2 liens are the same, only keeping 1
# to be added to ~/.ssh/authorized_keys on VM later
printf "\nCreating SSH KEY, if exists, will skip (not overwrite)\n\n"
# printf "n"|ssh-keygen -C ubuntu -b 2048 -t rsa -f ~/.ssh/$KEY_NAME -q -N ""
ssh-keygen -C ubuntu -b 2048 -t rsa -f ~/.ssh/$KEY_NAME -q -N "" <<< n
printf "\n\nSSH-KEY created(or existing) ${cyan}~/.ssh/$KEY_NAME${clear} & ${cyan}~/.ssh/$KEY_NAME.pub${clear} will be used\n"

# Generate cloud-init.yaml config file
printf "\n⚠️  Creating ${magenta}~/.ssh/$INIT_FILE${clear} config file⚠️\n"
PUBKEY=$(cat ~/.ssh/$KEY_NAME.pub)
printf "\n"

init_script="bash $script.sh | tee $script.txt"
cat > ~/.ssh/$INIT_FILE <<- EOM
users:
  - default
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
    - $PUBKEY
runcmd:
- cd /home/ubuntu
- curl -L -o $script.sh 'https://raw.githubusercontent.com/byegates/twitter2/main/$script.sh'
- # $init_script
EOM

printf "\n${magenta}~/.ssh/$INIT_FILE${clear} ${green}created${clear}(😄?) as below:\n\n"

cat ~/.ssh/$INIT_FILE # ${green}${clear}
printf "\n"

printf "\n⚠️  Launching a new VM with version ${magenta}ubuntu 22.04LTS${clear}, named ${cyan}$VM_NAME${clear}, using ${cyan}~/.ssh/$INIT_FILE${clear} ⚠️\n\n"

# NODE=test2204b;multipass stop $NODE;multipass delete $NODE;multipass purge
printf "${green}multipass${clear} stop ${cyan}$VM_NAME${clear}\n\n"
multipass stop $VM_NAME
printf "${green}multipass${clear} delete ${cyan}$VM_NAME${clear}\n\n"
multipass delete $VM_NAME
printf "${green}multipass${clear} purge\n\n"
multipass purge
printf "${green}multipass${clear} launch ${magenta}22.04${clear} --name ${cyan}$VM_NAME${clear} --cloud-init ${cyan}~/.ssh/$INIT_FILE${clear}\n\n"
multipass launch 22.04 --name $VM_NAME --cloud-init ~/.ssh/$INIT_FILE

printf "\n👀 your running Virtual Machines(use '${green}multipass list${clear}' command):\n"
nodes_list=$(multipass list)
printf $nodes_list
ip_addr=$(printf $nodes_list | grep "$VM_NAME " | grep -oE '\d+\.\d+\.\d+\.\d+')

printf "\nMounting your home folder to ${magenta}/home/ubuntu/Home${clear} on Virtual Node: ${cyan}$VM_NAME${clear}\n"
multipass set local.privileged-mounts=Yes # just in case
multipass mount $HOME $VM_NAME:Home

printf "\n🏅Open a new terminal to run: '${green}ssh ubuntu@${magenta}$ip_addr ${green}-i ~/.ssh/$KEY_NAME -o StrictHostKeyChecking=no${clear}' to ssh into your new VM"
printf "\n🥈Then run '${green}${init_script}${clear}' at the ${red}new terminal${clear} of your ${red}new VM${clear}\n\n"

printf "\n${green}END!!!${clear}🏅️🏅️🏅\n\n"
