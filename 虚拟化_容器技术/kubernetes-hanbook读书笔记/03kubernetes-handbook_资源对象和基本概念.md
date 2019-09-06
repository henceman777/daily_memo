3. 资源对象的概念
分类为以下几种资源对象：
- 资源对象 	Pod、ReplicaSet、ReplicationController、Deployment、StatefulSet、DaemonSet、Job、CronJob、HorizontalPodAutoscaling、
           Node、Namespace、Service、Ingress、Label、CustomResourceDefinition
- 存储对象 	Volume、PersistentVolume、Secret、ConfigMap
- 策略对象 	SecurityContext、ResourceQuota、LimitRange
- 身份对象 	ServiceAccount、Role、ClusterRole

3.1 对象的理解
这些对象是持久化的条目,k8s使用这些条目去表示整个集群的状态
主要描述的信息有:
- 什么容器什么应用及哪一个Node
- 应用使用的资源
- 关于应用如何表现的策略,重启/升级/容错等策略

kubernetes对象是"目标性记录",一旦创建对象,集群将持续工作确保对象的存在,保证集群期望状态

- 对象spec和状态status:
每个kubernetes对象包含两个嵌套的对象字段,负责管理对象的配置：对象spec和对象status
在任何时刻，Kubernetes 控制平面一直处于活跃状态，管理着对象的实际状态以与我们所期望的状态相匹配
关于对象 spec、status 和 metadata 更多信息，查看 Kubernetes API Conventions
https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md


- 描述kubernetes的对象:
在yaml格式文件中定义这些信息,
示例:
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
		
kubectl create -f docs/user-guide/nginx-deployment.yaml --record #创建一个deployment

必需字段:
apiVersion
kind  #创建对象类型
metadata  #识别对象的唯一性数据