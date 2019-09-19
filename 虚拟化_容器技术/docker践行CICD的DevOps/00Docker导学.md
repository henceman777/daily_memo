## Docker导学
### 1. Docker能做什么？
简化配置
代码流水线管理
提供开发效率
隔离应用
整合服务器
调试能力
多租户
快速部署

### 2. kubernetes
容器编排

### 3. DevOps=文化+过程+工具
信任和尊敬+敏捷的目标+开发的沟通

发布计划+持续集成/发布+持续测试/监控+持续改进

版本管理+自动化+部署+监控

## 第一章. 容器技术和Docker简介
### 1. 容器技术的历史
#### 1.1 传统物理机
部署慢\
成本高\
资源浪费\
难于迁移和扩展\
可能会硬件厂商限制

#### 1.2 虚拟化
物理机操作系统之上的Hypervisor管理VM虚拟机\
app可以独立运行在一个VM中

- 优点\
资源池，物理机的资源分配到不同的虚拟机中\
方便扩展\
方便云化

- 局限性\
每个虚拟机必须要有完整的操作系统

#### 1.3 容器
对软件和其依赖的便准化打包\
应用间的相互隔离\
共享宿主机OS的kernel\
可运行多种主流操作系统

- 容器和虚拟机的区别\
容器是应用层面的隔离\
虚拟机是物理资源层面的隔离

## 第二章. Docker环境的搭建
### 1. Docker的安装
#### Mac/Windows安装Docker
#### Vagrant安装VirtualBox  
- 安装VirtualBox
- 安装Vagrant, 重启windows
```
cmd
mkdir centos7
cd centos7
vagrant init centos/7
vagrant up
vagrant ssh  #登录
vagrant status
vagrant halt
vagrant destory

```
- [安装Docker-ce on CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)  
```
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce docker-ce-cli containerd.io
yum list docker-ce --showduplicates | sort -r
sudo systemctl start docker
sudo docker run hello-world
```

### 2. docker-machine搭建docker host
```
docker-machine create demo
docker-machine ls
docker-machine ssh demo
docker version
exit
docker-machine stop demo

docker-machine start demo
docker-machine env demo
eval $(docker-machine env demo)
```

### 3.docker-machine在阿里云上创建docker host
### 4.docker machine在亚马逊aws创建docker host

## 第三章. Docker基础-镜像和容器
### 1. docker架构和底层技术
#### 架构
- docker engine
- 后台进程dockerd
- REST API Server
- CLI接口docker

#### 底层技术：
- Namespaces： 隔离pid、net、ipc、mnt、uts
- Control groups： 资源控制
- Union file systems: 镜像和容器分层

### 2. Image镜像
- 文件和meta data的集合(rootfs)
- 分层的
- 不同的image可以共享相同的layer
- image本身是read-only的

### 3. container容器
- 通过image创建
- 在image layer之上建立一个container layer(rw)
- 类比面向对象：类和实例
- image负责app的存储和分发，container负责运行

### 4. 构建自己的镜像
#### Dockerfile
```
vim Dockerfile
FROM centos
RUN yum install -y vim

docker build -t jinmeng260/centos-vim .
```

#### Dockerfile语法和实践
```
FROM <base image>
LABEL mantainer='email' version='1.0'
RUN apt-get update && apt-get install -y vim \
  python-dev && rm -ef \
  /var/lib/apt/list/*
WORKDIR /test #会自动创建目录
ADD hello /   #添加文件

ENV MYSQL_VERSION 5.6

RUN命令写成一行
WORKDIR不使用RUN cd
目录尽量使用绝对目录
大部分情况下优先使用COPY
ADD相对COPY还有解压功能
ENV提高Dockerfile的可维护性

VOLUME
EXPOSE
CMD
ENTRYPOINT
```
#### RUN vs CMD vs ENTRYPOINT
```
- RUN: 
执行命令并创建新的Image Layer
- CMD：
设置容器启动后的默认执行命令和参数，docker run时指定其他命令CMD则会被忽略,多个CMD时只有最后一个会执行
- ENTRYPOINT：
设置容器启动时运行的命令，让容器以应用程序服务形式运行,不会被忽略,一定会执行
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoinit.sh"]
EXPOSE 27017
CMD ["mongod"]

#命令的shell格式和exec格式
ENRTYPOINT ["/bin/bash","-c","hello $name"]

```
### 5. 镜像的发布
```
docker loggin
docker push xiaopeng163/hello-world:latest

#docker hub上可以关联github，自动基于Dockerfile创建自动构建

#docker registry
```

### 6. Dockerfile实践
```
pip install flask

vi app.py
from flask import Flask
@app.route('/')
def hello():
  return "hello docker"
if __name__ == '__main__':
  app.run()

vi Dockerfile
FROM python:2.7
LABEL "maintainer=Max <max@max.com>"
RUN pip install flask
COPY app.py /app/
WORKDIR /app
EXPOSE 5000
CMD ["python","app.py"]

docker build -t jinmeng260/flask-hello-docker .

```
### 7. 容器的操作
```
docker exec -it container_id /bin/bash
docker logs
docker inspect
docker ps

```

## 第四章. Docker的网络
### 1. 单机网络
Bridge、Host、None

### 2. 多机网络
Overlay

### 3. 网络基础
#### 基于数据包通信
- 网络的分层：ISO的OSI 7层分层；TCP/IP

- IP地址和路由
- 公有和私有IP(A类10.0.0.0/8、B类172.16.0.0/12、C类192.168.0.0/16)、\
- 网络地址转换
- 网络工具：
  - Ping验证IP可达
  - telnet检查服务的可用性
  - wireshark

### 4. 网络名称空间
```
ip netns list  #查看网络名称空间
ip netns delete test1
ip netns add test1   #添加网络namespace test1
ip netns add test2

ip netns exec test1 ip a
ip netns exec test1 ip link set dev lo up  #test1的网络中启动lo

ip link add veth-test1 type veth peer veth-test2  #创建veth pair
ip link set veth-test1 netns test1  #加入test1网络namespace中
ip link set veth-test2 netns test2  #加入test2网络namespace中

ip netns exec test1 ip addr add 192.168.1.1/24 dev veth-test1  #配置IP
ip netns exec test2 ip addr add 192.168.1.2/24 dev veth-test2
ip netns exec test1 ip link set dev veth-test1 up  #启动
ip netns exec test2 ip link set dev veth-test2 up

ip netns exec test1 ip link  #查看
ip netns exec test2 ip link
ip netns exec test1 ping 192.168.1.2
ip netns exec test2 ping 192.168.1.1

```
### 5. bridge详解
```
docker network ls
yum install -y bridge-utils
brctl show
#不同的容器间通过docker0通信，veth pair网口连接docker0

```

### 6. 容器间的link


第五章. Docker的持久化存储和数据共享
第六章. Docker Compose多容器部署

第七章. 容器编排工具-Docker Swarm
第八章. Docker Cloud和Docker企业版
第九章. 容器编排工具-Kubernetes
第十章. 容器的运维和监控
第十一章. Docker的DevOps的实战-过程和工具
第十二章. 总结




