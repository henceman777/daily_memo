2. kubernetes的网络
kubernetes本身不提供网络功能,只是将网络接口开发出来,通过插件的形式实现

2.1 kubernetes中的网络解析 - flannel
https://jimmysong.io/kubernetes-handbook/concepts/flannel.html

kubectl get nodes -o wide
kubectl get pods --all-namespaces -o wide

etcdctl ls /kube-centos/network/subnets  #etcd中注册的宿主机pod网络信息
etcdctl get /kube-centos/network/config  #查看子网配置

- kubernetes集群内部的三中哦你IP:
Node IP: 宿主机Node的IP
Pod IP：网络插件创建的IP,使得主机的pod可以互通
CLuster IP：虚拟IP,通过iptables规则访问服务

节点上的进程是按照flannel -> docker -> kubelet -> kube-proxy的顺序启动的 

- Flannel
主要实现的两个功能:
为node分配subnet,容器将自动从该子网获取IP
有新node加入网络中,为每个node增加路由配置

- 以host-gw为backend的flannel网络

2.2 kubernetes中的网络解析 - calico
https://jimmysong.io/kubernetes-handbook/concepts/calico.html
- 概念
Calico创建和管理一个扁平的三层网络（不需要overlay），每个容器会分配一个可路由的IP。
由于通信时不需要解包和封包，网络性能损耗小，易于排查，且易于水平扩展。

Calico基于iptables还提供了丰富而灵活的网络Policy，保证通过各个节点上的ACL来提供Workload的多租户隔离、安全组以及其他可达性限制等功能

Calico主要由Felix、etcd、BGP client、BGP Route Reflector组成。

- 组件：
Etcd：负责存储网络信息
BGP client：负责将Felix配置的路由信息分发到其他节点
Felix：Calico Agent，每个节点都需要运行，主要负责配置路由、配置ACLs、报告状态
BGP Route Reflector：大规模部署时需要用到，作为BGP client的中心连接点，可以避免每个节点互联

- 部署：
运行下面的命令可以部署 calico 网络
mkdir /etc/cni/net.d/
kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/rbac.yaml
wget https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/calico.yaml

# 修改etcd_endpoints的值和默认的192.168.0.0/16(不能和已有网段冲突)
kubectl apply -f calico.yaml
wget  https://github.com/projectcalico/calicoctl/releases/download/v2.0.0/calicoctl
mv calicoctl /usr/loca/bin && chmod +x /usr/local/bin/calicoctl
calicoctl get ippool
calicoctl get node

如果安装时启用应用层策略的话还需要安装 istio
https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/app-layer-policy#about-enabling-application-layer-policy

2.3 具备API感知的网络和安全性管理开源软件Cilium
Cilium是一个纯开源软件，没有哪家公司提供商业化支持，也不是由某一公司开源，
该软件用于透明地保护使用Linux容器管理平台（如Docker和Kubernetes）部署的应用程序服务之间的网络连接。

Cilium的基础是一种名为BPF的新Linux内核技术，它可以在Linux本身动态插入强大的安全可见性和控制逻辑。
由于BPF在Linux内核中运行，因此可以应用和更新Cilium安全策略，而无需对应用程序代码或容器配置进行任何更改

基于微服务的应用程序分为小型独立服务，这些服务使用HTTP、gRPC、Kafka等轻量级协议通过API相互通信
但是，现有的Linux网络安全机制（例如iptables）仅在网络和传输层（即IP地址和端口）上运行，并且缺乏对微服务层的可见性。

Cilium为Linux容器框架（如Docker和Kubernetes）带来了API感知网络安全过滤。
使用名为BPF的新Linux内核技术，Cilium提供了一种基于容器/容器标识定义和实施网络层和应用层安全策略的简单而有效的方法

现代数据中心应用程序的开发已经转向面向服务的体系结构（SOA），通常称为微服务，其中大型应用程序被分成小型独立服务，这些服务使用HTTP等轻量级协议通过API相互通信

。。。。
