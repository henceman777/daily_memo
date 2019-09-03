
#!/bin/bash
# Author: hanli
# centos7初始化脚本

#USER=hanli
#PASSWD=abc520224
HOSTNAME=test.example.com
DNS1=119.29.29.29
DNS2=223.5.5.5

cat << EOF
+------------------------------------------------------------------+
|     **********  Welcome to CentOS 7 System init  **********    |
+------------------------------------------------------------------+
EOF

[ `whoami` != "root" ] && echo "please use root" && exit 1 

function format() {
    
    echo "-------------------我是分割线------------------------"
}

echo "添加配色"
echo 'export PS1="\[\e[1;33m\]\[\e[0;33m\][\[\e[1;32m\]\u\[\e[m\]\[\e[1;33m\]@\[\e[m\]\[\e[1;35m\]\h\[\e[m\]\[\e[0;33m\]] \w\$ \[\e[m\]"' >> /etc/bashrc
tail -n 1 /etc/bashrc
format

#echo "添加个人用户"
#useradd $USER
#echo $PASSWD | passwd $USER --stdin 
#usermod -G wheel $USER
#groups $USER
#format
#
#echo "赋予wheel用户组免密码sudo权限"
#sed -i 's/^%wheel/#&/' /etc/sudoers
#sed -i 's/^#\( %wheel\)/\1/' /etc/sudoers
#grep 'wheel' /etc/sudoers
#format
#
echo "设置主机名"
hostnamectl set-hostname $HOSTNAME
hostname 
format

echo "设置dns"
echo "" > /etc/resolv.conf     
echo "nameserver $DNS1" > /etc/resolv.conf
echo "nameserver $DNS2" >> /etc/resolv.conf
echo "options timeout:1 rotate" >> /etc/resolv.conf
cat /etc/resolv.conf
ping -c 3 www.baidu.com  
format

echo "关闭防火墙"
systemctl stop firewalld
systemctl status firewalld
format

echo "关闭selinux"
[ `getenforce` != "Disabled" ] && setenforce 0  && sed -i '/^SELINUX/ s/enforcing/disabled/g' /etc/selinux/config
grep '^SELINUX=' /etc/selinux/config 
format

##echo "禁止root登录"
##sed -i 's/^#PermitRootLogin\ yes/PermitRootLogin\ no/' /etc/ssh/sshd_config
##format
#
#
##echo "设置ntp"
##sed -i "/server/d" /etc/chrony.conf
##echo 'server ntp.aliyun.com iburst &>/dev/null' >> /etc/chrony.conf
##format

echo "更换yum源为阿里云"
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum makecache
format


echo "安装常用软件包"
yum -y install make gcc-c++ cmake snmp  iotop  wget vim lsof  git sysstat  traceroute
format

read -p "系统初始化完毕,是否需要重启(y/n)?" TT
    if [ "$TT" == "y" ];then
        reboot
    elif [ "$TT" == "n" ];then
        exit 4
    else
        echo "请输入y/n"
    fi
