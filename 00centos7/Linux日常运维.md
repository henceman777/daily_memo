https://blog.csdn.net/miss1181248983/article/details/80634490

## 监控系统的状态
- 查看当前系统负载： w、uptime
```
± uptime
07:36:42 up 1039 days, 16:28,  1 user,  load average: 0.07, 0.04, 0.01
```
一般情况下load average的一分钟内不大于cpu数量就ok

- 查看CPU数量\
`grep -c 'processor' /proc/cpuinfo`

- 监控系统的状态： vmstat
```
± vmstat
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0 1248916 367900 133324 866352  0    0     0     3    0    0  0  0  100 0  0

#vmstat命令显示的结果分为6部分：procs、memory、swap、io、system和cpu
- procs——显示进程的相关信息  
    r（run）：表示运行或等待CPU时间片的进程数；  
    b（block）：表示等待资源的进程数，资源指的是I/O、内存等。  

- memory——显示内存的相关信息  
    swpd：表示切换到交换分区中的内存数量，单位为KB，该值波动时说明内存不足；  
    free：表示当前空闲的内存数量，单位为KB；  
    buff：表示（即将写入磁盘的）缓冲大小，单位为KB；  
    cache：表示（从磁盘读取的）缓存大小，单位为KB。

- swap——显示内存的交换情况  
    si：表示由交换区写入内存的数据量，单位为KB；  
    so：表示由内存写入交换区的数据量，单位为KB。

- io——显示内存的交换情况  
    bi：表示从块设备读取数据的量（磁盘→内存），单位为KB；  
    bo：表示从块设备写入数据的量（内存→磁盘），单位为KB。

- system——显示采集间隔内发生的中断次数  
    in：表示在某一时间间隔内观测到的每秒设备的中断次数；  
    cd：表示每秒产生的上下文切换次数。

- cpu——显示CPU的使用状态  
    us：表示用户下所花费CPU的时间百分比（通常us<=10比较合适）；  
    sy：表示系统花费CPU的时间百分比(sy与us呈正相关）；  
    id：表示CPU处于空闲状态的时间百分比；  
    wa：表示I/O等待所占用CPU的时间百分比；  
    st：表示被偷走的CPU所占的时间百分比（一般为0）。  
    us + sy + id = 100%

vmstat 1 5  #动态输出,一秒一次输出5次
```


- 显示进程所占用的系统资源：top/htop
```
± top -bn1 -c |head -20
top - 07:47:11 up 1039 days, 16:39,  1 user,  load average: 0.07, 0.07, 0.02
Tasks: 614 total,   2 running, 612 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.2 us,  0.1 sy,  0.1 ni, 99.6 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem:   6110992 total,  5742540 used,   368452 free,   133404 buffers
KiB Swap:  1998844 total,  1248916 used,   749928 free.   866580 cached Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
10909 jinmax    20   0   27448   5072   2796 R  12.1  0.1   1064:32 htop
21218 jinmax    20   0   25256   3164   2452 R   6.1  0.1   0:00.02 top
    1 root      20   0   37368   3148   1836 S   0.0  0.1   3:47.77 init
    2 root      20   0       0      0      0 S   0.0  0.0   0:08.61 kthreadd
...
```
- htop的交互式命令:
```
上下键或PgUP/PgDn		选定想要的进程，左右键或Home, End   移动字段，当然也可以直接用鼠标选定进程；   
Space					标记/取消标记一个进程。命令可以作用于多个进程，例如 "kill"，将应用于所有已标记的进程   
U						取消标记所有进程   
s						选择某一进程，按s:用strace追踪进程的系统调用   
l						显示进程打开的文件: 如果安装了lsof，按此键可以显示进程所打开的文件（小写l）   
I						倒转排序顺序，如果排序是正序的，则反转成倒序的，反之亦然(大写i）   
+, -					在树形模式下，展开或折叠子树  
a						(在有多处理器的机器上) 设置 CPU affinity:   标记一个进程允许使用哪些CPU   
u						显示特定用户进程   
M						按Memory 使用排序   
P						按CPU 使用排序   
T						按Time+ 使用排序   
F						跟踪进程: 如果排序顺序引起选定的进程在列表上到处移动，让选定条跟随该进程。
                        这对监视一个进程非常有用：通过这种方式，你可以让一个进程在屏幕上一直可见。
                        使用方向键会停止该功能。   
K						显示/隐藏内核线程   
H						显示/隐藏用户线程   
Ctrl-L					刷新
```

