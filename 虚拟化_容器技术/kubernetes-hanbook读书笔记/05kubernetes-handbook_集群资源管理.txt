5. 集群资源管理
5.1 node
node是集群工作节点,物理机或虚拟机

- node的状态
Address:
	Hostname、ExternalIP、InternalIP
Condition:
	OutOfDisk、Ready、MemoryPressure、DiskPressure
Capacity:
	CPU、内存、可运行最大的Pod数量
Info：
	节点版本信息
	
- node管理：
kubectl cordon <node>  #禁止pod调度到该节点
kubectl drain <node>   #驱逐该节点上所有的pod,通常该节点需要维护时使用该命令
kubectl uncordon <node>  #即可将该节点添加到kubernetes集群中

5.2 namespace:
集群使用namespace创建多个"虚拟集群",这些namespace可以完全隔离

例如生产、测试、开发划分不同的namespace

- namespace的使用：
kubectl get ns

5.3 Label
label是附着到object上的键值对,可以创建object时指定
label能够将组织架构映射到系统架构上(康威定律),
常用的标签:
    "release" : "stable", "release" : "canary"
    "environment" : "dev", "environment" : "qa", "environment" : "production"
    "tier" : "frontend", "tier" : "backend", "tier" : "cache"
    "partition" : "customerA", "partition" : "customerB"
    "track" : "daily", "track" : "weekly"
    "team" : "teamA","team:" : "teamB"

- Label selector
Label不是唯一的,通过label selector,客户端/用户可以指定一个object集合
通过label selector对object的集合进行操作
示例:
kubectl get pods -l environment=production,tier=frontend
kubectl get pods -l 'environment in (production),tier in (frontend)'
kubectl get pods -l 'environment in (production, qa)'
kubectl get pods -l 'environment,environment notin (frontend)'

- API object中设置label selector
在service、replicationcontroller等object中有对pod的label selector，使用方法只能使用等于操作，例如：
selector:
    component: redis

在Job、Deployment、ReplicaSet和DaemonSet这些object中，支持set-based的过滤，例如：
selector:
  matchLabels:
    component: redis
  matchExpressions:
    - {key: tier, operator: In, values: [cache]}
    - {key: environment, operator: NotIn, values: [dev]}

5.4 annnotation注解

- 关联元数据到对象
Label和Annotation都可以将元数据关联到Kubernetes资源对象。
Label主要用于选择对象，可以挑选出满足特定条件的对象。相比之下，annotation 不能用于标识及选择对象

annotation和label一样都是key/value键值对映射结构：
"annotations": {
  "key1" : "value1",
  "key2" : "value2"
}

5.5 Taint和Toleration(污点和容忍)
Taint 和 toleration 相互配合，可以用来避免 pod 被分配到不合适的节点上。
每个节点上都可以应用一个或多个 taint ，这表示对于那些不能容忍这些 taint 的 pod，是不会被该节点接受的
toleration 应用于 pod 上，则表示这些 pod 可以（但不要求）被调度到具有相应 taint 的节点上

- 为node设置taint
kubectl taint nodes node1 key1=value1:NoSchedule
kubectl taint nodes node1 key1=value1:NoExecute
kubectl taint nodes node1 key2=value2:NoSchedule

#删除taint
kubectl taint nodes node1 key1:NoSchedule-
kubectl taint nodes node1 key1:NoExecute-
kubectl taint nodes node1 key2:NoSchedule-

#查看taint
kubectl describe nodes node1

- 为pod设置toleration
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoExecute"
- key: "node.alpha.kubernetes.io/unreachable"
  operator: "Exists"
  effect: "NoExecute"
  tolerationSeconds: 6000
  
5.6 垃圾回收
垃圾收集器负责删除指定对象  
  
kubectl delete replicaset my-repset --cascade=false