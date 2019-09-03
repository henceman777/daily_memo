#Tomcat根目录
TOMCAT_HOME="/usr/local/tomcat/apache-tomcat-9.0.0.M4"
#端口
TOMCAT_PORT=8080
#TOMCAT_PID用于检测Tomcat是否在运行
TOMCAT_PID=`lsof -n -P -t -i :${TOMCAT_PORT}`
 
#如果Tomcat还在运行
if [ -n "${TOMCAT_PID}" ]; then
 #关闭Tomcat
 ${TOMCAT_HOME}/bin/shutdown.sh
 #循环检查Tomcat是否关闭完成
 while [ -n "${TOMCAT_PID}" ]
 do
  #等待1秒
  sleep 1
  #获取8080端口运行进程PID，如果PID为空则表示Tomcat已经关闭
  TOMCAT_PID=`lsof -n -P -t -i :${TOMCAT_PORT}`
  echo "正在关闭Tomcat["${TOMCAT_PORT}"]..."
 done
 echo "成功关闭Tomcat."
fi
 
warPath="${TOMCAT_HOME}/webapps/war包名称/"
warFile="${TOMCAT_HOME}/webapps/war包名称.war"
 
#如果文件或者文件夹存在则删除
deleteWhenExist(){
 if [ -e $1 ]; then
  rm -rf $1
 fi
}
 
deleteWhenExist ${warPath}
deleteWhenExist ${warFile}
 
#拷贝新编译的包到Tomcat
cp 项目名称/target/war包名称.war ${TOMCAT_HOME}/webapps/
 
${TOMCAT_HOME}/bin/startup.sh
echo "正在启动Tomcat["${TOMCAT_PORT}"]..."
 
#检测Tomcat是否启动完成
while [ -z "${TOMCAT_PID}" ]
do
 sleep 1
 #echo "TOMCAT_PID["${TOMCAT_PID}"]"
 TOMCAT_PID=`lsof -n -P -t -i :${TOMCAT_PORT}`
 echo "正在启动Tomcat["${TOMCAT_PORT}"]..."
done
 
echo "成功启动Tomcat."