- 监控系统状态：sar
```
sar可以监控平均负载、网卡流量、磁盘状态、内存使用等系统状态
yum install -y sysstat  
sar -n DEV | head -15  #查看流量
sar -n DEV -f /var/log/sa/sa09 | head -15
sar -q  #查看历史负载
sar -b  #查看磁盘负载
```

- 查看网卡流量：nload
```
yum install -y epel-release
yum install -y nload
```

- 监控I/O性能：iostat iotop\
`iostat -x`


- 查看内存使用状况：free
```
free -h
             total       used       free     shared    buffers     cached
Mem:          5.8G       5.5G       357M       440K       128M       857M
-/+ buffers/cache:       4.5G       1.3G
Swap:         1.9G       1.2G       723M

#注解
total			内存总大小
used			真正使用的内存大小
free			剩余物理内存大小
shared			共享内存大小
buff/cache		分配给buffer和cache的内存，即缓冲/缓存（数据经过CPU计算，即将写入磁盘，用到的内存为buffer；CPU要计算时，需要把数据从磁盘中读出来，临时放入内存中，用到的内存是cache）
available		系统可使用的内存大小，包含free和buffer/cache剩余部分

total = used + free + buff/cache

```

### 查看系统进程： ps
- ps aux 显示进程信息非常详细（ps -elf与ps aux作用类似）
```
ps aux | head -5
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  37368  3148 ?        Ss    2016   3:47 /sbin/init
root         2  0.0  0.0      0     0 ?        S     2016   0:08 [kthreadd]
root         3  0.0  0.0      0     0 ?        S     2016   6:39 [ksoftirqd/0]
root         5  0.0  0.0      0     0 ?        S<    2016   0:00 [kworker/0:0H]

#注解
PID 		表示进程的ID，kill使用时后面需要跟上PID
  
STAT 		进程的状态，主要有以下几种：
	D 		不能中断进程（通常为IO）
	R		正在运行中的进程
	S		已经中断的进程
	Z		僵尸进程，杀不掉、打不死的进程（主进程意外丢失）
	<		高优先级进程
	N		低优先级进程
	s		主进程  
	l		多线程进程
	- \+ 	在前台运行的进程

```

### 查看网络状况：netstat
- netstat -lnp查看当前系统启动了哪些端口（netstat -ltnp查看tcp端口；netstat -lunp查看udp端口）


### 抓包工具
- tcpdump -nn
```
± sudo tcpdump -nn -i eth0  -c 10
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
08:06:37.455336 IP 10.223.10.51.22 > 10.167.188.29.64818: Flags [P.], seq 43797637:43797845, ack 1576205007, win 823, length 208
08:06:37.489983 IP 10.223.10.51.22 > 10.167.188.29.64818: Flags [P.], seq 208:400, ack 1, win 823, length 192
08:06:37.490121 IP 10.223.10.51.22 > 10.167.188.29.64818: Flags [P.], seq 400:576, ack 1, win 823, length 176
...
10 packets captured
12 packets received by filter
0 packets dropped by kernel

-nn		作用是让第3列和第4列显示成“ip+端口号”的形式，不加-nn则显示“主机名+服务名”
-i		指定设备名称
-c		指定抓包数量，抓够了自动退出
-w 		指定保存位置
-r 		读取抓到的包内容
tcp 	指定抓tcp的包
```

- wireshark： tshark
```
yum install -y wireshark
tshark -n -t a -R http.request -T fields -e "frame.time" -e "ip.src" -e "http.host" -e "http.request.method" -e "http.request.uri"
```

