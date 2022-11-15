#!/usr/bin/env bash

# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'

# Project Folder name
PROJECT_FOLDER=test
# PROJECT_FOLDER=twitter



echo ''
echo "START!!!"
echo ''


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
 echo "pip3 已安装"
fi


# for convenience
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 2
# create virtual env
python -m venv ~/.virtualenvs/twitter2
source ~/.virtualenvs/twitter2/bin/activate

# 安装pip etc. 最新版
pip install -U pip # setuptools wrapt
pip install django==4.1.3
pip install mysqlclient==2.1.1
# check python executable path
# import sys, os
# os.path.dirname(sys.executable)




# init twitter project
cd ~/Home/Desktop
mkdir -p $PROJECT_FOLDER
cd $PROJECT_FOLDER
django-admin startproject twitter .


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
python manage.py migrate

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
printf "$script" | python manage.py shell


# 2nd round
python manage.py migrate

echo ''
echo '⚠️ ⚠️ ⚠️ '
echo ''
echo '4 more steps to go!'
echo ''
echo "⚠️  1. Run below command:"
echo "    'source ~/.virtualenvs/twitter2/bin/activate'"
echo "    To activate your virtual environment"
echo ''
echo "⚠️  2. modify twitter/settings.py file at two places:"
echo "    2.1 Add your virtual machine ip to ALLOWED_HOSTS like: ALLOWED_HOSTS = ['192.168.64.6']"
echo "    2.2 Replace DATABASES in the file as below:"
echo ''
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
echo ''
echo "⚠️  3. Try 'python manage.py runserver 0.0.0.0:8000' to start your web app!"
echo ''
echo "⚠️  4. Go to your Browser, use your virtual machine ip with port 8000(e.g.: '192.168.64.2:8000') to view your web app!"
echo ''
echo '⚠️ ⚠️ ⚠️ '
echo ''

echo ''
echo "END!!!🏅️🏅️🏅"
echo ''
