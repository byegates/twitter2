# Steps
## install multipass
### Mac
```shell
brew install --cask multipass
```
If you don't have brew or don't know what brew is, go to their [website](https://multipass.run/install).

homebrew?

### Windows/Linux
reter to their [website](https://multipass.run/install)

## 2. check multipass (use multipass find)
输入命令
```shell
multipass find
```
output should be similar to below
```shell
Image                       Aliases           Version          Description
18.04                       bionic            20221014         Ubuntu 18.04 LTS
20.04                       focal             20221018         Ubuntu 20.04 LTS
22.04                       jammy,lts         20221101.1       Ubuntu 22.04 LTS
anbox-cloud-appliance                         latest           Anbox Cloud Appliance
charm-dev                                     latest           A development and testing environment for charmers
docker                                        latest           A Docker environment with Portainer and related tools
jellyfin                                      latest           Jellyfin is a Free Software Media System that puts you in control of managing and streaming your media.
minikube                                      latest           minikube is local Kubernetes
```
## 3. generate your ssh key
### mac
```shell
ssh-keygen -C ubuntu -f ~/.ssh/multipass-ssh-key
```
### windows
```shell
cd %HOMEPATH%
mkdir .ssh # 如果已经有这个文件夹了不要管他
cd .ssh
ssh-keygen
# for passphrase hit enter
Notepad %HOMEPATH%/.ssh/multipass-ssh-key.pub
```

## 4. copy result from line 6 and put it in note pad, paste to line 18 add "- "
### mac
```shell
cat ~/.ssh/multipass-ssh-key.pub
```

## #5. create cloud-init.yaml config file at below path
### mac
```shell
touch ~/.ssh/cloud-init.yaml
```

### windows
```shell
%HOMEPATH%/.ssh/cloud-init.yaml
```

## 6. 
```shell
vi ~/.ssh/cloud-init.yaml
```


## 7. 把下面的内容放到新建的~/.ssh/cloud-init.yaml 文件里面, 把最后一行从ssh-rsa 到 ubuntu整个string换成前面第四部保存的你的public key
users:
  - default
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
    - ssh-rsa XXXXB3NzaC1yc2EDDDDDAQABEEEBgQDAWGOpqPsQn4Kmus3QStWnI5OF3X4fkJYB3tTBi93WSuzCjVFEDlrSE2CRGQq38cc9hmLFFuVgj+Xpl3POkaavHyunxTcN7Ytza6ZD/hTP7IgDuo0RqySd3EjHy1e9IUdaDddYTtPR+7d2E51r9rjUq8toEUikNXgEprp45sjH6s3ZDgoRdjs8QU590fchvzDgVgCnPd9JVq4ai3XbkM1s8cTd5fsx75iKZwkv6QjzCG1/U5PKles+AVBE4WdZ5GoEPtV4YKvxWd9lUNgO9bYI3vrX9lBHXyVy2kVWLiynBstkAQcMpgKp8hj6H6VrBFkjRA4CrmrEvFijki+iNSf37NWXRawOPNh00x/lsdmjat8AkCCgEdWwZptTTOZ1PVbpHFfL3h7hk9noXtwNJtGbDpUGtQ2iSg1F27NzwZzeehTBKCrxApcKRUkDIz2eW8KV90Q0Twzi37rZsIxoQpfX7+Q8mri5kvh9PRCGy3neG8wR3OQzyhNUgTjDsbC5YOc= ubuntu

## 8. 让multipass 新建一个叫lts2204的虚拟机, 操作系统版本是22.04(ubuntu), 使用你刚才创建的~/.ssh/cloud-init.yaml文件来配置(之后有用!)
```shell
multipass launch 22.04 --name lts2204 --cloud-init ~/.ssh/cloud-init.yaml
```

## 9. 用multipass看一下你刚才创建成功的虚拟机, 把ip地址记下来(每个人可能不一样)
```shell
multipass list
```
### output (每个人不完全一样)
```shell
Name                    State             IPv4             Image
lts2204                 Running           192.168.64.4     Ubuntu 22.04 LTS
```
### 10. ssh 进入你的虚拟机
用ssh加密协议登陆你的ubuntu虚拟机, 把'192.168.64.4'换成你的lts2204虚拟机对应的ip地址⚠️⚠️⚠️否则ip不对，命令会卡住，timeout
```shell
ssh ubuntu@192.168.64.4 -i ~/.ssh/multipass-ssh-key -o StrictHostKeyChecking=no
```

## 11 用vim修复一个bug
编辑下面这个文件
```shell
sudo vi  /lib/systemd/system/snapd.service
```
找到下面这一行
```shell
EnvironmentFile=-/etc/environemnt
```
改成
```shell
EnvironmentFile=/etc/environemnt
```
vim的保存并退出
```shell
:wq
```
vim 不保存就退出
```shell
:q!
```
## 12. 更新系统+软件安装包
```shell
# 如果看到粉色的屏幕让你选东西 按 tab, 然后 enter
sudo apt update
sudo apt upgrade
sudo apt install snapd
sudo snap install bare
sudo snap install multipass-sshfs
sudo apt install python3.10-venv
sudo apt-get install tree
sudo apt install mysql-server
sudo apt-get install -y libmysqlclient-dev
```

## 13. 换一个terminal (host 系统, 不是虚拟机里面)
mount 你自己电脑的home folder到虚拟机里面, 这样虚拟机里面和外面就可以操作相同的文件了，比较方便
### mac
```shell
multipass mount $HOME lts2204:Home
```
if you are using windows, please use powershell for above
### mount not enabled
windows上可能碰到mount not enabled问题，执行下面的命令然后重复上面的mount
```shell
multipass set local.privileged-mounts=Yes
```
### 检查mount成功了没有
```shell
# 在ubuntu 虚拟机的命令行
ls Home
ls Home/Desktop
```
第一个output应该是你整个home 文件夹，第二个显示你的Desktop
### Mac 权限问题
Mac上可能会碰到没有权限的问题, 如果上面命令显示permission denied就说明有权限问题。
去system preference 里面的 security & privacy 里面的 full disk access 给multipassd和terminal 勾选☑️上，会要求你重启terminal，就重启一下。
### 重启完了terminal 怎么进入刚才的虚拟机?
回到前面的第10步, ssh 到你的虚拟机，以后都这么进去
### 
## 14. 创建项目文件夹
在你喜欢的地方新建一个folder作为项目的文件夹，然后在ubuntu的command line进入到这个文件夹, 比如
```shell
cd ~/Desktop
mkdir twitter
cd twitter
```
⚠️⚠️⚠️一定是在ubuntu的command line里面进入这个folder, 后面的命令都是在ubuntu的command line, 这个文件夹里面执行!
## 15. 执行下面的命令
change python to python3, create twitter2 as virtual
```shell
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 2
python -m venv ~/.virtualenvs/twitter2
source ~/.virtualenvs/twitter2/bin/activate
```
### 15.1 ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
如果重新打开虚拟机需要跑你的项目的话，要用下面的命令先激活你的虚拟环境，不然找不到你已经安装的python lib
```shell
source ~/.virtualenvs/twitter2/bin/activate
```
## 16. 执行下面的命令
这一步目前是需要的不能跳过，最后一步可能说link不成功, 已经存在，那就忽略
```shell
if [ ! -f "/usr/bin/pip" ]; then
 sudo apt-get install -y python3-pip
 sudo apt-get install -y python-setuptools
 sudo ln -s /usr/bin/pip3 /usr/bin/pip
else
 echo "pip3 已安装"
fi
```
## 17. 继续安装一些libs
准备工作
```shell
pip install --upgrade setuptools
pip install --ignore-installed wrapt
# 安装pip最新版
pip install -U pip
```

## 18. 安装django和mysqlclient
```shell
pip install django
pip install mysqlclient
```

## 19. 初始化twitter project
```shell
# . 也照着打，不要管细节先
django-admin startproject twitter .
```
## 20. mysql 设置
⚠️⚠️⚠️ 密码统一成'yourpassword', 后面要一致
```shell
# 设置mysql的root账户的密码为yourpassword
# 创建名为twitter的数据库
sudo mysql -u root << EOF
  ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'yourpassword';
  flush privileges;
  show databases;
  CREATE DATABASE IF NOT EXISTS twitter;
EOF
# fi

```
## 21. django 对数据模型初始化
```shell
#create basic tables, match ORM and tables
python manage.py migrate
```
## 22. 设置 django初始管理员账户和密码
admin, admin 😂😂😂

下面可以一起复制一起粘贴一次run
```shell
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

```

## 23. 更改你项目文件下面的twitter文件夹里面的settings.py文件
把你的虚拟机ip地址⚠️⚠️⚠️是你的地址不要抄下面的, 加入到下面的allowed hosts里面
```shell
ALLOWED_HOSTS = ['192.168.64.1']
```
### 把settings.py里面的 DATABASES 部分替换成下面的内容
```shell
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
```
## 24. 可以尝试性的跑一下了!
```shell
# ⚠️⚠️⚠️in ubuntu terminal⚠️⚠️⚠️, enter below.
python manage.py runserver 0.0.0.0:8000&
```
### 24.1 访问你刚运行起来的网站
去浏览器输入, 端口都是8000, 但是ip地址again, 是你自己的虚拟机地址❕⚠️⚠️
```shell
192.168.64.1:8000
```