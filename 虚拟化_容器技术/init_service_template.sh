#!/bin/bash  

#指定在哪几个级别执行，0一般指关机，6指的是重启，其他为正常启动。80为启动的优先级，05为关闭的优先级别  
#chkconfig:2345 80 05 
#description:simple example service

RETVAL=0  

start(){   
echo  "simple example service is started..." 
}  
   
stop(){
echo  "simple example service is stoped..." 
}  
   
#使用case选择  
case $1 in 
start)  
start  
;;  
stop)  
stop  
;;  
*)  
echo "error choice ! please input start or stop"
;;  
esac  
exit $RETVAL



docker pull mirrorgooglecontainers/kube-apiserver:v1.13.0
docker pull mirrorgooglecontainers/kube-proxy:v1.13.0
docker pull mirrorgooglecontainers/kube-controller-manager:v1.13.0
docker pull mirrorgooglecontainers/kube-scheduler:v1.13.0
docker pull mirrorgooglecontainers/coredns:1.3.1
docker pull mirrorgooglecontainers/etcd:3.3.10
docker pull mirrorgooglecontainers/pause:3.1


pip install virtualenv
virtualenv ENV
source ENV/bin/activate
python -V
deactivate

pyenv install --list
cd
git clone https://github.com/yyuu/pyenv.git ~/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
exec $SHELL
pyenv install --list
pyenv install 3.5.0
python -V
pyenv global system
pyenv versions
pyenv global 3.5.0
pyenv versions

cd mylog/
tinker --setup
tinker --post 'Hello World!'
tinker --build

git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile
source ~/.bash_profile
pyenv virtualenv 3.5.1 env35
pyenv virtualenv 3.5.0 env35
pyenv activate env35
python -V
tinker --build
