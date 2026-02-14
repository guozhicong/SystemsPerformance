## 问题描述

不定时，不限设备，都有NodeManager节点可能掉线。NodeManager进程没被kill，只是ResourceManager连接不上NodeManager。

重启NodeManager后，能正常连接ResourceManager，服务恢复正常状态。

![image-20260204163208031](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260204163208031.png)

hadoop版本 2.6.0    CDH 5.16.1

![image-20260205155311498](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260205155311498.png)

## 定位

1. 日志分析

   RM节点日志：hadoop-cmf-yarn-RESOURCEMANAGER-cdh3-dn-68.log.out.5

   ```shell
   2026-01-30 03:29:57,125 INFO org.apache.hadoop.yarn.util.AbstractLivelinessMonitor: Expired:cdh3-dn-83:8041 Timed out after 600 secs
   2026-01-30 03:29:57,125 INFO org.apache.hadoop.yarn.server.resourcemanager.rmnode.RMNodeImpl: Deactivating Node cdh3-dn-83:8041 as it is now LOST
   2026-01-30 03:29:57,126 INFO org.apache.hadoop.yarn.server.resourcemanager.rmnode.RMNodeImpl: cdh3-dn-83:8041 Node Transitioned from RUNNING to LOST
   2026-01-30 03:29:57,127 INFO org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler: Removed node cdh3-dn-83:8041 cluster capacity: <memory:33331200, vCores:8080>
   ```

   

   ![image-20260204163455562](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260204163455562.png)

   心跳超时了，大于600秒的时间限制了。所以RM把这个NM删除了

2. yarn-site.xml 配置文件

   

   ```xml
   <!-- 需要确认影响，是否需要修改 -->
   		<property>
   		<name>yarn.resourcemanager.container.liveness-monitor.interval-ms</name>
       <value>600000</value>
     </property>
   <!-- NM向RM心跳间隔，默认1秒，调大到2秒 -->
     <property>
       <name>yarn.resourcemanager.nm.liveness-monitor.interval-ms</name>
       <value>1000</value>
     </property>
   <!-- RM判定NM心跳超时时间，默认10分钟，调大到20分钟 -->
     <property>
       <name>yarn.nm.liveness-monitor.expiry-interval-ms</name>
       <value>600000</value>
     </property>
   ```

3. 单个容器卡死了？

   ```shell
   2026-01-30 03:57:01,459 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 2846344 for container-id container_e34_1766739190543_177928_01_001963: 5.8 GB of 8 GB physical memory used; 8.9 GB of 16.8 GB virtual memory used
   2026-01-30 03:57:04,504 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 2846344 for container-id container_e34_1766739190543_177928_01_001963: 5.8 GB of 8 GB physical memory used; 8.9 GB of 16.8 GB virtual memory used
   2026-01-30 03:57:07,549 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 2846344 for container-id container_e34_1766739190543_177928_01_001963: 5.8 GB of 8 GB physical memory used; 8.9 GB of 16.8 GB virtual memory used
   2026-01-30 03:57:10,594 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 2846344 for container-id container_e34_1766739190543_177928_01_001963: 5.8 GB of 8 GB physical memory used; 8.9 GB of 16.8 GB virtual memory used
   2026-01-30 03:57:13,638 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 2846344 for container-id container_e34_1766739190543_177928_01_001963: 5.8 GB of 8 GB physical memory used; 8.9 GB of 16.8 GB virtual memory used
   2026-01-30 03:57:16,683 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 2846344 for container-id container_e34_1766739190543_177928_01_001963: 5.8 GB of 8 GB physical memory used; 8.9 GB of 16.8 GB virtual memory used
   2026-01-30 03:57:19,727 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 2846344 for container-id container_e34_1766739190543_177928_01_001963: 5.8 GB of 8 GB physical memory used; 8.9 GB of 16.8 GB virtual memory used
   2026-01-30 03:57:22,769 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 2846344 for container-id container_e34_1766739190543_177928_01_001963: 5.8 GB of 8 GB physical memory used; 8.9 GB of 16.8 GB virtual memory used
   ```

   

4. 下一步计划

   ```shell
   # 查一下8041端口能正常连接吗
   netstat -antp | grep 8041
   # 1. ping测试网络层连通（先确认IP通）
   ping cdh3-dn-83 -c 10
   # 2. telnet测试8041端口连通（核心！不通直接定位网络问题）
   telnet cdh3-dn-83 8041
   # 3. 无telnet用nc命令（CDH/鲲鹏Linux原生支持）
   nc -zv cdh3-dn-83 8041
   # 4. 检查RM节点到NM节点的防火墙规则
   traceroute cdh3-dn-83
   mtr cdh3-dn-83  # 更精准的链路丢包测试
   
   
   # 步骤1：在cdh3-dn-83节点确认8041端口监听
   ss -tulpn | grep 8041 # 显示LISTEN即为正常
   # 步骤2：在RM节点测试8041端口连通
   nc -zv cdh3-dn-83 8041 # 显示succeeded!即为正常
   # 步骤3：查看RM上NM的状态，确认未被标记为Expired/LOST
   yarn node -list | grep cdh3-dn-83 # 显示RUNNING即为正常
   # CDH集群可在CM界面查看：YARN → 节点 → cdh3-dn-83状态为正常
   
   
   1. 查容器业务日志（最核心，定位程序问题）
   容器日志默认在 NM 本地目录 / 聚合到 HDFS，优先查看僵死前的报错：
   bash
   # 方式1：NM本地容器日志（路径含container ID）
   cd $HADOOP_HOME/yarn/local/usercache/用户名/appcache/应用ID/container_xxxx/
   cat stderr log stdout log
   # 方式2：HDFS聚合日志（生产推荐）
   hdfs dfs -cat /tmp/logs/用户名/application_xxxx/container_xxxx/stderr
   重点排查关键字：OutOfMemoryError、Deadlock、IO Exception、Connection timeout、无限循环相关业务报错。
   
   
   # yarn-site.xml 每个节点的配置是否一致？ NM和RM配置是否一致？
   
   # 
   ```

5. 第二天再次复现问题：

   ![image-20260205144250475](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260205144250475.png)

   RM节点可以连通断链的NM节点：

   ![image-20260205144323897](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260205144323897.png)

   断连的NM节点8041端口是开放的

   ![image-20260205144345853](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260205144345853.png)

   6. 继续定位

      ```shell
      # 1. 检查Hadoop版本（与服务端版本对比）
      hadoop version
      
      # yarn-site.xml 每个节点的配置是否一致？ NM和RM配置是否一致？  
      检查了配置都是一样的
      core-site.xml yarn-site.xml hdfs-site.xml
      
      
      ps aux | grep D | grep -E "java|yarn|container"
      
      ```

      