## 遗留问题
- TLB和页表的关系？页表是做虚拟地址到物理地址映射的（完整的映射关系）；TLB为CPU内部的高速缓冲，只缓冲部分映射关系。
- perf record 和 perf report的使用 (加不加-g参数的差异) : 如何查看调用关系

## uptime 平均负载解释

system load averages for the past 1, 5, and 15 minutes. 
（指单位时间内，系统处于可运行状态和不可中断状态的平均进程数。
**当执行stress -c 48后，load average会变成48左右**

> 平均负载的值如果超过逻辑cpu核数的70%， 一般是认为系统负载较高的
- 可运行状态：正在使用cpu或正在等待cpu的状态
- 不可中断状态：处于内核态关键流程中，比如等待硬件设备的I/O响应等


```shell
# uptime
 11:28:09 up 3 days,  8:24,  2 users,  load average: 47.99, 47.99, 48.00
```

### 平均负载相关命令（主要跟CPU相关）
```shell
[root@hostname-zb9ta ~]# watch -d uptime  # -d表示高亮变化的数值 （uptime会一只执行）
[root@hostname-zb9ta ~]# mpstat -P ALL 5 1 # 监控所有cpu，间隔5秒输出一次
Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
Average:     all    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:       0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:       1    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:       2    0.00    0.00    0.20    0.00    0.00    0.00    0.00    0.00    0.00   99.80
Average:       3    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00

[root@hostname-zb9ta ~]# mpstat -P 0-2    # 监控0-2 的cpu core

[root@hostname-zb9ta ~]# pidstat -u 5 1   # 间隔5秒后输出一组数据
# pidstat 的 %wait不是iowait，而是进程等待cpu的时间
Average:      UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
Average:        0     45491   41.94    0.00    0.00   57.09   41.94     -  stress
```

> 思考
>> 1. 负载高不一定cpu使用率高，比如在io密集型任务中，CPU使用率低，但是iowait和负载都高
>> 2. 进程等待cpu可以通过pidstat -u 5 1的%wait来查询, top看不出来 


## 上下文切换 （几十纳秒到数微妙）
就是上一个任务的CPU上下文（寄存器和程序计数器）保存，然后加载新任务的上下文的寄存器和程序计数器的过程

- 进程上下文切换：需要保存虚拟内存、栈、全局变量等用户空间，还要保存内核堆栈、寄存器等内核空间。
- 线程上下文切换（同一进程）： 只需要切换线程的私有数据、寄存器等不共享的数据。
- 中断上下文切换：中断上下文切换不涉及进程的用户态，只切换内核态的堆栈、寄存器、硬件中断参数等。因为只需要中断服务程序所必需的状态即可。

