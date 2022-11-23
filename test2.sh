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

if [ $# -gt 0 ]; then
  printf "${green}Argument provided, testing mode${clear}\n"
  PROJECT_FOLDER=$1
fi

printf "\nProject Folder will be named: ${cyan}${PROJECT_FOLDER}${clear}\n\n"
printf "\n${magenta}START!! ${clear}... ⚠️ ⚠️ ⚠️ \n\n"

sudo apt-get install tree

# Setup temp folders in your virtual machine for pycharm to use later
mkdir -p ~/pycharm
mkdir -p ~/pycharm/$PROJECT_FOLDER
printf "\nWorking directory for pycharm: ${green}$PROJECT_FOLDER${clear} in ${green}~/pycharm${clear} (on ubuntu, only)\n\n"
printf "$green"
ls ~/pycharm
printf "$clear\n"

# init twitter project
mkdir -p ~/Home/github
mkdir -p ~/Home/github$PROJECT_FOLDER
printf "\nProject folder: ${green}$PROJECT_FOLDER${clear} created in ${green}~/Home/github${clear} (on ubuntu, on your mac it will be under: ~/github\n\n"
printf "$green"
ls -lsa ~/Home/github
printf "$clear\n"
cd ~/Home/github/$PROJECT_FOLDER

# Init your django app named twitter in current directory
# django-admin startproject twitter ~/Home/github/$PROJECT_FOLDER
printf "\nWhat's currently in project folder:\n\n"
printf "$green"
curl -sSL -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore
ls -lsa ~/Home/github/$PROJECT_FOLDER
printf "$clear\n"

printf '\n⚠️ ⚠️ ⚠️ \n'
printf "\n${bold_red}4${clear} more steps to go!\n\n"
printf "⚠️  ${magenta}1${clear}. At terminal run: '${green}source${clear} ${cyan}~/.virtualenvs/$PROJECT_FOLDER/bin/activate${clear}' to activate your virtual environment\n"
printf "⚠️  ${magenta}1.1${clear}. At terminal run: '${green}cd${clear} ${cyan}~/Home/github/$PROJECT_FOLDER${clear}' to go to your project folder(if not already in it)\n\n"
printf "⚠️  ${magenta}2${clear}. modify ${green}twitter/settings.py${clear} file at two places:\n"
printf "    ${magenta}2.1${clear} Add your virtual machine ip to ALLOWED_HOSTS like: ALLOWED_HOSTS = [$cyan'192.168.64.6'$clear]\n"
printf "    ${magenta}2.2${clear} Replace DATABASES in the file as below:\n\n"
cat << EOM
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'twitter',
        'HOST': 'localhost',
        'PORT': '3306',
        'USER': 'root',
        'PASSWORD': 'yourpassword',
    }
}
EOM
printf "\n"
printf "⚠️  ${magenta}3${clear}. At terminal run '${cyan}python manage.py runserver 0.0.0.0:8000${clear}' to start your web app!\n\n"
printf "⚠️  ${magenta}4${clear}. Go to your Browser, use your virtual machine ip with port 8000(e.g.: '${cyan}192.168.64.${red}2$cyan:8000$clear') to view your web app!\n\n"
printf '⚠️ ⚠️ ⚠️ \n\n'

printf "\n${green}END!!!${clear}🏅️🏅️🏅\n\n"
