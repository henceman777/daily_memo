## 一. [Jenkins官方文档](https://jenkins.io/zh/doc/pipeline/tour/getting-started/)
docker run \
>   --rm \
>   -u root \
>   -p 8080:8080 \
>   -v jenkins-data:/var/jenkins_home \
>   -v /var/run/docker.sock:/var/run/docker.sock \
>   -v "$HOME":/home \
>   jenkinsci/blueocean


### Jenkins配置
设置Jenkins主目录
设置JDK、Ant路径
设置Git地址和目录


系统设置JAVA_HOME、Ant_HOME

### 构建Job
- 常规设置general
```
1. 新建项目
2. 项目名称和描述
3. 丢弃的构建
4. 参数化构建过程
```

- 源码管理
```
repo仓库地址; credentials配置，用户名秘钥等凭据
具体的项目路径，默认根目录；选择构建的分支
额外认证
代码检出策略
```

- 构建触发器
```
构建：执行shell
触发远程构建；自动化构建(脚本和工具执行构建)
Build after other projects are build
定时构建
Build when a change is pushed
Poll SCM
```

- 构建环境
```
构建前清空工作空间
构建出现问题终止构建
给控制台输出增加时间戳
使用加密文件或文本
```

- 构建
```
Execute shell 执行shell脚本
ant执行脚本进行构建
gradle脚本实现自动打包
maven
```

- 构建后的操作
```
发送邮件
构建后删除工作空间
```


### Jenkins管理节点
- 新建节点
- 节点名称jenkins_slave
- 节点创建成功后会自动跳转到配置页面
- 使用slave机器进入Jenkins的管理节点页面，配置连接
- 关联job



---
- 流水线按功能的划分：
构建build - 测试test - 部署deploy

- Jenkinsfile信息如下所示，内容非常简单易读，简单说明如下：

pipeline是结构，在其中可以指定agent和stages等相关信息
agent用于指定执行job的节点，any为不做限制
stages用与设定具体的stage
stage为具体的节点，比如本文示例中模拟实际的 Build（构建）、测试（Test）、部署（Deploy）的过程。
tools中可以使用集成的工具进行操作

```
pipeline {
    agent any

    tools {
        maven 'bundled'
    }

    stages {
        stage('Build') {
            steps {
                sh 'echo Build stage ...'
                sh 'java -version'
            }
        }
        stage('Test'){
            steps {
                sh 'echo Test stage ...'
                sh 'mvn --version'
            }
        }
        stage('Deploy') {
            steps {
                sh 'echo Deploy stage ...'
            }
        }
    }
  }

```

### Jenkins Pipeline
- Pipeline的概念
Pipeline是一套运行于Jenkins上的工作流框架，将原本独立运行于单个或者多个节点的任务连接起来，实现单个任务难以完成的复杂流程编排与可视化
Pipeline是Jenkins2.X的最核心的特性, 帮助Jenkins实现从CI到CD与DevOps的转变
Pipeline是一组插件，让Jenkins可以实现持续交付管道的落地和实施
Pipeline as Code（Jenkinsfile存储在项目的源代码库）

- stage阶段
一个pipeline划分成多个stage，每个stage代表一组操作

- node节点
一个node是一个Jenkins节点，master或agent，是执行step的具体运行环境

- step步骤
step是最基本的操作单元，小到创建目录，大到构建docker镜像

Pipeline：单个Job完成所有任务编排，多分支pipeline跟据jenkinsfile自动创建job
pipeline基于Groovy语言实现：声明式和脚本式

Docker 1.9以后支持overlay 网络driver，overlay需要key-value存储；如consul、etcd等


### Devops：
- 自动化测试
- 持续集成
- 代码质量管理


设计架构规划-代码的存储-构建-测试、预生产、部署、监控


### Git版本控制系统
#### vcs
- svn集中式版本控制系统，集中式中央数据仓库，对网络要求高
- Git分布式版本控制系统
git config --global user.name max
git config --global user.email max@123.com
git config --global color.ui true



git reset b.txt等效于git rm --cached b.txt
git checkout -- d 
git rm -f d  #删除彻底
git diff --cached a



### Jenkins Pipeline
#### CI/CD持续集成和部署
持续集成：自动化的构建(编译、发布、自动测试)，尽量尽早发现集成错误
持续部署：通过自动化构建、测试和部署循环来快速交付高质量的产品
持续交付：频繁的将软件新版本，交付给质量团队或用户，以供评审

#### pipeline
Jenkins 2.0大的精髓是Pipeline as Code，帮助jenkinsCI到CD的转变
Pipeline的实现方式Groovy DSL的语法

- Pipeline的概念
用户定义的CD流水线模式，构建-测试-发布

- Node
是机器，Jenkins环境的部分，能够执行Pipeline，node代码块是脚本式pipeline语法的关键特性

- Stage
定义整个Pipeline中执行的概念上不同的任务子集，有插件可视化或呈现进度

- Step
一项任务

#### jenkinsfile声明式和脚本式
```
pipeline{
agent any
stages{
stage("get code"){
steps{
echo "get code from scm"
}
}
stage("package"){
steps{
echo "package code"
}
}
stage("deploy"){
steps{
echo "deploy package to node1"
}
}
}
}
```
