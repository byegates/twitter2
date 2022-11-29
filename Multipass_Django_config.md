# Setup Django App with multipass 

## STEP0, $$$ BUY a MAC if you dont have one
## Note for windows users
Before you start,download a good terminal that runs shell like [cmder full version](https://github.com/cmderdev/cmder/releases/download/v1.3.20/cmder.zip), for detail, check their [website](https://cmder.app/).

## STEP000, setup your mac with iterm, brew etc. for a steady start
1. Check video [How To Make Your Boring Mac Terminal So Much Better](https://www.youtube.com/watch?v=CF1tMjvHDRA) for step by step instructions.
2. [Blog version of above](https://www.josean.com/posts/terminal-setup)
## 1. install multipass
Windows/linux users go to 1.2 directly
### 1.1b install multipass with brew
```shell
brew install --cask multipass
```
### 1.2 Windows/Linux
reter to their [website](https://multipass.run/install)

## 1.3. Verify you installed multipass successfully
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
## 2. run first script
```shell
# curl -L -o script1.sh 'https://raw.githubusercontent.com/byegates/twitter2/main/script1.sh'
cd ~
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/byegates/twitter2/main/script1.sh)" | tee script1.txt
```
⚠️⚠️⚠️script1会给你ssh 进入虚拟机的完整命令并带有虚拟机的ip地址，存下来，会经常需要用⚠️⚠️⚠️
## 3. 用ssh加密协议登陆你的ubuntu虚拟机
script1 output y有这些信息(example如下), 把'**192.168.64.1**'⚠️**换成你的虚拟机(lts2204)对应的ip地址**⚠️否则ip不对，命令会卡住，timeout
```shell
ssh ubuntu@192.168.64.1 -i ~/.ssh/multipass-ssh-key -o StrictHostKeyChecking=no
```
## 4. 关于Mount
mount 作用时把你的Mac的home folder映射到虚拟机里面, 这样虚拟机里面和外面就可以操作相同的文件了，比较方便
### 检查mount成功了没有, 在ssh进入虚拟机之后的terminal:
```shell
# 在ubuntu 虚拟机的命令行
ls ~/Home
```
output应该是你整个home 文件夹
### ⚠️⚠️⚠️Mount 有bug 经常出问题，然后你在Home文件夹下面就看不到东西了⚠️⚠️⚠️
怎么办？重新mount一次，在你host (Mac/Windows) terminal 输入下面的命令
```shell
multipass set local.privileged-mounts=Yes
multipass unmount lts2204:Home
multipass mount $HOME lts2204:Home
```
然后回到上一步在ubuntu里面 ls ~/Home, 你就应该能看到很多文件夹(你的Mac/Windows的home文件夹), 里面有个叫做github的再里面的twitter就是你的项目root folder了

### ⚠️⚠️⚠️如果Home下面还看不到东西，求助，先解决再继续⚠️⚠️⚠️
## 6. 执行script2.sh
安装必要的软件包，更新，初始化你的项目

⚠️⚠️⚠️script1 output也会告诉你怎么run第二个script, just follow the instruction⚠️⚠️⚠️
Basically, it looks like this:
```shell
cd ~
bash script2.sh
```
如果找不到script2.sh 这个文件, run 下面的命令(先下载，再执行)
```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/byegates/twitter2/main/script2.sh)" | tee script2.txt
```
⚠️⚠️⚠️仔细看script2.sh的output, 有任何error要处理，warning可以忽略，最后的要你做四步，跟着做，把4步骤重的1，3，4都拿小本本记一下⚠️⚠️⚠️
## 小本本记一下: 跑完script2之后, 每次打开ubuntu, 跑下面的命令进入你的项目home folder, 每次!
```shell
cd ~/Home/github/twitter
```
如果进去不了或者看不到东西，回到第五步，fix mount bug
## 7. script2会告诉你还有四步
按照说明走完那四步
### 7.1 激活python 虚拟环境
这个每次登录ubuntu都要run一次，小本本记一下
```shell
source ~/.virtualenvs/twitter2/bin/activate
```
### 7.2 更改你项目文件下面的twitter文件夹里面的settings.py文件
把settings.py里面的 DATABASES 部分替换成下面的内容
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
### 7.3 可以尝试性的跑一下了!
# ⚠️⚠️⚠️in ubuntu terminal⚠️⚠️⚠️, enter below.
```shell
python manage.py runserver 0.0.0.0:8000&
```
### 7.4 访问你刚运行起来的网站
去浏览器输入, 端口都是8000, 但是ip地址again, 是你自己的虚拟机地址❕⚠️⚠️
```shell
192.168.64.1:8000
```