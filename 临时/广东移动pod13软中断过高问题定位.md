## 缺少的图片

1. sysbench压测脚本
2. 145的bios配置\ top命令显示cpu占比高的函数
3. 



## 测试场景

sysbench： 800并发/10W记录/256表

Pod13 有问题的场景： 241 连接240proxy压测 240和242的observer

佛山无问题的场景： 132 连接145proxy压测 145和XXX的observer

## 现象

### 240问题机器现象：

![8ffe9e3547204131a9fcf811fb3c05c9](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/8ffe9e3547204131a9fcf811fb3c05c9.jpg)

![470a262e0a268f4124057ea253de08bf](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/470a262e0a268f4124057ea253de08bf.jpg)

![](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/e524476b4ff404b1891477c97407a1ce.jpg)

![4b90e6d11ec2bd4e3f309ae47e28fb6b](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/e19bab21ad6de094fcdb183f3dc23f45/4b90e6d11ec2bd4e3f309ae47e28fb6b.jpg)

![1c24bc3df9f168b930af1f25d8d124dc](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/e19bab21ad6de094fcdb183f3dc23f45/1c24bc3df9f168b930af1f25d8d124dc.jpg)

### 145佛山无问题节点

![ec8b3c7b935c0c59c89382a72ca8d317](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/e19bab21ad6de094fcdb183f3dc23f45/ec8b3c7b935c0c59c89382a72ca8d317.jpg)



![c917c0c675077012e0b3fd4f6e51fbd7](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/e19bab21ad6de094fcdb183f3dc23f45/c917c0c675077012e0b3fd4f6e51fbd7.jpg)

![5f18bdac2ff4462319a690d399471bdf](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/5f18bdac2ff4462319a690d399471bdf.jpg)

![b82584e893bd79577c63812177d596dd](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/e19bab21ad6de094fcdb183f3dc23f45/b82584e893bd79577c63812177d596dd.jpg)

## 环境配置

|              | 240                                            | 226                  | 145                                            |      |
| ------------ | ---------------------------------------------- | -------------------- | ---------------------------------------------- | ---- |
| OS           | BCLinux 21.10U3 LTS（4.19.90-2107.6.0.0192.8） |                      | BCLinux 21.10U3 LTS（4.19.90-2107.6.0.0192.8） |      |
| CPU          | 4 * 7260                                       |                      |                                                |      |
| 网卡         | SP681 2*25GE                                   | Netswift RP1000P2SFP |                                                |      |
| 网卡驱动版本 | hinic3 17.6.9.2                                |                      | Mlx5_core 5.0-0                                |      |
| 网卡固件版本 | 15.19.2.10                                     |                      | 14.31.1014                                     |      |
| 中断         | 24个核心 几乎都100%                            |                      |                                                |      |
|              |                                                |                      |                                                |      |
|              |                                                |                      |                                                |      |
|              |                                                |                      |                                                |      |



## 定位

### BIOS配置比对

​	问题机器和佛山145的关键差异在于PxeRetry的配置，修改240、241、242三台设备的PxeRetry为1，并修改了240一台设备的PCIeSRIOVSupport为Enabled，均无变化

241 

![5456a56845ed1bd3a180d371db7577ab](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/5456a56845ed1bd3a180d371db7577ab.jpg)

246

![6580ca09edc7e22afee7ab89fb7fad8e](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/6580ca09edc7e22afee7ab89fb7fad8e.jpg)

### 网络参数对比

![2db29ace96a2dcbaca210450cfc0e119](/Users/guozhicong/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_1r8mkl1365m521_e7a8/temp/RWTemp/2025-08/0c8f4bf7d16ac4187c960898c6beb296/2db29ace96a2dcbaca210450cfc0e119.png)



### perf top函数差异点

![image-20250826203938834](../png/image-20250826203938834.png)



使用bash ./collect.sh -t 10 收集系统侧火焰图以及添加-p参数收集proxy进程火焰图，查看spin_lock的调用函数

异常节点240 ip_local_out函数调用了nf_hook_slow函数，去获取spin_lock锁了，不清楚阻塞在哪里？

![image-20250827104555761](../png/image-20250827104555761.png)
