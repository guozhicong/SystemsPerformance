> [!NOTE]
>
> 记录一些网络相关的FAQ，主要包含一些基本的问题定位和解决方法

## 1. 更换OS内核后，网卡驱动无法识别

### 现象

iBMC 上存在SP380网卡，且网口状态为正常； 但是命令中查看不到对应的网口（ip a查寻不到）



### 解决方法

1. 根据[华为support网站](https://support.huawei.com/enterprise/zh/doc/EDOC1100056515/d8cca655 )下载EulerOS V2R10对应的驱动包进行安装，发现始终无法安装上驱动，报错系统不匹配，因为当前环境使用的OS为EulerOS V2R12

   

2. 参考[Mellanox网卡驱动安装指南](https://www.kontronn.com/network/install-linux-device-driver-for-mellanox-network-adapter/) 下载Mellanox对应的OS版本驱动，驱动可以正确安装，但是重启后驱动还是加载失败

   ```shell
   # 如果执行./mlnxofedinstall报错不支持该操作系统则执行
   ./mlnxofedinstall --add-kernel-support
   ```


3. dmesg查询开机信息

   ```shell
   mlx5_core 0000:85:00.1: wait_fw_init:(pid 701): Firmware over 120000 MS in pre-initializing state, aborting
   mlx5_core 0000:85:00.1: probe_one:2494:(pid 701) : mlx5_init_one failed with error code -110
   ```

4. Firmware 固件升级

   [SP380 固件链接](https://support.huawei.com/enterprise/zh/management-software/computing-component-idriver-pid-259488843/software/262409139?idAbsPath=fixnode01|23710424|251364417|251364851|254884035|259488843)

   ![img.png](img.png)
   ```shell
   ./install.sh upgrade
   ```

   

5. ifup eth4 出现 RTNTETLINK answers： File exists

   执行ip adds flush dev eth4





## 2. 查看驱动是否正确加载

```shell
# 查看businfo
lspci -vvv | grep Eth 
# 查看网卡驱动
lspci -k

# 回显结果如下
85:00.0
	kernel drive in use: mlxs_core # 如果这行没有，就是没有驱动
	kernel modules: mlxs_core # 没有驱动，这行还是会显示
```