### Linux网络相关
- 查看网卡IP: ifconfig、ip addr
```
yum install -y net-tools  
systemctl restart network

#绑定IP
cd /etc/sysconfig/network-scripts/
cp ifcfg-ens33 ifcfg-ens33:1
vim ifcfg-ens33:1
```

- 查看网卡连接状态：\
mii-tool ens33  
ethtool ens33

- 更改主机名：hostname、hostnamectl set-hostname
- 设置DNS：\
vim /etc/hosts\
vi /etc/resolv.conf（临时修改）  
修改网卡配置文件（永久修改）  
vi /etc/hosts 临时解析某个域名


### Linux的防火墙
Selinux是linux系统特有的安全机制，这种机制限制较多，配置也比较繁琐，所以一般把SELinux关闭

### netfilter
CentOS7之前的CentOS版本的防火墙为netfilter，CentOS7的防火墙为firewalld\
而iptables是针对防火墙的一个工具，iptables用来设置、维护和检查Linux内核的IP包过滤规则的
```
systemctl stop firewalld				#关闭firewalld服务
systemctl disable firewalld				#禁止firewalld服务开机启动
yum install -y iptables-services				#安装iptables-services
systemctl enable iptables				#让iptables开机启动
systemctl start iptables				#启动iptables服务

iptables -nvL #查看规则
iptables -F;service iptables save  #清除当前所有规则，但清除只是暂时的
```

- filter表
filter表是iptables的默认表，用于过滤包，如果你没有自定义表
```
INPUT链		处理来自外部的数据
OUTPUT链	处理向外发送的数据
FORWARD链	将数据转发到本机的其他网卡设备上
```
- nat表
nat表用于网络地址转换，它也有3个内建链
```
PREROUTING链    处理刚到达本机并在路由转发前的数据包。它会转换数据包中的目标IP地址（destination ip address），通常用于DNAT(destination NAT)
OUTPUT链	    改变本机产生的包的目的地址
POSTROUTING链   处理即将离开本机的数据包。它会转换数据包中的源IP地址（source ip address），通常用于SNAT（source NAT）
```

- mangle表
mangle表用于指定如何处理数据包，它能改变TCP头中的QoS位，Mangle表具有5个内建链
```
PREROUTING链
INPUT链
FORWARD链
OUTPUT链
POSTROUTING链
```

- raw表
raw表可以实现不追踪某些数据包，默认系统的数据包都会被追踪，用于处理异常，它具有2个内建链：
```
PREROUTING链
OUTPUT链
```

- security表
security表用于强制访问控制（MAC）的网络规则，在CentOS6中没有该表

```
netfilter的5个链：
PREROUTING		数据包进入路由器之前
INPUT			通过路由表后，目的地为本机
FORWARD			通过路由表后，目的地不为本机
OUTPUT			由本级产生，向外转发
POSTROUTING		发送到网卡接口之前
```

