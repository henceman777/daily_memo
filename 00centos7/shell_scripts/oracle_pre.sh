#!/bin/bash

#普通Linux服务器 /root目录下执行此脚本,执行之前修改用户的密码
HTOPS_PWD=trade

#1.关闭iptables
iptables -F
service iptables save
service iptables restart
chkconfig iptables off
service iptables stop
service ip6tables stop

if [ $? -ne 0 ]; then
    echo "stop iptables filed" >&2
    exit 1
fi

#2.关闭ipv6
echo "NETWORKING_IPV6=no" >>/etc/sysconfig/network
echo "alias net-pf-10 off" >> /etc/modprobe.d/disipv6.conf
echo "alias ipv6 off" >> /etc/modprobe.d/disipv6.conf
/sbin/chkconfig ip6tables off

#3.关闭SELinux
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
setenforce 0

#8.清除系统Banner
cp /etc/issue /etc/issue.bak
cp /etc/issue.net /etc/issue.bak
echo "" > /etc/issue
echo "" > /etc/issue.net

#9.设置用户最大进程以及资源限制
sed -i 's/1024/102400/' /etc/security/limits.d/90-nproc.conf
ulimit -u 102400

#16.安装基本的PRM包
yum -y install gcc gcc-c++ unzip zip man make vim

#17.reboot system
echo "system init end, reboot system afte 5s"
sleep 5

reboot
