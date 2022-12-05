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

proj_full_path=~/Home/github/"$PROJECT_FOLDER"
venv_full_path=~/.virtualenvs/"$PROJECT_FOLDER"
echo -e "Project Folder to use: ${cyan}${proj_full_path}${clear}"
echo -e "Venv    Folder to use: ${cyan}${venv_full_path}${clear}\n"

# pull list of latest packages
sudo apt update

# useful utility
sudo apt install tree

# for virtual env setup
sudo apt install python3.10-venv
# memcached, for later use
sudo apt install memcached libmemcached-tools redis

# mysql related
sudo apt install mysql-server
sudo apt install -y libmysqlclient-dev

# install java for hbase
sudo apt install openjdk-8-jdk-headless

if [ ! -f "/usr/bin/pip" ]; then
 sudo apt install -y python3-pip
 sudo apt install -y python-setuptools
else
 echo -e "${cyan}pip3${clear} ${green}已安装${clear}\n"
fi

# for convenience
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 2
# delete virtual env first
echo -e "\nCreating python virtual environment '${cyan}$venv_full_path${clear}':\n\n"
rm -rf "$venv_full_path"
# create virtual env
python -m venv "$venv_full_path"
source "$venv_full_path"/bin/activate

# 安装pip etc. 最新版
python -m pip install -U pip setuptools wheel

# Setup temp folders in your virtual machine for pycharm to use later
mkdir -p ~/pycharm/"$PROJECT_FOLDER"
echo -e "\nWorking directory for pycharm: ${green}$PROJECT_FOLDER${clear} in ${green}~/pycharm${clear} (only on ubuntu)\n\n"
tree -L $lvl --filelimit $file_limit ~/pycharm

# init twitter project
mkdir -p "$proj_full_path"
echo -e "\nProject folder '${green}$PROJECT_FOLDER${clear}' created in ${green}~/Home/github${clear} (${green}~/github${clear} on your mac)\n"
tree -L $lvl --filelimit $file_limit "$proj_full_path"
cd "$proj_full_path"
curl -sSL -o requirements.txt https://raw.githubusercontent.com/byegates/twitter2/main/requirements.txt
pip install -r requirements.txt

# 设置mysql的root账户的密码为yourpassword
# 创建名为twitter的数据库
echo -e "\n\n${red}"
sudo mysql -u root << EOF
  ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'yourpassword';
  flush privileges;
  show databases;
  SELECT '---------------' as '';
  SELECT 'Before vs After' as '';
  SELECT '---------------' as '';
  CREATE DATABASE IF NOT EXISTS twitter;
  show databases;
EOF
echo -e "${clear}"
# fi

# Init your django app named twitter in current directory
curl -sSL -o .gitignore https://raw.githubusercontent.com/byegates/twitter2/main/.gitignore
echo -e "\n\nProject folder before '${cyan}django-admin startproject twitter .${clear}':\n\n"
tree -L $lvl --filelimit $file_limit "$proj_full_path"

django-admin startproject twitter .

echo -e "\nProject folder after '${cyan}django-admin startproject twitter .${clear}':\n\n"
tree -L $lvl --filelimit $file_limit "$proj_full_path"

ipv4=$(hostname -I | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}")

settings_file=twitter/settings.py
echo -e "\nAdding your VM ip: ${cyan}${ipv4}${clear} to ${yellow}ALLOWED_HOSTS${clear} in ${cyan}$settings_file${clear} file:\n\n"
< $settings_file grep ALLOWED_HOSTS
echo -e " --->\n"
sed -i'.bkup' "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['${ipv4}'\]/g" "${settings_file}"
< $settings_file grep ALLOWED_HOSTS
echo -e "\n"
# mv $settings_file.bkup $settings_file

# Add sql db settings in local_settings
cat >> twitter/local_settings.py <<- EOM
# Database
# https://docs.djangoproject.com/en/4.1/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'twitter',
        'HOST': '0.0.0.0',
        'PORT': '3306',
        'USER': 'root',
        'PASSWORD': 'yourpassword',
    }
}
EOM

# import local settings into settings
cat >> twitter/settings.py <<- EOM

# local_settings will be ignored in .gitignore file, and configured locally at each environment

try:
    from .local_settings import *
except:
    pass
EOM

python manage.py migrate
echo -e "\nProject folder after first ${cyan}migration${clear}:\n\n"
tree -L $lvl --filelimit $file_limit "$proj_full_path"

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
echo -e "$cyan\n"
echo -e "$script" | python manage.py shell
echo -e "$clear\n"

cat >> ~/.bashrc <<- EOM

# User Added
proj1=$proj_full_path
cd $proj1
venv1="$venv_full_path"/bin/activate

echo -e "Use 'source \$venv1' to activate your virtual env first"
echo -e "Remember to always go to your project folder: \$proj1"

export HBASE_HOME=~/hbase-2.5.2
export PATH=\$PATH:\$HBASE_HOME/bin
echo -e "HBASE_HOME set and added to PATH: $HBASE_HOME"
EOM

echo -e "\n⚠️ ⚠️ ⚠️ \n${bold_red}4${clear} more steps to go!\n"
echo -e "⚠️  ${magenta}1${clear}. ALWAYS ACTIVATE PYTHON VIRTUAL ENV BY RUNNING: '${green}source${clear} ${cyan}$venv_full_path/bin/activate${clear}' before you do anything, MAKE A NOTE!!!"
echo -e "⚠️  ${magenta}1.1${clear}. Always go to your project folder: '${green}cd${clear} ${cyan}$proj_full_path${clear}' first on ubuntu before you do anything, MAKE A NOTE!!!"
echo -e "\n⚠️  ${magenta}2${clear}. ${green}twitter/settings.py${clear} was modified to use local_settings.py, which have ${yellow}mysql${clear} configs as below:"
echo -e "\nWhats changed in ${green}$settings_file${clear} to use the correct IP and local_settings:\n"
diff $settings_file.bkup $settings_file
echo -e "\nMYSQL Config in ${green}twitter/local_settings.py${clear}\n${yellow}"
cat twitter/local_settings.py
echo -e "${clear}"
echo -e "⚠️  ${magenta}3${clear}. At terminal run '${cyan}python manage.py runserver 0.0.0.0:8000${clear}' to start your web app!\n"
echo -e "⚠️  ${magenta}4${clear}. Go to your Browser, enter '${magenta}${ipv4}${clear}:${cyan}8000$clear' to view your web app!\n"

echo -e "\n${green}END!!!${clear}🏅️🏅️🏅\n\n"
