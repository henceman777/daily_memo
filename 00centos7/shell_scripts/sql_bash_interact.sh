#!/bin/bash
# Define log
TIMESTAMP=`date +%Y%m%d%H%M%S`
LOG=call_sql_${TIMESTAMP}.log
echo "Start execute sql statement at `date`." >>${LOG}
# execute sql stat
mysql -uroot -p'Hanli224!' -e "
tee /tmp/temp.log
drop database if exists tempdb;
create database tempdb;
use tempdb
create table if not exists tb_tmp(id smallint,val varchar(20));
insert into tb_tmp values (1,'jack'),(2,'robin'),(3,'mark');
select * from tb_tmp;
notee
quit"
 
echo -e "\n">>${LOG}
echo "below is output result.">>${LOG}
cat /tmp/temp.log>>${LOG}
echo "script executed successful.">>${LOG}
exit;
