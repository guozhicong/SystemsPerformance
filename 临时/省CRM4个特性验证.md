## waas



### 安装

在所有的CRM业务计算节点执行（需要root 权限）

1. rpm -ivh --nodeps waasbooster-1.0.0-1.aarch64.rpm   # 如果没加--nodeps，则会报错没有python；（添加--nodeps接口）
2. systemctl start waasbooster
3. 查看/var/log/waasbooster.log 大量的update pod XXX ...  quota: 81000.0 即为生效



### 卸载

1. systemctl stop waasbooster
2. rpm -e waasbooster-1.0.0-1



## NUMA亲和插件



### 安装

参考： https://www.hikunpeng.com/document/detail/zh/kunpengcpfs/basicAccelFeatures/comAccel/kunpengkp_tap_04_002.html

1. 在所有的计算节点执行

2. 在文件/etc/kubernetes/kubelet 中添加参数： --docker-endpoint=unix:///var/run/kunpeng/tap-runtime-proxy.sock

3. ./kunpeng-tap

4. ```shell
   systemctl daemon-reload
   systemctl restart kubelet
   systemctl status kubelet
   ```

5. systemctl status kunpeng-tap

6. 重启pod

### 卸载

1. 删除参数：  --docker-endpoint=unix:///var/run/kunpeng/tap-runtime-proxy.sock

2. 重启kubelet

   ```shell
   systemctl daemon-reload
   systemctl restart kubelet
   systemctl status kubelet
   ```

3. 在计算节点上，进入“topology-affinity-plugin”源码目录，并执行插件卸载命令。

   ```shel
   cd /path/to/topology-affinity-plugin
   make uninstall-service
   ```

4. 查看插件是否已成功删除。

   ```shell
   # systemctl status kunpeng-tap
   Unit kunpeng-tap.service could not be found.
   ```

   如果卸载成功，将看到“Unit kunpeng-tap.service could not be found.”。

5. 重启pod



## JDK Fusion



### 安装

下载JDK Fusion（毕昇融合JDK） https://www.hikunpeng.com/zh/developer/devkit/download/jdk

并替换原来的JDK 8即可，启动java应用时可能需要对java启动参数做调整

### 卸载

替换为原来的JDK 8即可
