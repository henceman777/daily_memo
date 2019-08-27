#!/bin/bash

#Author: jinmax
#email: jinmeng260@gmail.com
#desc: using for initialize environment after complete installation centos7


USER=jinmax
PASSWD=jinmax
HOSTNAME=
DNS1=
DNS2=

Green_font="\033[32m"
Yellow_font="\033[33m"
Red_font="\033[31m"
Font_suffix="\033[0m"

Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
reboot="${Yellow_font}重启${Font_suffix}"
echo -e "${Green_font}
#welcome banner
cat << EOF
+------------------------------------------------------------------+
|     **********  Welcome to CentOS 7 System init  **********      |
+------------------------------------------------------------------+
EOF
${Font_suffix}"



#user checking
[ `whoami` != "root" ] && echo "please use root" && exit 1 
#[ `id -u` != 0 ] && echo "please use root" && exit 1 

#add user
echo "添加个人用户"
useradd $USER
echo $PASSWD | passwd $USER --stdin 
usermod -G wheel $USER
groups $USER


#hostname
hostnamectl set-hostname $HOSTNAME


#dns
echo "" > /etc/resolv.conf     
echo "nameserver $DNS1" > /etc/resolv.conf
echo "nameserver $DNS2" >> /etc/resolv.conf
echo "options timeout:1 rotate" >> /etc/resolv.conf
cat /etc/resolv.conf
ping -c 3 www.baidu.com  

#disable firewalld
systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld

#disable selinux
[ `getenforce` != "Disabled" ] && setenforce 0 && sed -i '/^SELINUX/ s/enforcing/disabled/g' /etc/selinux/config
grep '^SELINUX=' /etc/selinux/config 

#ssh PermitRootLogin no; etc
sed -i 's/^#PermitRootLogin\ yes/PermitRootLogin\ no/' /etc/ssh/sshd_config
echo "UseDNS no" >> /etc/ssh/sshd_config
sed -i 's/RSAAuthentication no/RSAAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
systemctl daemon-reload
systemctl restart sshd

#ntp time synchronization
sed -i "/server/d" /etc/chrony.conf
echo 'server ntp.aliyun.com iburst' >> /etc/chrony.conf
timedatectl set-timezone Asia/Shanghai
systemctl enable chronyd

#yum repo set up
#mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
#curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
#yum makecache

if [ -e /etc/redhat-release ];then
    System_release_File=/etc/redhat-release
  elif [ -e /etc/centos-release ];then
    System_release_File=/etc/centos-release
  elif [ -e /etc/system-release ];then
    System_release_File=/etc/system-release
fi
if [ -n "$System_release_File" ];then
    System_release=$(sed -e 's@.*release @@g' -e 's@\..*@@g' "$System_release_File") || System_release=$(sed 's@.*release @@g' "$System_release_File" | awk -F. '{print $1}')
fi
if [ -n "$System_release" ];then
    if [[ "$System_release" =~ [1-9] ]];then
        echo -e "\033[1mSystem release:\033[m\033[34;1m${System_release}\033[m"
    fi
  else
    echo "Unknown System release"
    exit 255
fi

Yum() {
  echo -e "\033[34;1mCentOS "$System_release" install Network yum source\033[m"
  find '/etc/yum.repos.d/' -name *.repo -exec mv {} {}'.bak' \;
    $(\which wget &> /dev/null)
      if [ "$?" -eq 0 ];then
          wget -q -t 2 -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-"$System_release".repo 
        else
          curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-"$System_release".repo
      fi
      if [ "$?" -eq 0 ];then
          yum clean all && yum list all && yum repolist
          yum -y install epel-release
      fi
      if [ "$?" -eq 0 ];then
          echo -e "\033[32m$(date +%F_%R:%S):CentOS network yum source has been configured successfully and you can now use yum to install or uninsta programs.\033[0m"
        else
          echo -e '\033[47;31;1mCentOS network yum source configuration failed, please confirm!\033[0m' && exit 222
      fi
  exit "$?"
}

ping -c8 www.baidu.com
  if [ "$?" -eq 0 ];then
      if [ -f ./yum.log ];then
          echo >> ./yum.log
          echo -e '\033[1;32m===== Network YUM source installation log information =====\033[m' | tee -a yum.log
          Yum | tee -a yum.log
        else
          echo -e '\033[1;35m===== New network yum source =====\033[m' | tee yum.log
          Yum | tee -a yum.log
      fi
    else
      echo -e '\033[31;1mError, please check the network.\033[0m' ; exit 13
  fi
#END





#yum install untils
yum -y install make gcc-c++ cmake snmp iotop wget vim-enhanced lsof git git-daemon sysstat traceroute \
screen zip unzip bzip2 zlib zlib-devel gcc-c++ curl curl-devel tmux nc htop strace vim wget \
bash-completion net-tools epel-release ntp nfs-utils rpcbind

#java
yum install -y java-1.78.0-openjdk.x86_64
yum install -y maven
yum -y install readline.i686 readline.x86_64

#=======安装docker============
installDocker(){
#yum update -y
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#yum-config-manager --add-repo docker-ce.repo
yum install -y /data/dockerinstall/docker-ce-cli-18.09.0-3.el7.x86_64.rpm
yum install -y /data/dockerinstall/docker-ce-18.09.0-3.el7.x86_64.rpm
#yum install -y /data/dockerinstall/docker-ce-18.03.1.ce-1.el7.centos.x86_64.rpm
#yum install docker-ce
#阿里云加速
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://dqd3qtfe.mirror.aliyuncs.com"]
}
EOF
systemctl enable docker.service
}

#complete prompt
read -p "系统初始化完毕,是否需要重启(y/n)?" TT
    if [ "$TT" == "y" ];then
        reboot
    elif [ "$TT" == "n" ];then
        exit 4
    else
        echo "请输入y/n"
    fi
	
	
	









