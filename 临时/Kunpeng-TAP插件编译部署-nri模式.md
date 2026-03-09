## NRI模式部署插件需要使用release-3.0版本

## 源代码仓库

```shell
git clone --branch kunpeng-tap-release-0.3.0-rc0  https://gitcode.com/boostkit/cloud-native.git
```

## 编译

> [!NOTE]
>
> 本环境为mac + Docker Desktop + vpn（没有的话要陪代理，好麻烦的。。）

1. 安装依赖

   ```shell
   yum install git wget make cmake -y 
   ```

2. 启动openEuler容器（需要挂载宿主机的套接字 /var/run/docker.sock ），并下载docker

   ```shell
   docker pull openeuler/openeuler:24.03-lts
   # 启动容器， 并挂载宿主机的套接字，来使用宿主机的daemon守护进程
   docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock openeuler/openeuler:24.03-lts
   yum install docker -y  # 下载docker客户端
   ```

3. 安装1.25.0版本golang

   ```shell
   wget https://dl.google.com/go/go1.25.0.linux-arm64.tar.gz
   rm -rf /usr/local/go && tar -C /usr/local -xzf go1.25.0.linux-arm64.tar.gz 
   export PATH=$PATH:/usr/local/go/bin
   
   # 安装完成
   [root@hostname-skiuw cloud-native]# go version
   go version go1.25.0 linux/arm64
   ```

4. 下载KP-TAP 代码

   ```shell
   git clone --branch kunpeng-tap-release-0.3.0-rc0  https://gitcode.com/boostkit/cloud-native.git
   ```

5. 进入**cloud-native**目录，并下载项目所需依赖

   ```shell
   cd cloud-native/
   go mod tidy 
   ```

6. 构建插件

   ```shell
   # 运行如下命令构建插件，构建后将在bin目录下生成二进制文件 kunpeng-tap
   make kunpeng-tap-build 
   
   # 对于NRI模式，还需要运行如下命令构建插件镜像
   make kunpeng-tap-build-nri
   # 构建后docker images 会有一个新的镜像 kunpeng-tap-nri
   [root@69363b8b7ebf cloud-native]# docker images 
   REPOSITORY                           TAG             IMAGE ID       CREATED         SIZE
   kunpeng-tap-nri                      latest          d26cc4077b2e   6 seconds ago   69.6MB
   ```


## 部署K8S集群

详情参考： 虚拟化的 K8S部署集群.md文件



## 验证KP-TAP nri模式部署

1. 修改config.toml 文件

   ```shell
   vim /etc/containerd/config.toml 
   
   # 添加 io.containerd.nri.v1.nri
     [plugins."io.containerd.nri.v1.nri"]
       disable = false
       disable_connections = false
       plugin_config_path = "/etc/nri/conf.d"
       plugin_path = "/opt/nri/plugins"
       plugin_registration_timeout = "5s"
       plugin_request_timeout = "2s"
       socket_path = "/var/run/nri/nri.sock"
   
   # 修改后如下：
   
   [plugins]
     [plugins."io.containerd.grpc.v1.cri"]
       sandbox_image = "sealos.hub:5000/pause:3.9"
       max_container_log_line_size = 16384
       max_concurrent_downloads = 20
       disable_apparmor = true
       [plugins."io.containerd.grpc.v1.cri".containerd]
         snapshotter = "overlayfs"
         default_runtime_name = "runc"
         [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
           [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
             runtime_type = "io.containerd.runc.v2"
             [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
               SystemdCgroup = true
           [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.crun]
             runtime_type = "io.containerd.runc.v2"
             [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.crun.options]
               BinaryName = "/usr/bin/crun"
               SystemdCgroup = true
       [plugins."io.containerd.grpc.v1.cri".registry]
         config_path = "/etc/containerd/certs.d"
         [plugins."io.containerd.grpc.v1.cri".registry.configs]
             [plugins."io.containerd.grpc.v1.cri".registry.configs."sealos.hub:5000".auth]
               username = "admin"
               password = "passw0rd"
     [plugins."io.containerd.nri.v1.nri"]
       disable = false
       disable_connections = false
       plugin_config_path = "/etc/nri/conf.d"
       plugin_path = "/opt/nri/plugins"
       plugin_registration_timeout = "5s"
       plugin_request_timeout = "2s"
       socket_path = "/var/run/nri/nri.sock"
   ```

   

2. 重启containerd

   ```shell
   systemctl daemon-reload
   systemctl restart containerd 
   systemctl status containerd 
   ```

3. js

   ```shell
   docker save kunpeng-tap-nri:latest  -o kunpeng-tap-latest.tar 
   ctr -n k8s.io images import kunpeng-tap-latest.tar 
   kubectl create namespace kunpeng-tap 
   cd cloud-native
   make kunpeng-tap-nri-deploy 
   [root@node1 cloud-native]# kubectl get pods -n kunpeng-tap -owide 
   NAME                    READY   STATUS    RESTARTS   AGE   IP          NODE    NOMINATED NODE   READINESS GATES
   kunpeng-tap-nri-tm5ct   1/1     Running   0          34s   10.0.1.50   node1   <none>           <none>
   ```

   

