#!/bin/bash
#批量ssh认证建立  
 
for p in $(cat /root/ip.txt)  #注意ip.txt文件的绝对路径  
do   
ip=$(echo "$p"|cut -f1 -d":")       #取ip.txt文件中的ip地址  
password=$(echo "$p"|cut -f2 -d":") #取ip.txt文件中的密码  
 
#expect自动交互开始  
expect -c "   
spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$ip  
        expect {   
                "yes/no" {send \"yes\n\"; exp_continue}   
                "Password:" {send \"$password\n\";}        
        }   
"   # 注意转义
done
