https://jimmysong.io/kubernetes-handbook/concepts/

### kubernetes-handbook读书笔记

1. kunernetes架构
kubernetes最初源于google内部的Borg, Kubernetes 具备完善的集群管理能力，包括多层次的安全防护和准入机制、
多租户应用支撑能力、透明的服务注册和服务发现机制、内建负载均衡器、故障发现和自我修复能力、服务滚动升级和在线扩容、
可扩展的资源自动调度机制、多粒度的资源配额管理能力。 
Kubernetes 还提供完善的管理工具，涵盖开发、部署测试、运维监控等各个环节。

kubernetes主要由以下核心组件组成:
- etcd保存整个集群状态
- apiserver提供集群资源操作的唯一入口,提供认证、授权、访问控制、API注册和发现等机制
- controller manager负责资源的调度,按照预定的调度策略将Pod调度到相应的机器上
- kubelet负责维护容器的生命周期,也负责volume(CSI)和网络(CNI)的管理
- container runtime负责镜像管理以及Pod的容器运行(CRI)
- kube-proxy负责为service提供cluster内部的服务发现和负载均衡

除了核心组件还有CNCF推荐的插件add-on:
- CoreDNS负责为集群提供DNS服务
- Ingress Controller为服务提供外网入口
- Prometheus提供资源监控
- Dashboard提供GUI
- Federation提供跨可用区的集群


1.1 kubernetes设计理念
分层架构
高内聚、松耦合

1.1.1 kubernetes的核心技术概念和API对象
每个API对象都有3个类属性:
- 元数据metadata、用来标记API对象: namespace+name+uid+label等
- 规范spec、描述了用户期望集群中分布式系统的理想状态desired state
- 状态status,描述了系统实际达到的状态

声明式declarative操作比命令式imperative更稳定、不怕丢操作或运行多次

- Pod：
是k8s集群中运行部署应用或服务的最小单位,可以支持多容器,pod内的容器共享网络地址和文件系统

- Deployment: 
表示对集群的一次更新操作,部署是一个比RS应用模式更广的API对象，可以是创建一个新的服务，更新一个新的服务，
也可以是滚动升级一个服务。滚动升级一个服务，实际是创建一个新的RS，然后逐渐将新RS中副本数增加到理想状态，将旧RS中的副本数减小到0的复合操作long-running长期伺服型业务

- Replication controller(RC): 
保证pod高可用的对象,保持执行的副本数量 

- Replica Set(RS): 
是新一代的RC,同样提供高可用能力,支持更多的匹配模式

- 服务Service：
RC、RS、Deployment只是保证了支撑服务的微服务Pod数量,没有解决服务访问问题
服务发现就是针对客户端访问的服务,找到对象的后端服务实例
Service对应一个集群内部有效的虚拟IP,集群内部通个这个虚拟IP访问服务
Kube-proxy来实现服务的负载均衡,它是一个分布式代理服务器

- 任务Job：
是用来控制批处理型任务的API对象

- 后台支持服务集DaemonSet:
保证每个节点都有此类Pod运行,节点可能是通过nodeSelector选定的一些特定节点
典型的DaemonSet有:存储、日志和监控等服务

- 有状态的服务集StatefulSet：
用来控制有状态的服务,每个pod名字都是事先确定的,不能更改
适合statefulSet的业务包括: MySQL和PostgreSQL,集群化管理服务Zookeeper、etcd等
StatefulSet的另一种典型应用场景是作为一种比普通容器更稳定可靠的模拟虚拟机的机制
StatefulSet保证确定的Pod和确定的存储关联起来保证状态的连续性

- 集群联邦Federation：
提供跨Region跨服务商的集群服务
cluster的负载均衡通过域名服务的负载均衡来实现

- 存储卷Volume：
类似Docker的存储卷,只是kubernetes的存储卷生命周期和作用范围是一个Pod
支持多种公有云平台存储
支持多种分布式存储包括GlusterFS和Ceph
支持较容易使用的主机目录emptyDir,hostPath和NFS
还支持Persistent Volume Claim即PVC这种逻辑存储,

- 持久存储卷PV和持久存储卷声明PVC:
PV和PVC使得kubernetes集群具备了存储的逻辑抽象能力,使得配置Pod的逻辑里可以忽略对实际后台
存储技术的配置,而将配置工作交给PV的配置者,
PV是资源提供者,PVC是资源使用者