### 查询上下文切换相关命令
```shell
[root@hostname-zb9ta ~]# vmstat -w 5
# cs (context switch) 每秒上下文切换次数
# in 每秒中断次数
# r （正在运行的和等待CPU的进程数）
# b 不可中断睡眠的进程数


# 使用了stress -c 200
--procs-- -----------------------memory---------------------- ---swap-- -----io---- -system-- ----------cpu----------
   r    b         swpd         free         buff        cache   si   so    bi    bo   in   cs  us  sy  id  wa  st  gu
   1    0            0    258866464       110152      1967500    0    0     6     1    5    5   1   0  99   0   0   0
   1    0            0    258866608       110152      1967500    0    0     0     3  192  322   0   0 100   0   0   0
   1    0            0    258866608       110152      1967500    0    0     0     0  175  313   0   0 100   0   0   0
   1    0            0    258866608       110152      1967500    0    0     0     0  204  356   0   0 100   0   0   0
  38    0            0    258850384       110152      1967500    0    0     0     0  327  417   0   0 100   0   0   0
 201    0            0    258859232       110152      1967500    0    0     0     0 23478 4423  97   0   3   0   0   0
 201    0            0    258860704       110152      1967500    0    0     0     0 24155 5805 100   0   0   0   0   0
 201    0            0    258862912       110152      1967500    0    0     0     0 24w218 6335 100   0   0   0   0   0
 201    0            0    258863056       110152      1967500    0    0     0     0 24138 6172 100   0   0   0   0   0
 201    0            0    258864368       110152      1967500    0    0     0     0 24158 6259 100   0   0   0   0   0

[root@hostname-zb9ta ~]# pidstat -w 5 #限制：只能看到进程的上下文切换，看不到线程的上下文切换
# 自愿上下文切换 ： 因为内存或者I/O等资源不足，主动进行上下文切换
# 非自愿上下文切换 ： 因为时间片已到被系统进行强制调度（当大量进程争抢CPU时，就很高；比如下方的28.32就是用stress -c 200）
Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64 (hostname-zb9ta.foreman.pxe)         01/03/2025      _aarch64_       (96 CPU)

Average:      UID       PID   cswch/s nvcswch/s  Command
Average:        0     61755      1.56      0.00  kworker/u193:0-hclge
Average:        0     65381      1.56      0.00  kworker/u195:1-hclge
Average:        0     65952      1.17      0.00  kworker/u193:1-flush-253:0
Average:        0     65996      0.00     28.32  stress
Average:        0     65997      0.00     29.88  stress
Average:        0     65998      0.00     31.25  stress

[root@hostname-zb9ta ~]# pidstat -wt 1 
# -t 可以记录线程的上下文切换；不加-t的话，只记录进程的上下文切换
```

## 中断类型
```shell
[root@hostname-zb9ta ~]# cat /proc/interrupts 
# 可以看到Rescheduling interrupts 较多
# 主要是因为重调度中断，需要唤醒空闲的cpu来调度新的任务运行（分散任务到不同的cpu上）

```



## CPU 使用率查看
```shell
[root@hostname-zb9ta ~]# pidstat -u 5 1 
[root@hostname-zb9ta ~]# top
```

### CPU 使用率过高的定位方法
#### 简单应用的使用率过高问题排查
1. perf top 查看热点函数
```shell
perf top -g -p 21515 # -p 可以指定进程
```
2. perf record 和 perf report的使用 (加不加-g参数的差异)
```shell
[root@hostname-zb9ta ~]#  perf record # 进行采样
^C[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.324 MB perf.data (1506 samples) ]

[root@hostname-zb9ta ~]# ll
total 420
-rw-------. 1 root root 427980 Jan  7 09:16 perf.data

[root@hostname-zb9ta ~]# perf report  # 展示类似于perf top的报告
```

> 思考
>> 1. 用户CPU和Nice CPU过高，应该着重排查进程的性能问题，perf top看看进程的热点函数
>> 2. 系统CPU过高， 看内核线程和系统调用的性能问题（具体怎么分析？）
>> 3. ioswait过高就看磁盘IO性能
>> 4. 软中断和硬中断高，着重排查内核中的中断服务程序


#### CPU使用率高，但是top找不到对应的进程————短时进程分析
1. top 和 pidstat -u 1 不一定能查询到短时的进程(也就是程序内部通过exec调用的外面的命令)
2. 但是perf record -g 可以记录到； 或者使用 execsnoop（arm上好像没有）
```shell
# pstree 查询进程的父进程，以及进程之间的关系（或者是这个进程是怎么被启动的）
# 数字2 表示有2个进程
[root@hostname-zb9ta ~]# pstree | grep stress
        |-sshd---sshd---sshd-+-bash---stress---2*[stress]

[root@hostname-zb9ta ~]# pstree -aps 3084 #查3084进程的父进程       
```

## 系统中大量的不可中断进程和僵尸进程
> top命令下的进程状态
- R （Running / Runnable）
- D （Disk Sleep） 不可中断状态睡眠，一般表示进程正在和硬件交互，切交互过程不允许被其他进程或中断打断
- Z （Zombie） 进程已经结束，但是父进程还没有回收它的资源
- S （Interruptible Sleep） 可中断状态睡眠，表示进程因为等待某个事件而被系统挂起。
- I （Idle）

> 额外的两个进程状态

