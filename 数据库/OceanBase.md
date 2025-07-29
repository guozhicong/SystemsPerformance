# OceanBase

## 安装部署

### 商业版本

1. 关闭防火墙

   ```shell
   [root@hostname-0ptoe oat-all-in-one-arm]#  systemctl disable firewalld
   Removed "/etc/systemd/system/multi-user.target.wants/firewalld.service".
   Removed "/etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service".
   [root@hostname-0ptoe oat-all-in-one-arm]#  systemctl stop  firewalld
   ```

   

2. 下载oat包并上传至服务器上并解压，解压后进入oat-all-in-one-arm目录

   ```shell
   [root@hostname-0ptoe home]# tar -xvf oat-all-in-one-arm.tar
   [root@hostname-0ptoe home]# cd oat-all-in-one-arm
   ```

3. 执行sh install.sh 

   ```shell
   [root@hostname-0ptoe oat-all-in-one-arm]# sh install.sh 
   Before installation, please set the config below:
   Input the docker root dir: /home/docker
   df: /home/docker: No such file or directory
   Docker home dir /home/docker avail space less than 60GB, change to larger disk is recommended. Continue install anyway (y/n)? ^C
   [root@hostname-0ptoe oat-all-in-one-arm]# sh install.sh 
   Before installation, please set the config below:
   Input the docker root dir: /home/docker
   df: /home/docker: No such file or directory
   Docker home dir /home/docker avail space less than 60GB, change to larger disk is recommended. Continue install anyway (y/n)? y
   Input the OAT data dir: /home/oat_data
   Input the OAT HTTP listen port: 7000
   Input the OAT database port: 3306
   
   ...
   
   OAT API not ready, sleep 5s retry...
   curl: (7) Failed to connect to 127.0.0.1 port 7000 after 0 ms: Couldn't connect to server
   OAT API not ready, sleep 5s retry...
   curl: (7) Failed to connect to 127.0.0.1 port 7000 after 0 ms: Couldn't connect to server
   OAT API not ready, sleep 5s retry...
   OAT API ready
   Copy images and binary_packages to OAT data dir
   Trigger OAT scan api to find images and binary_packages
   Trigger scan task success, please visit OAT web site and wait for scan task finished
   Device "101
   102" does not exist.
   OAT is ready for visit
   url is: http://<current_ip>:7000
   user/password is: admin/aaAA11__   #修改密码为Huawei12#$
   ```

3. 浏览器打开http://175.11.22.4:7000

   ![image-20250726101926383](/Users/guozhicong/Library/Application Support/typora-user-images/image-20250726101926383.png)

4. 

### 社区版本

