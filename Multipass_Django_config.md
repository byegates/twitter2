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
## 3. run script1.sh
### mac
make it executable first
```shell
sudo chmod 777 script1.sh
```
run it
```shell
./script1.sh
```
script1会给你ssh 进入虚拟机的完整命令并带有虚拟机的ip地址，存下来，会经常需要用

## 4. 用ssh加密协议登陆你的ubuntu虚拟机
前面存下来的命令(如下), 把'192.168.64.4'换成你的lts2204虚拟机对应的ip地址⚠️⚠️⚠️否则ip不对，命令会卡住，timeout
```shell
ssh ubuntu@192.168.64.4 -i ~/.ssh/multipass-ssh-key -o StrictHostKeyChecking=no
```

## 5. 关于mount
mount 作用时把你的Mac的home folder映射到虚拟机里面, 这样虚拟机里面和外面就可以操作相同的文件了，比较方便

script1.sh 应该已经成功完成这件事情了
### 检查mount成功了没有, 在ssh进入虚拟机之后的terminal:
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
回到前面的第4步, ssh 到你的虚拟机，以后都这么进去
### 
### mount not enabled
windows上可能碰到mount not enabled问题，执行下面的命令然后重复上面的mount
```shell
multipass set local.privileged-mounts=Yes # for windows only
```

## 6. 执行script2.sh
安装必要的软件包，更新，初始化你的项目
<pre>
!script2.sh 要在虚拟机里面执行! 放到一个虚拟机可以访问到的文件夹，进入那个文件夹
默认项目会被创建在 ~/Desktop/twitter 文件夹
</pre>
不要忘记先设置可执行权限
```shell
sudo chmod 777 script1.sh
```
然后执行
```shell
./script2.sh
```
## 7. script2会告诉你还有四步
按照说明走完那四步
### 7.1 激活python 虚拟环境
```shell
source ~/.virtualenvs/twitter2/bin/activate
```
### 7.2 更改你项目文件下面的twitter文件夹里面的settings.py文件
#### 7.2a 添加 ALLOWED_HOSTS
把你的虚拟机ip地址(⚠️⚠️⚠️是你的地址不要抄下面的), 加入到更改你项目文件下面的twitter文件夹里面的settings.py的allowed hosts里面
⚠️⚠️⚠️its a string, quote it
```shell
ALLOWED_HOSTS = ['192.168.64.1']
```
#### 7.2b 把settings.py里面的 DATABASES 部分替换成下面的内容
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
```shell
# ⚠️⚠️⚠️in ubuntu terminal⚠️⚠️⚠️, enter below.
python manage.py runserver 0.0.0.0:8000&
```
### 7.4 访问你刚运行起来的网站
去浏览器输入, 端口都是8000, 但是ip地址again, 是你自己的虚拟机地址❕⚠️⚠️
```shell
192.168.64.1:8000
```