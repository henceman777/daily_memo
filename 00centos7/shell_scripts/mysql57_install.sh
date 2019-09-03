#!/bin/bash
#author:hanli
cat > /etc/yum.repos.d/mysql-community.repo <<EOF
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql57-community-el7/
enabled=1
gpgcheck=0
EOF
yum install -y mysql-community-server
systemctl enable mysqld
systemctl start mysqld
systemctl status mysqld
grep 'temporary password' /var/log/mysqld.log
mysql -uroot -p
