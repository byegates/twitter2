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

echo -e "\n${magenta}START!! ${clear}️ ⚠️ ⚠️ ⚠️ \n\n"

# testing file names
KEY_NAME=id_rsa
CLOUD_INIT=cloud-init
VM_NAME=lts2204
script=script2

if [ $# -gt 0 ]; then
  VM_NAME=$1
fi
if [ $# -gt 1 ]; then
  script=$2
fi
echo -e "${green} KEY_NAME${clear}: ${cyan}$KEY_NAME${clear}"
echo -e "${green}INIT_NAME${clear}: ${cyan}$CLOUD_INIT${clear}"
echo -e "${green}  VM_NAME${clear}: ${cyan}$VM_NAME${clear}"
echo -e "${green}   Script${clear}: ${cyan}$script${clear}"
INIT_FILE=$CLOUD_INIT.yaml

# create the folder only if it doesn't exist
mkdir -p ~/.ssh

# create ssh key, without override existing, below 2 liens are the same, only keeping 1
# to be added to ~/.ssh/authorized_keys on VM later
echo -e "\nCreating SSH KEY, No Overwrite\n"
# echo -e "n"|ssh-keygen -C ubuntu -b 2048 -t rsa -f ~/.ssh/$KEY_NAME -q -N ""
echo -e "\n\nSSH-KEY created(or existing) ${cyan}~/.ssh/$KEY_NAME${clear} & ${cyan}~/.ssh/$KEY_NAME.pub${clear} will be used\n"

# Generate cloud-init.yaml config file
echo -e "\n⚠️  Creating ${magenta}~/.ssh/$INIT_FILE${clear} config file⚠️\n"
PUBKEY=$(cat ~/.ssh/$KEY_NAME.pub)

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

echo -e "${magenta}~/.ssh/$INIT_FILE${clear} ${green}created${clear}(😄?) as below:\n"

cat ~/.ssh/$INIT_FILE

echo -e "\n⚠️  Launching a new VM with version ${magenta}ubuntu 22.04LTS${clear}, named ${cyan}$VM_NAME${clear}, using ${cyan}~/.ssh/$INIT_FILE${clear} ⚠️\n"

echo -e "${green}multipass${clear} delete --purge ${cyan}$VM_NAME${clear}\n"

echo -e "${green}multipass${clear} launch ${magenta}22.04${clear} --name ${cyan}$VM_NAME${clear} --cloud-init ${cyan}~/.ssh/$INIT_FILE${clear}\n\n"


echo -e "\n👀 your running Virtual Machines(use '${green}multipass list${clear}' command):\n"
multipass list
ip_addr=$(multipass list | grep "$VM_NAME " | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
echo -e "\nip of your VM: ${cyan}$ip_addr${clear}\n"

echo -e "Mounting your home folder to ${magenta}/home/ubuntu/Home${clear} on Virtual Node: ${cyan}$VM_NAME${clear}\n"
sleep 3
multipass set local.privileged-mounts=Yes # just in case
multipass mount "$HOME" "$VM_NAME":Home
echo -e "\nIf mount failed, run '${cyan}multipass mount $HOME $VM_NAME:Home${clear}' in your ${cyan}Mac/Windows${clear} terminal to mount again\!\n"

echo -e "🏅Open a new ${red}terminal Tab${clear}, run: '${green}ssh ubuntu@${magenta}$ip_addr ${green}-i ~/.ssh/$KEY_NAME -o StrictHostKeyChecking=no${clear}' to ssh into your VM"
echo -e "🥈Then run '${cyan}ls ~/Home${clear}' ${cyan}INSIDE your VM${clear} to verify mount action: You should see lots of folders inside ~/Home\!"
echo -e "🥉Then run '${green}${init_script}${clear}' at the ${red}new terminal${clear} of your ${red}new VM${clear}"

echo -e "\n${green}END\!\!\!${clear}🏅️🏅️🏅\n"
