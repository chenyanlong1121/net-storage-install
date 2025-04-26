#!/bin/sh

echo "请确认大容量硬盘挂载的路径是您指定的nfs路径"
if [ $# != 1 ] ; then 
echo "USAGE: sh install.sh 数据存放路径" 
  echo " e.g.: sh install.sh /home/nfs_root" 
  exit 1; 
fi

NFS_PATH=$1
#安装nfs

echo "NFS服务器暴露路径为：$NFS_PATH"
read -r -p "请确认上述配置,是否继续? [Y/n] " input

case $input in
    [yY][eE][sS]|[yY])
        echo "开始安装NFS"
        rpm -q nfs-utils
        mkdir $NFS_PATH
        chmod 777 $NFS_PATH
        sed -i "/insecure/d" /etc/exports
        echo "$NFS_PATH/ *(insecure,rw,sync,no_root_squash)" >> /etc/exports
        systemctl restart nfs
        systemctl enable nfs
        systemctl restart rpcbind
        systemctl enable rpcbind
        showmount -e localhost
          
	mkdir -p $NFS_PATH/radar-direct-proxy/nginx-config
        mkdir -p $NFS_PATH/kafka-connectors
        cp -r ./kafka-connectors/* $NFS_PATH/kafka-connectors
		    mkdir -p $NFS_PATH/elasticsearch-plugins-ik
        cp -r ./elasticsearch-plugins-ik/* $NFS_PATH/elasticsearch-plugins-ik
        mkdir -p $NFS_PATH/db-init
        mkdir -p $NFS_PATH/file-upload
        cp -r ./geoserver $NFS_PATH/

        mkdir -p $NFS_PATH/storm-data
        mkdir -p $NFS_PATH/storm-logs
		mkdir -p $NFS_PATH/portal-upload
        mkdir -p $NFS_PATH/kuboard_data
        #创建Nifi与上传文件
        mkdir -p $NFS_PATH/nifi/nifi-current/extensions
        cp -r nifi  $NFS_PATH/
		  
		  #备份mysql数据：每周六凌晨四点备份一次，删除两周之前的备份文件
		  cp -r nfs_data_backup.sh   /root/nfs_data_backup.sh
		  chmod 777  /root/nfs_data_backup.sh
		  sed -i "s#/home/nfs_root#$NFS_PATH#g" /root/nfs_data_backup.sh
		  cat >> /var/spool/cron/root  << eof
0 4 * * 6 /root/nfs_data_backup.sh 2>&1> /root/nfs_data_backup.log
eof
        #fi
        
        IP=`ip route get 114.114.114.114 | awk 'NR==1 {print $NF}'`
        echo $IP $HOSTNAME >>  /etc/hosts
        ;;

    [nN][oO]|[nN])
        echo "取消安装"
        ;;

    *)
        echo "无效输入，退出安装"
        exit 1
        ;;
esac