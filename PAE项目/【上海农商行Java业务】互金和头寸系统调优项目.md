# 上海农商银行互联网金融平台&头寸系统Java应用优化



## 项目背景

客户要求ISV在26年3月13号完成互联网金融平台&头寸系统的性能测试，且性能达到intel的80-90%。当前未调优性能落后intel 25%-30%，要求PAE投入项目进行调优，达成客户目标。

ISV： 艾融软件

## 测试方案

多个业务接口分别进行单接口测试以及混合接口测试，选择最优的并发下的TPS进行性能比拼。针对单接口和混合接口进行测试，其中更看中混合接口测试的结果。

## 软硬件配置

| 类型             | Intel                   | kunpeng                                                      |
| ---------------- | ----------------------- | ------------------------------------------------------------ |
| 整机型号/CPU     | 2 * intel 5218 主频2.3  | 2 * 鲲鹏 5220  2.6GHz一个cpu一个numa                         |
| OS               | redhat 8.6/ kylinV10SP1 | KylinV10 SP3                                                 |
| 内存             | 16 * 32GB               | 12 * 64GB 最优内存插法 （后续拔下4个内存条，替换成8 * 64GB） |
| 网卡             | 10GE网卡                | TM210 GE板载网卡(后续替换成10GE独立网卡)                     |
| 磁盘             | 网络盘 NAS              | 网络盘 NAS                                                   |
| JDK              | openJDK 17              | openJDK 17                                                   |
| 虚拟化平台       | VMware ESXi 6.7         | WinServer 9.3.0（云宏平台研发说会比VMware性能差些）（查询下补丁） |
| 数据库跨机房问题 | 不存在                  | 存在                                                         |
| 其它             | -                       | SRIOV网卡直通、DPDK、绑核、虚机加核心监控系统：20250115版本，26W contract参数 |

## 组网架构（调整后的）

> [!NOTE]
>
> 组网差异点：鲲鹏的业务虚机和数据库不在同一个机房，但是Intel的业务虚机和数据库是在同一个机房，鲲鹏和Intel的Oracle数据库是同一套环境，部署在Intel机房中。

​	两个网关负责分发任务到业务JAVA进程，java进程涉及10个虚机，5种业务进程，每种业务进程放在2个虚机上（一个请求只要其中一个虚机进行处理）。一个业务接口只需要一个业务进程来执行，java应用之间不需要交互，但是应用需要和Oracle数据库进行交互。



鲲鹏和Intel虚拟机规模： 4C16GB

![image-20260313151756007](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260313151756007.png)

## 性能调优

### 测试组网分析

**鲲鹏**：鲲鹏互金的业务虚机（17个）都部署在一台物理机上，但是该物理机总共有43个虚机，该物理机上资源占比较高的是另一个业务部门的应用，非当前调优的业务。鲲鹏虚机vCPU 在这台物理机上占用了168个核心，超分比为1:3 （物理机只有64个核心）

**Intel**：17个虚机应用部署在5台x86物理机上。vCPU 超分比不知道多少。

结合鲲鹏和Intel之间的组网差异点，建议客户将Intel和鲲鹏的虚机都分别放到一台物理机上运行，拉奇环境配置后再做测试。



### 组网拉齐后

Intel和鲲鹏的虚机都分别放到一台物理机上运行，且只部署当前互金业务的虚机，其他业务都删除（intel还保留几个未删除）。此时鲲鹏的vCPU 超分比大约是1:1左右，但是性能上没有明显的变化。

**鲲鹏虚机**：

![image-20260313154329766](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260313154329766.png)

**Intel虚机**：

![image-20260313154411343](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260313154411343.png)



### 性能分析

1. collect信息收集： bash ./collect.sh -t 10 

   |           | 业务应用                    | 网关                       |
   | --------- | --------------------------- | -------------------------- |
   | CPU使用率 | 1.22-2.41个核心             | 1.49-2.82个核心            |
   | 内存      | 使用2.7GB，7GB的buff/cache  | 使用2GB，7.4GB的buff/cache |
   | 网络      | 收发1MB                     | 收发0.65MB，发2-3MB        |
   | 磁盘      | 读写基本为0 （0.1MB/s以下） | 0MB/s                      |

2. BMC一键收集日志：AppDump>BIOS>currentvalue.json

   可优化的的BIOS配置项

   - CustomPowerPolicy: Efficiency ; 
   - EnableSMMU : Disabled ; 

   - DdrRefreshRate : 32ms ;

3. 业务虚机到Oracle数据库的网络时延

   - 排查到鲲鹏服务器存在跨机房问题
   - 网卡型号存在差异：x86是万兆独立网卡、鲲鹏是千兆板载网卡

   | ping时延/ms                | 鲲鹏    | Intel   |
   | -------------------------- | ------- | ------- |
   | 业务虚机到Oracle数据库时延 | 0.444ms | 0.239ms |

   ![image-20260313171556264](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260313171556264.png)

