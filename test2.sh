#!/usr/bin/env bash

# Color variables
red='\033[0;31m'
bold_red='\033[1;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'

# Project Folder name
PROJECT_FOLDER=twitter
file_limit=8
lvl=2

if [ $# -gt 0 ]; then
  PROJECT_FOLDER=$1
fi

echo -e "\n${magenta}START!! ${clear}... ⚠️ ⚠️ ⚠️ \n"
echo -e "Project Folder to use: ${cyan}${PROJECT_FOLDER}${clear}\n"

sudo apt install tree

echo -e "\nCreating python virtual environment '${cyan}~/.virtualenvs/$PROJECT_FOLDER${clear}':\n\n"
# Setup temp folders in your virtual machine for pycharm to use later
mkdir -p ~/pycharm/"$PROJECT_FOLDER"
echo -e "\nWorking directory for pycharm: ${green}$PROJECT_FOLDER${clear} in ${green}~/pycharm${clear} (only on ubuntu)\n\n"
tree -L $lvl --filelimit $file_limit ~/pycharm

# init twitter project
mkdir -p ~/Home/github/"$PROJECT_FOLDER"
echo -e "\nProject folder '${green}$PROJECT_FOLDER${clear}' created in ${green}~/Home/github${clear} (${green}~/github${clear} on your mac)\n"
tree -L $lvl --filelimit $file_limit ~/Home/github/"$PROJECT_FOLDER"
cd ~/Home/github/"$PROJECT_FOLDER"

# Init your django app named twitter in current directory
echo -e "\n\nProject folder before '${cyan}django-admin startproject twitter .${clear}':\n\n"
tree -L $lvl --filelimit $file_limit ~/Home/github/"$PROJECT_FOLDER"

ipv4=$(hostname -I | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}")

settings_file=twitter/settings.py
echo -e "\nAdding your VM ip: ${cyan}${ipv4}${clear} to ${yellow}ALLOWED_HOSTS${clear} in ${cyan}$settings_file${clear} file:\n\n"
< $settings_file grep ALLOWED_HOSTS
echo -e " --->\n"
sed -i'.bkup' "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['${ipv4}'\]/g" "${settings_file}"
< $settings_file grep ALLOWED_HOSTS
echo -e "\n"
mv $settings_file.bkup $settings_file

echo -e "\n# User Added\n cd ~/Home/github/$PROJECT_FOLDER" >> ~/.bashrc

echo -e "\n⚠️ ⚠️ ⚠️ \n${bold_red}4${clear} more steps to go!\n"
echo -e "⚠️  ${magenta}1${clear}. ALWAYS ACTIVATE PYTHON VIRTUAL ENV BY RUNNING: '${green}source${clear} ${cyan}~/.virtualenvs/$PROJECT_FOLDER/bin/activate${clear}' before you do anything, MAKE A NOTE!!!"
echo -e "⚠️  ${magenta}1.1${clear}. Always go to your project folder: '${green}cd${clear} ${cyan}~/Home/github/$PROJECT_FOLDER${clear}' first on ubuntu before you do anything, MAKE A NOTE!!!"
echo -e "\n⚠️  ${magenta}2${clear}. ${green}twitter/settings.py${clear} was modified to use local_settings.py, which have ${yellow}mysql${clear} configs as below:"
echo -e "\nWhats changed in ${green}$settings_file${clear} to use the correct IP and local_settings:\n"
diff $settings_file.bkup $settings_file
echo -e "\nMYSQL Config in ${green}twitter/local_settings.py${clear}\n${yellow}"
cat twitter/local_settings.py
echo -e "${clear}"
echo -e "⚠️  ${magenta}3${clear}. At terminal run '${cyan}python manage.py runserver 0.0.0.0:8000${clear}' to start your web app!\n"
echo -e "⚠️  ${magenta}4${clear}. Go to your Browser, enter '${magenta}${ipv4}${clear}:${cyan}8000$clear' to view your web app!\n"

echo -e "\n${green}END!!!${clear}🏅️🏅️🏅\n\n"
