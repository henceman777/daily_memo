6. 控制Controller Manager
控制器controller相当于状态机,控制pod的具体状态和行为

6.1 Deployment
deployment为pod和replicaSet提供声明式declarative方法,用来替换之前的replicationController
- 应用场景
定义deployment来创建pod和replicaSet
滚动升级和回滚应用
扩容和缩容
暂停和继续deployment

一个简单的nginx定义:
apiVersion: extensions/v1beta1
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
		
kubectl scale deployment nginx-deployment --replicas=4  #扩容
kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80

kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1  #更换镜像版本
kubectl rollout undo deployment/nginx-deployment  #回滚

- Deployment是什么
在 Deployment 中描述您想要的目标状态是什么，Deployment controller 就会帮您将 Pod 和ReplicaSet 的实际状态改变到您的目标状态		

- 创建Deployment
kubectl create -f https://kubernetes.io/docs/user-guide/nginx-deployment.yaml --record
kubectl get deployments
kubectl get rs
kubectl get pods
kubectl get pods --show-labels

- 更新Deployment
Deployment 的 rollout 当且仅当 Deployment 的 pod template（例如.spec.template）中的label更新或者镜像更改时被触发
其他更新，例如扩容Deployment不会触发 rollout

kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
kubectl edit deployment/nginx-deployment
kubectl rollout status deployment/nginx-deployment #查看rollout状态
kubectl get deployments
kubectl get rs
kubectl get pods


- rollover(多个rollout并行)

- label selector更新:

- 回退Deployment
kubectl rollout history deployment/nginx-deployment  #Deployment 的 revision
kubectl rollout history deployment/nginx-deployment --revision=2
kubectl rollout undo deployment/nginx-deployment  #回退历史版本
kubectl rollout undo deployment/nginx-deployment --to-revision=2  #指定某个历史版本

- 扩容deployment
kubectl scale deployment nginx-deployment --replicas 10
kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80

- 比例扩容
例如，您正在运行中含有10个 replica 的 Deployment。maxSurge=3，maxUnavailable=2

- 暂停和恢复deployment
kubectl rollout pause deployment/nginx-deployment
kubectl set image deploy/nginx nginx=nginx:1.9.1
kubectl rollout history deploy/nginx
kubectl set resources deployment nginx -c=nginx --limits=cpu=200m,memory=512Mi

kubectl rollout resume deploy nginx  #恢复这个Deployment
kubectl get rs -w


用例:
- 金丝雀deployment
使用 Deployment 对部分用户或服务器发布 release，您可以创建多个 Deployment，每个 Deployment 对应一个 release，
参照 managing resources 中对金丝雀模式的描述

6.2 StatefulSet
解决有状态的服务,应用场景有:
- 稳定的持久化存储,即pod重新调度后还能访问到相同的持久化数据,基于PVC实现
- 稳定的网络标志,podname和hostname不变,基于headless service来实现是
- 有序的部署,有序扩展, 基于init container来实现
- 有序的收缩、有序的删除 
每个Pod的DNS格式为 statefulSetName-{0..N-1}.serviceName.namespace.svc.cluster.local


- 使用statefulset
适于用: 稳定有序的网络标志、稳定持久化的存储、有序部署的scale、有序删除和终止、有序自动的滚动升级


- 组件
示例
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: gcr.io/google_containers/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
      annotations:
        volume.beta.kubernetes.io/storage-class: anything
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi