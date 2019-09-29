4. Pod状态和生命周期管理
Kubernetes中的基本组件kube-controller-manager就是用来控制Pod的状态和生命周期的

4.1 pod概述
pod代表集群中的进程
pod中封装着部署应用容器,存储、网络等

一个pod中可以封装多个紧密耦合相互协作的容器,他们共享资源

- 如何管理多个容器:
k8s使用controller来管理pod实例
controller可以创建和管理多个pod,提供副本管理、滚动升级和集群级别的自愈能力

- 常见的controller有:
Deployment
StatefulSet
DaemonSet

pod模板包含了pod的定义

- 什么是Pod
pod像豌豆荚,由一个或者多个容器组成（例如Docker容器），它们共享容器存储、网络和容器运行配置项
Pod中的容器总是被同时调度，有共同的运行环境

- Pod中共享的环境包括Linux的namespace、cgroup和其他可能的隔绝环境
Pod中的容器共享IP地址和端口号，它们之间可以通过localhost互相发现。它们之间可以通过进程间通信，例如SystemV信号或者POSIX共享内存

Pod中的容器也有访问共享volume的权限，这些volume会被定义成pod的一部分并挂载到应用容器的文件系统中

通常，用户不需要手动直接创建Pod，而是应该使用controller（例如Deployments），即使是在创建单个Pod的情况下。
Controller可以提供集群级别的自愈功能、复制和升级管理。

4.2 init容器
4.3 pause容器
pause容器主要:
在pod中担任Linux命名空间共享的基础
启用pid命名空间,开启init进程

4.4 pod的安全策略
PodSecurityPolicy
创建 Pod 安全策略 psp.yaml  
  
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: permissive
spec:
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  hostPorts:
  - min: 8000
    max: 8080
  volumes:
  - '*'
  
kubectl create -f ./psp.yaml  
  
kubectl get psp #获取podsercuritypolicy
kubectl edit psp permissive
kubectl delete psp permissive

使用RBAC
当 Pod 基于 Deployment、ReplicaSet 创建时，它是创建 Pod 的 Controller Manager

4.5 pod的生命周期
pod的phase是pod在其生命周期中的简单宏观概述
Pending,等待容器创建
Running, pod已绑定到一个节点上,
Successed, pod中的容器都成功终止
Failed, 至少一个容器因失败终止
Unknown, 无法获取pod状态

Pod状态:
PodStatus对象

容器探针是kubelet对容器执行定期诊断:
1.ExecAction,容器内部执行指定的命令
2.TCPSocketAction, 指定端口上的容器IP地址进行TCP检查
3.HTTPGetAction, GTTP Get请求状态码200-400则成功

重启策略:
PodSpec中有一个restartPolicy字段,可能值有Always、OnFailure、Never
restartPolicy 仅指通过同一节点上的 kubelet 重新启动容器

4.6 Pod Preset：
Preset 就是预设，有时候想要让一批容器在启动的时候就注入一些信息，比如 secret、volume、volume mount 和环境变量

4.7 Pod中断和PDB(Pod中断预算)
自愿中断:

程序所有者操作包括：
    删除管理该 pod 的 Deployment 或其他控制器
    更新了 Deployment 的 pod 模板导致 pod 重启
    直接删除 pod（意外删除）

集群管理员操作包括：
    排空（drain）节点进行修复或升级。
    从集群中排空节点以缩小集群（了解集群自动调节）。
    从节点中移除一个 pod，以允许其他 pod 使用该节点。

处理中断:
应用程序所有者可以为每个应用程序创建一个 PodDisruptionBudget 对象（PDB）
PDB 将限制在同一时间自愿中断的复制应用程序中宕机的 Pod 的数量

