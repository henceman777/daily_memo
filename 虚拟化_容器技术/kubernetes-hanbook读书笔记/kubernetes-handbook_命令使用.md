https://jimmysong.io/kubernetes-handbook/guide/command-usage.html

1. kubectl 及其他管理命令使用
docker run:
docker run -d --restart=always -e DOMAIN=cluster --name nginx-app -p 80:80 nginx

kubectl run:
kubectl run --image=nginx nginx-app --port=80 --env="DOMAIN=cluster"

----------------------------------------------------------------------------------------------------------
kubectl自动补全:
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc

命令别名:
alias k=kubectl
complete -F __start_kubectl k

kubectl cluster-info
kubectl api-versions
kubectl explain rc

- run
ubectl run sonarqube --image=192.168.32.131:5000/sonarqube:5.6.5 --replicas=1 --port=9000 #创建一个deployment

- get
kubectl get all 	#列出所有不同的资源对象
kubectl get csr     #列出所有csr请求  
kubectl get	clusterrolebindings  #列出集群角色绑定
kubectl get clusterroles #列出集群角色
kubectl get	componentstatuses #cs；查看集群监控状态
kubectl get configmaps #获取资源对象cm

kubectl get	controllerrevisions  #
kubectl get	cronjobs
kubectl get	daemonsets #(aka 'ds')
kubectl get	deployments #(aka 'deploy')
kubectl get	endpoints #(aka 'ep')
kubectl get	events #查看事件(aka 'ev')   
kubectl get	horizontalpodautoscalers #(aka 'hpa')
kubectl get	ingresses #(aka 'ing')
kubectl get	jobs
kubectl get	limitranges (aka 'limits')
kubectl get	namespaces #(aka 'ns')
kubectl get	networkpolicies #(aka 'netpol')
kubectl get	nodes #(aka 'no')
kubectl get node --show-labels

kubectl get	persistentvolumeclaims #(aka 'pvc')
kubectl get	persistentvolumes #(aka 'pv')

kubectl get	poddisruptionbudgets #(aka 'pdb')
kubectl get	podpreset
kubectl get	pods #(aka 'po')
kubectl get po -o wide
kubectl get po --namespace=kube-system
kubectl get po --all-namespaces
kubectl get pods --all-namespaces -o wide
kubectl get -f pod.yaml -o json
kubectl get	podsecuritypolicies #(aka 'psp')
kubectl get	podtemplates
kubectl get pod [podname] -o yaml
kubectl get pod [podname] -o json
kubectl get po rc-nginx-2-btv4j -o=custom-columns=LABELS:.metadata.labels.app
kubectl get pods -l app=nginx  #指定label查看pod

kubectl get	replicasets   #(aka 'rs')
kubectl get	replicationcontrollers  #(aka 'rc')
kubectl get rc,services   #查看replication controller
kubectl get	resourcequotas #(aka 'quota')
kubectl get resourcequota --all-namespaces -o yaml
kubectl get	rolebindings
kubectl get	roles
kubectl get	secrets  #查看secret
kubectl get	serviceaccounts #(aka 'sa')
kubectl get	services   #(aka 'svc')
kubectl get	statefulsets
kubectl get	storageclasses
kubectl get	thirdpartyresources

kubectl describe po [podname] 

- create命令
kubectl create -f filename
kubectl patch pod rc-nginx-2-kpiqt -p '{"metadata":{"labels":{"app":"nginx-3"}}}' 
kubectl edit po rc-nginx-btv4j 

- delete命令
kubectl delete pod,service baz foo
kubectl delete pods,services -l name=myLabel
kubectl delete -f rc-nginx.yaml 
kubectl delete po rc-nginx-btv4j 
kubectl delete po -lapp=nginx-2 
kubectl delete pod foo --grace-period=0 --force
kubectl delete pods --all

- logs
kubectl logs rc-nginx-2-kpiqt 
kubectl logs -f --namespace=kube-system [pod] 

- scale命令,扩容和缩容
kubectl scale rc rc-nginx-3 —replicas=4 
kubectl scale rc rc-nginx-3 —replicas=2
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql  #如果当前副本数为2，则将其扩展至3
kubectl scale --replicas=5 rc/foo rc/bar rc/baz
kubectl autoscale deploy/mysql --min=3 --max=10 #使用默认的自动伸缩策略，指定目标CPU使用率，使其Pod数量在3到10之间
kubectl get horizontalpodautoscalers.autoscaling #水平自动伸缩
kubectl delete horizontalpodautoscalers.autoscaling nginx-deployment  #删除hpa
kubectl autoscale deploy mysql --max=10 --cpu-percent=80 #Pod的数量介于1和10之间，CPU使用率维持在80%

- cordon和drain
kubectl cordon d-node    #cordon命令将d-node1标记为不可调度
kubectl drain d-node1    #node在维护期间排除, 将运行在d-node1上运行的pod平滑的赶到其他节点上
kubectl uncordon d-node  #节点维护完后，使用uncordon命令解锁d-node1，使其重新变得可调度

kubectl run nginx --image=nginx --expose --port=80 --replicas=5
kubectl get pod -o wide
kubectl drain [nodename] --ignore-daemonsets --delete-local-data   #排除node

- taint
taint使节点能够排斥一类特定的pod
taint和toleration相互配合，可以用来避免pod被分配到不合适的节点上
每个节点上都可以应用一个或多个taint，这表示对于那些不能容忍这些 taint 的 pod，是不会被该节点接受的。
如果将 toleration 应用于 pod 上，则表示这些 pod 可以（但不要求）被调度到具有匹配 taint 的节点上

kubectl taint nodes <node_name> <key>=<value>:NoSchedule


- top
kubectl top node  #资源使用情况


- attach
- exec
在Pod的容器里执行date命令，默认使用Pod中的第1个容器执行
kubectl exec <pod-name> date

指定Pod中某个容器执行date命令
kubectl exec <pod-name> -c <container-name> date

以bash方式登陆到Pod中的某个容器里
kubectl exec -it nginx-5847748bf9-49k5k /bin/bash
kubectl exec -it <pod-name> -c <container-name> /bin/bash

- cp
kubectl cp mysql-478535978-1dnm2:/tmp/message.log message.log
kubectl cp message.log mysql-478535978-1dnm2:/tmp/message.log  #拷贝到pod


- port-forward
- proxy
- run
- label

- rollout更新升级,回滚
kubectl rollout history deploy/nginx-deployment
kubectl rollout resume deploy/nginx-deployment
kubectl rollout status deploy/nginx-deployment
kubectl rollout history deploy/nginx-deployment--revision=2  