- iptables基本语法
```
iptables -t nat -nvL  #查看规则
iptables -F  #删除所有规则
iptables -Z  #把包及流量计数清零

iptables -A INPUT -s 192.168.200.1 -p tcp --sport 1234 -d 192.168.200.200 --dport 80 -j DROP

-A/-D/-I		表示增加/删除/插入一条规则（-I可以插入到最前面，-A只能增加到最后面）
-p				指定协议，可以是tcp、udp、icmp或all
--dport			必须和-p一起使用，表示指定目标端口
--sport			必须和-p一起使用，表示指定源端口
-s				指定源ip（可以是一个ip段）
-d				指定目的ip（可以是一个ip段）
-j				后面跟动作，其中ACCEPT表示允许包，DROP表示丢掉包，REJECT表示拒绝包
-i				指定接收进来数据包的网卡
-o				指定发送出去数据包的网卡
--line-number	显示规则编号（可以根据编号来删除规则）
-P				默认规则，默认为ACCEPT所有包（可以更改为DROP，表示丢弃所有包，不过这是危险操作，轻易不要尝试）  

iptables -I INPUT -s 1.1.1.1 -j DROP #表示插入一条规则，把来自1.1.1.1的数据包全部丢掉
iptables -I INPUT -s 2.2.2.2 -p tcp --dport 80 -j DROP #把来自2.2.2.2并且是TCP协议到本机80端口的数据包丢掉
iptables -I OUTPUT -p tcp --dport 22 -d 10.0.1.14 -j DROP   #把发送到10.0.1.14的22端口的数据包丢掉
iptables -A INPUT -s 192.168.1.0/24 -i eth0 -j ACCEPT       #把来自192.168.1.0/24这个网段且作用在eth0网卡上的包放行
iptables -nvL --line-numbers  #查看iptables规则，显示规则编号
iptables -D INPUT 6         #-D后面依次跟链名、规则编号，表示删除对应编号的规则
iptables -P INPUT ACCEPT    #-P表示预设策略，后面跟链名，策略内容为ACCEPT
iptables -I INPUT -m iprange -src 192.168.100.0-192.168.188.255 -j DROP #
iptables -I INPUT -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
iptables -I INPUT -p icmp --icmp-type 8 -j DROP #表示能在本机ping通其他机器，而其他机器无法ping通本机
```

- iptables规则备份和恢复
```
service iptables save
iptables-save > zx.ipt
iptables-restore < zx.ipt
```

- nat的应用，实现代理上网  
A机器 - 两块网卡ens33(192.168.20.128)、ens37(192.168.100.1)，ens33可以上外网，ens37仅仅是内部网络  
B机器 - 只有ens34（192.168.100.100），和A机器ens37可以通信互联,实现B机器通过A上网
```
#A机器上：
echo "1">/proc/sys/net/ipv4/ip_forward  #打开路由转发
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -o ens33 -j MASQUERADE
route add default gw 192.168.100.1 #设置默认网关为A机器的ens37
route -n  #查看网关

B机器可以ping通 www.baidu.com，实现B机器通过nat借助A机器来上网
```

### firewalld 
- firewalld的9个zone
```
drop			接收的任何网络数据包都会被丢弃，没有任何回复，仅能有发送出去的网络连接
block			接收的任何网络数据包都被 IPv4 的 icmp-host-prohibited 信息和 IPv6 的 icmp6-adm-prohibited 信息所拒绝
public			在公共区域内使用，不能相信网络内的其他计算机不会对你的计算机造成危害，只能接收经过选取的连接
external		特别是为路由器启用了伪装功能的外部网，你不能信任来自网络的其他计算机，不能相信他们不会对你的计算机造成危害，只能接收经过选取的连接
dmz				用于你的非军事区内的电脑，此区域内可公开访问，可以有限地进入你的内部网络，仅仅接收经过选取的连接
work			用于工作区，你可以基本相信网络内的其他计算机不会危害你的电脑，仅接收经过选取的连接
home			用于家庭网络，你可以基本相信网络内的其他计算机不会危害你的电脑，仅接收经过选取的连接
internal		用于内部网络，你可以基本相信网络内的其他计算机不会危害你的电脑，仅接收经过选取的连接
trusted			可以接收所有的网络连接

```

- 关于zone的操作
```
firewall-cmd --get-zones		#查看所有的zone
firewall-cmd --set-default-zone
firewall-cmd --set-default-zone=work	
firewalld-cmd --get-default-zone
firewall-cmd --get-zone-of-interface=ens33	
firewall-cmd --zone=dmz --change-interface=ens33:1	
firewall-cmd --zone=dmz --change-interface=ens33:1	
firewall-cmd --zone=dmz --remove-interface=ens33:1	
firewall-cmd --get-active-zones	 #查看系统所有网卡所在的zone
```

