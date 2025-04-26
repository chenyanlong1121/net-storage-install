#!/bin/bash

#一、确认备份文件所在目录、备份目录


nfs_data_path='/home/nfs_root'
backup_path=$nfs_data_path'/backups'
mkdir -p $backup_path

#二、生成备份文件至备份目录
echo -e "\033[32m **********开始执行时间：$(date +%Y年%m月%d日\ %H时%M分%S秒)********* \033[0m"
#  backup file(include mysql data)  to  backup_path
echo -e "\033[32m **********开始打包备份文件********* \033[0m"
cd $nfs_data_path
tar -zcvf  $backup_path/mysql_`date +%Y_%m_%d`.tgz  *mysql-data-db* 
echo -e '\033[32m backup success \033[0m'
#三、删除两周前备份文件
#find nas backup file and  delete  old  backup file
echo -e "\033[32m **********开始删除两周前的备份文件********* \033[0m"
find $backup_path/mysql_* -ctime +14 -type f -exec rm {} \;
if [ $? -eq 0 ]
 then
   echo -e '\033[32m delete success \033[0m'
 else
   echo -e '\033[31m delete fail \033[0m'
fi
echo -e "\033[32m **********结束执行时间：$(date +%Y年%m月%d日\ %H时%M分%S秒)********* \033[0m"
