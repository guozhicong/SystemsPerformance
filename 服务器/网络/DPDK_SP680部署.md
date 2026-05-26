参考指南： https://support.huawei.com/enterprise/zh/doc/EDOC1100309168/f659ab37#ZH-CN_TOPIC_0000001839829760

# DPDK在SP680网卡上部署

## 环境配置

| 服务器型号 | 920B                                                         |
| ---------- | ------------------------------------------------------------ |
| CPU        | Kunpeng 920 7270Z                                            |
| 网卡       | SP680 25GE网卡/SP670 100GE网卡（注意100GE网卡需要确认光模块和路由器支持100G） |
| OS         | openEuler 22.03 (LTS-SP4)                                    |
| dpdk       | 22.11.11                                                     |
|            |                                                              |
|            |                                                              |

## 依赖的文件链接

DPDK： https://core.dpdk.org/download/

DPDK SP680驱动包： https://support.huawei.com/enterprise/zh/huawei-computing-components/in220-pid-253287505/software/265425005?idAbsPath=fixnode01|23710424|251364417|9856629|253287505



## DPDK 部署

1. 依赖安装

   ```shell
   yum install -y libatomic python3-devel meson ninja-build python3-pyelftools libibverbs numactl-devel tar gcc clang 
   ```

2. 编译安装dpdk

   ```shell
   
   # 根据 https://core.dpdk.org/download/ 下载22.11.11版本
   tar -xvf dpdk-22.11.11.tar.xz 
   cd dpdk-stable-22.11.11/
   meson build -Ddisable_drivers=net/cnxk,net/mlx4,net/mlx5,common/mlx5,regex/mlx5,vdpa/mlx5,crypto/* -Ddefault_library=shared
   ninja -C build
   ninja install -C build
   # 工具会安装到“/usr/local/bin/”目录中；动态库会安装到“/usr/local/lib64”中
   
   ```

3. 安装dpdk驱动包

   ```shell
   # 根据https://support.huawei.com/enterprise/zh/huawei-computing-components/in220-pid-253287505/software/265425005?idAbsPath=fixnode01|23710424|251364417|9856629|253287505 下载DPDK SP680驱动包
   
   tar -xvf DPDK_2211_arm-17.12.5.0.tar.gz 
   cd DPDK_2211_arm-17.12.5.0
   rpm -Uvh dpdk-sp600-pmd-22.11-17.12.5.0.aarch64.rpm  --force --nodeps
   rpm -ql dpdk-sp600-pmd-22.11-17.12.5.0.aarch64.rpm 
   ```

4. 配置大页内存

   ```shell
   # 查询当前网卡配置模板是否为NIC模板
   [root@localhost aarch64]# ./hinicadm3 info 
   Card num:2
   Device Information:
        Card         PCIe Function
   |----hinic0(CAL_4X25G)
            |--------0000:17:00.0(NIC:enp23s0f0)
            |--------0000:17:00.1(NIC:enp23s0f1)
            |--------0000:17:00.2(NIC:enp23s0f2)
            |--------0000:17:00.3(NIC:enp23s0f3)
   |----hinic1(CAL_4X25G)
            |--------0000:96:00.0(NIC:enp150s0f0)
            |--------0000:96:00.1(NIC:enp150s0f1)
            |--------0000:96:00.2(NIC:enp150s0f2)
            |--------0000:96:00.3(NIC:enp150s0f3)
   [root@localhost aarch64]# ./hinicadm3 cfg_template -i hinic0 -q
   ***************** Current Info *******************
   [Current   ] Cfg template index :  0
   ***************** Next Reset Cfg *****************
   [Next Reset] Max support index  :  2
   [Next Reset] Cfg template index :  0
   [Next Reset] Firmware support cfg template name:
                Template[ 0]: NIC_4X25G
                Template[ 1]: NIC_4X25G_5PF_120VF
                Template[ 2]: NIC_4X25G_8PF
   # 禁用透明大页
   echo never > /sys/kernel/mm/transparent_hugepage/enabled
   # 配置大页内存
   vim /etc/grub2-efi.cfg
   # linux行末尾添加default_hugepagesz=1G hugepagesz=1G hugepages=64 iommu.passthrough=1
   # 保存文件后重启服务器
   # 执行cat /proc/cmdline命令查看内核命令行配置是否生效
   
   # 查看配置结果
   dpdk-hugepages.py -s
   cat /proc/meminfo | grep Huge
   ```

5. 加载VFIO驱动

   ```shell
   # vfio-pci是通过VFIO（Virtual Function I/O）框架，允许应用程序直接访问PCI设备的硬件加速驱动。
   # 执行以下命令加载vfio-pci驱动，无回显表示执行成功
   modprobe vfio enable_unsafe_noiommu_mode=1
   echo 1 > /sys/module/vfio/parameters/enable_unsafe_noiommu_mode
   modprobe vfio-pci
   ```

   

6. 配置DPDK

   ```shell
   # 执行如下命令查询当前网络设备基本信息
   ./hinicadm3 info
   # 执行如下命令绑定网络设备到DPDK用户态驱动
   dpdk-devbind.py -b vfio-pci 0000:c1:00.0
   ```

   

7. 启动testpmd

   > [!IMPORTANT]
   >
   > 1. 接收端如果只配置rxd和txd为1024，在100G网卡测试环境上压测，接收端只能到80-90G左右，无法打满。需要配置为2048才行
   > 2. 

   

   ```shell
   dpdk-testpmd -d librte_net_sp600.so -l 10-31 -a 0000:01:00.0 -- --nb-cores=8 --rxq=8 --txq=8 --rxd=1024 --txd=1024 -i
   ```

   测试命令：发送端

   ![image-20260413105931983](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260413105931983.png)

   接收端

   ![image-20260420140815559](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260420140815559.png)

8. 

   

## FAQ 

- 执行dpdk-devbind.py -b vfio-pci 0000:c1:00.0 报错Warning: routing table indicates that interface 0000:c1:00.0 is active. Not modifying

  ![image-20260413100708900](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260413100708900.png)

  解决方法：ip link set down enp193s0f0

- 执行**dpdk-testpmd -d librte_net_sp600.so -l** *10-31* **-a 0000:01:00.0 -- --nb-cores=8 --rxq=8 --txq=8 --rxd=1024 --txd=1024 -i**报错 error while loading shared libraries: librate_ethdev.so.23: cannnot open shared object file: No such file or directory

  ![image-20260413102921200](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260413102921200.png)

  解决方法：export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH

- testpmd压测 TX-errors持续增加，且对端收不到任何包

  ![image-20260420112037416](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260420112037416.png)

  ![image-20260420112050958](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260420112050958.png)

  解决方法：接收端增加两个参数 --auto-start --stats-period 3

  ![image-20260420140712473](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260420140712473.png)





## DPDK SP680网卡驱动



https://support.huawei.com/enterprise/zh/huawei-computing-components/in220-pid-253287505/software/265425005?idAbsPath=fixnode01|23710424|251364417|9856629|253287505