- firewalld关于service的操作
service都是由一个个配置文件定义的，配置文件的模板在/usr/libfirewalld/services/目录下\
真正生效的配置则是在/etc/firewalld/services目录下面
```
firewall-cmd --get-service				#列出当前系统所有的service
firewall-cmd --list-services				#查看当前zone下有哪些service
firewall-cmd --zone=public --list-services				#查看指定zone下有哪些service
firewall-cmd --zone=public --add-service=http			#给指定zone添加服务，重启失效
firewall-cmd --zone=public --list-services
ls /usr/lib/firewalld/zones
firewall-cmd --zone=public --list-services
cat /etc/firewalld/zones/public.xml
firewall-cmd --zone=public --add-service=http --permanent
```

### Linux的计划任务Cron
```
#crontab
crontab -u  #指定用户
crontab -e  #编辑任务
crontab -l   #列出任务
crontab -r   #删除任务
```

### Linux服务管理
- chkconfig
CentOS6上的服务管理工具为chkconfig，linux系统所有的预设服务都可以通过查看/etc/init.d/目录\
CentOS7之前的版本采用的服务管理为SysV，而CentOS7换成了systemd\
数字0~6为系统启动级别，CentOS7仅保留运行级别0、1、6
```
chkconfig --level 3 network off	
chkconfig --list |grep network

chkconfig --level 345 network off		
chkconfig --del network		#从系统服务中删除network服务
chkconfig --add network		#增加network服务到系统服务中
#chkconfig --add/del 服务名用来 增加或删除 系统服务，通常用来把自定义的启动脚本加入到系统服务中
```

- systemd，systemd支持多个服务并发启动
```
systemctl list-units --all --type=service #列出所有服务, /usr/lib/systemd/system/目录下
systemctl enable crond.service
systemctl status crond
systemctl start crond
systemctl is-enabled crond

ls /usr/lib/systemd/system/
systemctl list-units --all
systemctl list-units --all --state-inactive
systemctl list-units --type=service	
systemctl is-active crond.service	
```

target类似于CentOS6的启动级别，但CentOS7支持多个target同时启动。  
target是多个unit的组合，系统使用target来管理unit
```
systemctl list-unit-files --type=target
systemctl list-dependencies multi-user.target  #查看某一target包含的所有unit
systemctl get-default                       #查看系统默认的target,multi-user.target等同于CentOS6的运行级别3
systemctl set-default multi-user.target		#设置默认的target

```

### 数据备份工具rsync
`yum install -y rsync`

### Linux系统日志
- /var/log/messages是核心系统日志文件
包含了系统启动时的1引导消息，以及系统运行时的其他状态消息，I/O错误、网络错误和其他系统错误都会被记录到这个文件中  
对应的日志切割工具：logrotate\
/var/log/messages是由rsyslogd这个守护进程产生的

- dmesg命令可以显示系统的启动信息（主要是硬件）

- last、lastb\
last命令用来查看正确登录linux的历史消息\
lastb命令用来查看登录失败的用户历史记录\
系统的安全日志是/var/log/secure，保存系统被暴力破解的记录


### xargs和exec
- xargs
```
ls 123.txt | xargs cat
touch 1.txt 2.txt 3.txt 4.txt
ls *.txt | xargs -n1 -i{} mv {} {}_bak  
#批量重命名,-n1表示逐个对象进行处理；-i{}表示用{}取代前面的对象；mv {} {}_bak相当于mv 1.txt 1.txt_bak
```

- exec
```
find . -mtime +10 -exec rm -rf {} \;  #{}替代前面find出来的文件，后面的\作为;的转义符
find ./*_bak -exec mv {} {}_bak \;  #批量重命名
```

### screen
- nohup可以防止进程意外中断
`nohup sh /usr/local/sbin/sleep.sh &`

- screen表示虚拟终端，是一个可以在多个进程之间多路复用一个物理终端的窗口管理器。
```
screen -ls
Ctrl+a  组合键再按d退出虚拟终端，只是临时退出（真正结束时Ctrl+D或exit）
screen -r id/终端名  #进入指定的终端（id即终端编号）
screen -S zx        #定义终端名称
```