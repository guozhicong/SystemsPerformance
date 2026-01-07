> [!NOTE]
>
> 确保当前环境为干净的环境，不要自己装docker
>
> 通过Sealos安装部署K8S集群： https://sealos.run/docs/k8s/quick-start/deploy-kubernetes

# K8S使用



## K8S集群部署

1. 配置hostname

   ```shell
   # 准备一个master节点，一个/多个node节点，分别配置hostname
   hostname master
   hostname node1
   
   # 或者通过修改vim /etc/hostname后重启服务器，永久配置hostname
   ```

2. 配置是时钟同步

   ```shell
   # 所有节点都需要配置时钟同步
   yum install ntpdate tar -y
   ntpdate ntp.aliyun.com 
   ```

3. 根据 [Sealos命令行工具](https://sealos.run/docs/k8s/quick-start/install-cli) 进行安装

   ```shell
   yum install sealos_5.1.2-rc3_linux_arm64.rpm -y 
   ```

4. 安装K8S集群

   ```shell
   sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes:v1.29.9 registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4 registry.cn-shanghai.aliyuncs.com/labring/cilium:v1.13.4 \
        --masters 193.133.1.2 \
        --nodes 193.133.1.4 -p Huawei12#$
   ```

   回显如下表示安装成功

   ![image-20260103232756881](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260103232756881.png)

5. kubectl get nodes

   ```shell
   [root@master k8s]# kubectl get nodes
   NAME     STATUS   ROLES           AGE   VERSION
   master   Ready    control-plane   43s   v1.29.9
   node1    Ready    <none>          21s   v1.29.9
   ```



## 业务POD部署

1. 在node节点拉取docker镜像

   ```shell
   # https://1ms.run/   镜像可以在这个网站搜索来拉取
   docker pull docker.1ms.run/library/nginx:latest
   
   [root@node1 ~]# docker images 
   REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
   docker.1ms.run/library/nginx   latest              759581db3b0c        6 days ago          172MB
   ```

2. 将docker镜像放到crictl中

   ```shell
   docker save -o mynginx.tar docker.1ms.run/library/nginx:latest
   ctr -n k8s.io images import mynginx.tar
   
   [root@node1 ~]# crictl images
   IMAGE                             TAG                 IMAGE ID            SIZE
   docker.1ms.run/library/nginx      latest              759581db3b0c2       176MB
   sealos.hub:5000/cilium/cilium     v1.13.4             14515a7951cd7       164MB
   sealos.hub:5000/cilium/operator   v1.13.4             aa69f21a33233       28.2MB
   sealos.hub:5000/kube-proxy        v1.29.9             0e8a375be0a8e       25.3MB
   sealos.hub:5000/labring/lvscare   v5.0.1              ecdaca13c3b3d       13.1MB
   sealos.hub:5000/pause             3.9                 829e9de338bd5       266kB
   [root@node1 ~]# 
   ```

3. 填写pod.yaml文件

   ```shell
   apiVersion: v1
   kind: Pod
   metadata:
     # Pod 名称，自定义
     name: nginx-resource-pod
     # 命名空间，默认 default，可自定义
     namespace: default
   spec:
     # 容器列表，一个 Pod 可以有多个容器
     containers:
     - name: nginx-container
       # 容器镜像
       image: docker.1ms.run/library/nginx:latest
       imagePullPolicy: Never
       # 资源配置：requests（最小需求）和 limits（最大限制）
       resources:
         requests:
           # CPU 请求：200毫核（0.2核）
           cpu: "8000m"
           # 内存请求：256兆字节
           memory: "512Mi"
         limits:
           # CPU 限制：500毫核（0.5核）
           cpu: "16000m"
           # 内存限制：512兆字节
           memory: "512Mi"
     # 重启策略：Never（一次性 Pod）/ Always / OnFailure
     restartPolicy: Never
   ```

4. 启动部署

   ```shell
   kubectl apply -f pod.yaml 
   
   # 查看部署的pod
   [root@master k8s]# kubectl get pods
   NAME                 READY   STATUS    RESTARTS   AGE
   nginx-resource-pod   1/1     Running   0          5s
   
   # 删除pod
   kubectl delete pod nginx-resource-pod 
   ```



## NUMA插件使用

1. 插件编译涉及的GO语言安装使用

   - [GO 安装](https://go.dev/doc/install)
   - [GO 更换依赖源](https://blog.csdn.net/qq_35204012/article/details/136898543)

2. 在所有的node计算节点进行部署

   **参考word部署指导**或者[社区部署指导](https://www.hikunpeng.com/document/detail/zh/kunpengcpfs/basicAccelFeatures/comAccel/kunpengkp_tap_04_009.html)

3. 注意Sealos部署集群的方式需要修改以下两个配置文件才能生效

   ```shell
   vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
   vi /var/lib/kubelet/kubeadm-flags.env
   ```



## FAQ 

1. 执行sealos run XXX 报错Error: cluster status is not ClusterSuccess

   ```shell
   # 清理K8S集群后重新安装
   sealos reset 
   ```

2. 执行sealos run XXX 报错init-containerd.sh: line 21: tar: command not found

   注意不一定是master节点缺少tar解压工具，node节点缺少tar也会报错（草。。）

   yum install tar -y