- T （Stopped/Traced） 暂停（比如发送个一个SIGSTOP信号给进程）或者跟踪状态（gdb调试的时候）：
- X （Dead） 进程已经消亡，无法在top中查看

### dstat 工具使用
支持同时查看CPU和IO两种资源的使用情况
```shell
# 安装指南：
# 间隔1秒输出10组数据
sh-4.4# dstat 1 10
You did not select any stats, using -cdngy by default.
----total-usage---- -dsk/total- -net/total- ---paging-- ---system--
usr sys idl wai stl| read  writ| recv  send|  in   out | int   csw 
  0   0 100   0   0|   0     0 |   0     0 |   0     0 | 316   437 
  0   0 100   0   0|   0     0 |   0     0 |   0     0 | 230   310 
  0   0  99   0   0|   0     0 |   0     0 |   0     0 | 619   870 
  0   0  99   0   0|   0     0 |   0     0 |   0     0 |1419  2076 
  0   0 100   0   0|   0     0 |   0     0 |   0     0 |1477  2117 
  1   0  98   0   0|   0    12k|   0     0 |   0     0 |1550  2223 
  0   0 100   0   0|   0     0 |   0     0 |   0     0 | 461   647 
  0   0 100   0   0|   0     0 |   0     0 |   0     0 |  88    90 
  0   0 100   0   0|   0     0 |   0     0 |   0     0 | 124   144 
  0   0 100   0   0|   0     0 |   0     0 |   0     0 | 466   647

```

### pidstat -d
-d 展示IO统计数据
```shell
(base) [root@hostname-acpym ~]# pidstat -d -p 158221 1 3 
Linux 5.10.0-182.0.0.95.oe2203sp3.aarch64 (hostname-acpym.foreman.pxe)  02/23/2025      _aarch64_       (96 CPU)

02:14:52 PM   UID       PID   kB_rd/s   kB_wr/s kB_ccwr/s iodelay  Command
02:14:53 PM     0    158221      0.00      0.00      0.00      98  stress
02:14:54 PM     0    158221      0.00      0.00      0.00      99  stress
02:14:55 PM     0    158221      0.00      0.00      0.00      99  stress
Average:        0    158221      0.00      0.00      0.00      99  stress
```

## 软硬中断
- 软中断和硬中断：
> Linux将中断处理分为上下两个部分，上半部分直接处理硬件请求（硬中断），特点是快速运行。比如：响应中断，把网卡数据包读取到内存中
> 下半部分由内核触发（软中断），用于延迟完成上半部分未完成的工作。比如：响应中断，然后解析数据包协议及内容


```shell
# 查询软中断
sh-4.4# cat /proc/softirqs 
                    CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7       
          HI:          0          0          0          0          0          0          0          0
       TIMER:      25623      31501      32778      25004      32521      27053      23874      26552
      NET_TX:          0          7          4          0          3          5          2          0
      NET_RX:       5444        314        489        234        380        260        339        497
       BLOCK:      16142          0          0          0          0          0          0          0
    IRQ_POLL:          0          0          0          0          0          0          0          0
     TASKLET:          0          0          0          0         29          0         28          0
       SCHED:     220614      76424      52147      38439      42269      40233      38846      43356
     HRTIMER:          0          0          0          0          0          0          0          0
         RCU:      43131      59358      65311      50818      54544      53077      46624      48508

# 查询硬中断
sh-4.4#  cat /proc/interrupts

```



### 查询软中断内核线程执行状态

每个CPU都对应一个软中断内核线程

```shell
(base) [root@localhost home]# ps -aux | grep softirq
root          12  0.0  0.0      0     0 ?        S    Apr07   0:00 [ksoftirqd/0]
root          18  0.0  0.0      0     0 ?        S    Apr07   0:00 [ksoftirqd/1]
root          23  0.0  0.0      0     0 ?        S    Apr07   0:00 [ksoftirqd/2]
root          28  0.0  0.0      0     0 ?        S    Apr07   0:00 [ksoftirqd/3]
```

