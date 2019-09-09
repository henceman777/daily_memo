[toc]

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
信任和尊敬
敏捷的目标
开发的沟通

发布计划
持续集成/发布
持续测试/监控
持续改进

版本管理
自动化
部署
监控

## 第一章. 容器技术和Docker简介
### 1. 容器技术的历史
1.1 传统物理机
部署慢
成本高
资源浪费
难于迁移和扩展
可能会硬件厂商限制

1.2 虚拟化
物理机操作系统之上的Hypervisor管理VM虚拟机
app可以独立运行在一个VM中

- 优点
资源池，物理机的资源分配到不同的虚拟机中
方便扩展
方便云化

- 局限性
每个虚拟机必须要有完整的操作系统

1.3 容器
对软件和其依赖的便准化打包
应用间的相互隔离
共享宿主机OS的kernel
可运行多种主流操作系统

- 容器和虚拟机的区别
容器是应用层面的隔离
虚拟机是物理资源层面的隔离

## 第二章. Docker环境的搭建
### 1. Docker的安装
- Mac/Windows安装Docker
- Vagrant安装VirtualBox  
  - 安装VirtualBox
  - 安装Vagrant,重启windows
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
#### docker engine
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
- Dockerfile
```
vim Dockerfile
FROM centos
RUN yum install -y vim

docker build -t jinmeng260/centos-vim .
```

- Dockerfile语法和实践
```
FROM <base image>
LABEL mantainer='email' version='1.0'
RUN apt-get update && apt-get install -y vim \
  python-dev && rm -ef \
  /var/lib/apt/list/*
WORKDIR /test #会自动创建目录
ADD hello /   #添加文件

ENV MYSQL_VERSION 5.6

```

RUN命令写成一行
WORKDIR不使用RUN cd
目录尽量使用绝对目录
大部分情况下优先使用COPY
ADD相对COPY还有解压功能
ENV提高Dcokerfile的可维护性
VOLUME
EXPOSE
CMD
ENTRYPOINT



第四章. Docker的网络
第五章. Docker的持久化存储和数据共享
第六章. Docker Compose多容器部署

第七章. 容器编排工具-Docker Swarm
第八章. Docker Cloud和Docker企业版
第九章. 容器编排工具-Kubernetes
第十章. 容器的运维和监控
第十一章. Docker的DevOps的实战-过程和工具
第十二章. 总结




