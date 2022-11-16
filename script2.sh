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
printf "\n${magenta}START!! ${clear}️ ⚠️ ⚠️ ⚠️ \n\n"


sudo apt-get update
# it looks like below are no longer required
# sudo snap install bare
# sudo snap install multipass-sshfs

# for virtual env setup
sudo apt-get install python3.10-venv
# useful utility
sudo apt-get install tree

# mysql related
sudo apt-get install mysql-server
sudo apt-get install -y libmysqlclient-dev
if [ ! -f "/usr/bin/pip" ]; then
 sudo apt-get install -y python3-pip
 sudo apt-get install -y python-setuptools
 # sudo ln -s /usr/bin/pip3 /usr/bin/pip
else
 printf "${cyan}pip3${clear} ${green}已安装${clear}\n"
fi


# for convenience
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 2
# create virtual env
python -m venv ~/.virtualenvs/$PROJECT_FOLDER
source ~/.virtualenvs/$PROJECT_FOLDER/bin/activate

# 安装pip etc. 最新版
pip install -U pip # setuptools wrapt
pip install django==4.1.3
pip install mysqlclient==2.1.1
# check python executable path
# import sys, os
# os.path.dirname(sys.executable)



# Setup temp folders in your virtual machine for pycharm to use later
mkdir -p ~/pycharm
mkdir -p ~/pycharm/$PROJECT_FOLDER
ls ~/pycharm

# init twitter project
mkdir -p ~/Home/github
mkdir -p ~/Home/github$PROJECT_FOLDER
ls ~/Home/github
cd ~/Home/github/$PROJECT_FOLDER

# Init your django app named twitter in current directory
django-admin startproject twitter ~/Home/github/$PROJECT_FOLDER
ls ~/Home/github/$PROJECT_FOLDER

# 设置mysql的root账户的密码为yourpassword
# 创建名为twitter的数据库
sudo mysql -u root << EOF
  ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'yourpassword';
  flush privileges;
  show databases;
  CREATE DATABASE IF NOT EXISTS twitter;
EOF
# fi

# 1st round ORM creation
python ~/Home/github/$PROJECT_FOLDER/manage.py migrate
ls ~/Home/github/$PROJECT_FOLDER

# setup superuser (admin:admin 😂😂😂)
# superuser名字
USER="admin"
# superuser密码
PASS="admin"
# superuser邮箱
MAIL="admin@twitter.com"
script="
from django.contrib.auth.models import User;

username = '$USER';
password = '$PASS';
email = '$MAIL';
if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username, email, password);
    print('Superuser created.');
else:
    print('Superuser creation skipped.');
"
printf "$script" | python ~/Home/github/$PROJECT_FOLDER/manage.py shell

printf "\n"
printf '⚠️ ⚠️ ⚠️ \n'
printf "\n"
printf "${bold_red}4${clear} more steps to go!\n\n"
printf "⚠️  ${magenta}1${clear}. At terminal run: '${green}source${clear} ${cyan}~/.virtualenvs/$PROJECT_FOLDER/bin/activate${clear}' to activate your virtual environment\n"
printf "⚠️  ${magenta}1.1${clear}. At terminal run: '${green}cd${clear} ${cyan}~/Home/github/$PROJECT_FOLDER${clear}' to go to your project folder(if not already in it)\n\n"
printf "⚠️  ${magenta}2${clear}. modify twitter/settings.py file at two places:\n"
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