4. 鲲鹏物理机内存插法：

   建议替换为8根内存，保证最优的内存带宽

   ![image-20260316145145517](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260316145145517.png)

5. topdown信息收集：

   ./kperf --hotfunc --topdown --cache --tlb --imix --uncore --duration 1 --interval 15 --pid <pid>

   - 前端瓶颈占比较高42.47%， 可以尝试PGO优化（**JDK17支持，但是具体不知道怎么做）**
   - Core Bound一般需要修改代码解决，当前业务不支持
   - mem bound10.94% ，可以考虑开大页内存和预取
   - TLB miss率也比较高，考虑开大页内存 (TODO：待确定)

   后续增加了JVM透明大页参数： -XX:+UseTransparentHugePages （头寸系统混压提升3.9%）

   ![image-20260316142538973](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260316142538973.png)

   ![image-20260316142552344](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260316142552344.png)

6. JVM参数配置：ps -ef | grep java

   G1GC可以考虑调大初始堆和最大堆的大小，且配置成相同的大小，避免内存不足时，再进行扩内存操作，影响业务性能。

   ![image-20260313172207123](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260313172207123.png)

7. GC日志收集： （日志一般放在-Xlog:gc*.gc  或者增加参数-Xlog:gc*:file=/opt/app/logs/gc.log

   TODO：待分析 

   ![image-20260316142426498](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260316142426498.png)

8. GC时延分析：

   GC时延都在10ms内，性能不差

   - 鲲鹏

     - 应用：9.814ms

     - 网关：6.959ms

       ![image-20260316142319858](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260316142319858.png)

   - intel

     - 应用：12.38ms
     - 网关：2.831ms

9. java火焰图采集：./asprof -d 30 -f flamegraph.html <PID>  

   和Intel未见明显区别以及可优化的点

   ![image-20260313172444591](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260313172444591.png)

10. 其它未排查的点：

   - 虚机的网络模式是什么（网桥模式？）
   - 虚机配置的网络带宽有限制吗
   - 业务端到端时延（应用侧和数据库时延分别占比多少）



以下测试数据非标准的单接口和混合压测，仅为反洗钱交易接口测试数据

| 调优措施                                         | TPS性能 | 提升比（相对鲲鹏基线） | 备注                   | 是否上线 |
| ------------------------------------------------ | ------- | ---------------------- | ---------------------- | -------- |
| Intel基线                                        | 1000    |                        |                        | -        |
| 鲲鹏基线（最优并发反洗钱接口性能）               | 800     |                        |                        | -        |
| OpenJDK 17替换为BishengJDK 17                    |         | 无提升                 |                        | 否       |
| BIOS（性能模式+内存刷新率Auto+SMMU开启）         |         | 小幅度的提升           |                        | 是       |
| JVM参数（透明大页开启+ -Xms8192m -Xmx8192m）     | 825     | 3%                     |                        | 是       |
| 替换独立网卡+使用8根内存（保证最大内存频率）     | 830-880 | 0.75%-7%               | 大概率是网络波动的影响 | 是       |
| 虚拟机绑核（只绑核反洗钱相关的两个业务Java虚机） |         | 性能下降               |                        | 否       |



## 调优结果

**互金**：8大业务接口单交易负载测试场景，性能提升19.37%，性能落后Intel 15%；混合压测场景，调优后性能提升10.96%，落后Intel 17.57%

**头寸**：5大业务接口平均落后Intel 25.6%；混合压测场景，调优后落后Intel 16.65%



## 头寸SO库缺失问题定位

### 报错信息

Jnidispatch (com/sun/jna/linux-aarch64/libjnidispatch.so) not found in resource path

![image-20260316155016666](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260316155016666.png)

### 问题分析

1. intel和鲲鹏都找不到这个so库，但是Intel不报错。

2. 查询到头寸代码里maven有引入jna，且业务jar包中包含jna的jar包。

   ![image-20260316160606033](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260316160606033.png)	![image-20260316154813967](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260316154813967.png)

3. 查看到jna代码仓https://github.com/java-native-access/jna 中包含这个so文件，但是ISV的版本不包含arm版本的so库，导致报错。

4. 建议ISV重新打包这个jna jar包后验证。 （待有机器后验证）

   ```shell
   # 1. 在一个空目录解压    unzip jna-5.18.1.jar  -d ./
   # 2. cd com/sun/jna/
   # 3. mkdir linux-aarch64
   # 4. 把arm版本的libjnidispatch.so放到linux-aarch64目录下
   # 5. cd 到有com和META-INF的目录下
   # 6. jar cvfm jna-1.0.0.jar META-INF/MANIFEST.MF .
   # 7. 然后把生成的新 jna-1.0.0.jar， 放到idea项目下原来的 jna-1.0.0.jar位置，重新打包msp-basis 运行即可
   ```

   

## 附录：云宏平台支持特性

1. 支持虚拟机绑核（已验证）
2. 支持DPDK
3. 支持SRIOV网卡直通
4. 云宏9.3版本 支持KAE