- 节点Node：
最初成为Minion
Node相当于Mesos的Slave节点,是Pod运行所在的工作主机,可以是物理机也可以是虚拟机

- 密钥Secret：
用来保存和传递密码、密钥、认证凭证这些敏感信息的对象
避免将明文写在配置文件中,可以将这些信息存入一个Secret对象,

- 用户帐户User Account和服务帐户Service Account:
用户帐户为人提供账户标识,而服务帐户为计算机进程和pid提供账户标识
用户帐户对应的是人的身份,人的身份和服务的namesapce无关
服务帐户对应的是一个运行中程序的身份,与特定namespace相关的

- 命名空间namespace:
命名空间为集群提供虚拟的隔离作用,kubernetes初始有两个命名空间,分别是默认的命令空间default
和系统命令空间kube-system,管理员可以创建新的命名空间满足需要

- RBAC访问授权:
Role-based Access Contorl的授权模式,相对于基于属性的访问控制ABAC
RBAC引入了角色Role和角色绑定RoleBinding的抽象概念
ABAC的访问策略只能和用户直接关联,RBAC这一新的概念抽象使的集群服务管理
和使用更容器扩展和重用


- 总结：
Kubernetes系统最核心的两个设计理念：一个是容错性，一个是易扩展性
按照分布式系统一致性算法Paxos发明人计算机科学家Leslie Lamport的理念，
一个分布式系统有两类特性：安全性Safety和活性Liveness


1.2 Etcd解析
etcd是kubernetes集群中一个十分重要的组件,用于保存集群所有网络配置和对象的状态信息
- 网络插件flannel、对于其他网络插件也需要用到etcd存储网络的信息
- kubernetes本身,包括各种对象的状态和元信息配置

- etcd的原理:
etcd使用raft一致性算法来实现的,是一款分布式的一致性KV存储,用于共享配置和服务发现

使用etcd存储flannel网络信息:
etcdctl --ca-file=/etc/kubernetes/ssl/ca.pem \  #查看etcd中存储的flannel网络信息
--cert-file=/etc/kubernetes/ssl/kubernetes.pem \
--key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
ls /kube-centos/network -r

etcdctl --ca-file=/etc/kubernetes/ssl/ca.pem \  #查看flannel的配置
--cert-file=/etc/kubernetes/ssl/kubernetes.pem \
--key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
get /kube-centos/network/config


使用etcd存储kubernetes对象信息:

- 查看集群所有Pod信息:
ETCDCTL_API=3 etcdctl get /registry/pods --prefix -w json|python -m json.tool

- Etcd V2与V3版本API的区别：
Etcd V2和V3之间的数据结构完全不同，互不兼容
这就造成我们访问etcd中保存的flannel的数据需要使用etcdctl的V2版本的客户端，而访问kubernetes的数据需要设置ETCDCTL_API=3环境变量来指定V3版本的API


- Etcd数据备份：
Etcd数据的存储路径是/var/lib/etcd，一定要对该目录做好备份

1.3 开放接口
Kubernetes作为云原生应用的基础调度平台,相当于云原生的操作系统,为了方便扩展
kubernetes开发了以下接口: 可以对接不同的后端来实现业务逻辑

- CRI: 容器运行时接口,提供计算资源
定义了容器和镜像的服务接口,容器运行时和镜像的生命周期是彼此隔离的
该接口使用protocol bufffer基于gRPC
CRI实现了CRI gRPC Server包括runtimeserver和imageservice,
gRPC server需要监听本地的Unix socket
kubelet则作为gRPC Client运行

》支持的CRI后端:
cri-o: 兼容OCI和CRI的容器运行时
cri-containerd: 基于containerd和kubernetes CRI实现
rkt：CoreOS主推的容器运行时
docker：还没有从kubelet中解耦等

- CNI: 容器网络接口,通过网络资源
是CNCF下的一个项目,由一组用于配置容器网络接口的规范和库组成
CNI插件负责将网络接口插入容器网络命名空间（例如，veth对的一端），并在主机上进行任何必要的改变（例如将veth的另一端连接到网桥）
然后将IP分配给接口，并通过调用适当的IPAM插件来设置与“IP地址管理”部分一致的路由

- CSI:容器存储接口,提供存储资源
代表容器存储接口,CSI试图建立一个行业标准接口的规范


































