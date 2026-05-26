## OSI网络模型和TCP/IP模型

OSI七层模型只是一个标准，没有具体实现。TCP/IP模型是具体实现，有相关的协议。

![image-20260401143947436](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260401143947436.png)

### TCP/IP模型

TCP/IP(网络四层)模型，每往下一层都会增加头部/尾部，按照特定的协议格式填充。

> [!NOTE]
>
> MTU（最大传输单元）：规定了最大的IP包的大小，默认是1500。如果IP包超过了MTU的大小，就会在网络层分片。

```shell
[root@hostname-5brju ~]# ip link show enp23s0f0
2: enp23s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether ac:dc:ca:86:a4:42 brd ff:ff:ff:ff:ff:ff
```

## Linux内核协议栈

```text
应用程序
    ↑↓ （通过 Socket）
内核协议栈（TCP、UDP、IP、ARP…）
    ↑↓
网卡驱动、DMA、软中断、网卡
```



### 网络包收发过程

1. 内核分配一个主内存地址段（DMA缓冲区），网卡设备可以在DMA缓冲区中读写数据
2. 当来了一个网络包之后，网卡将网络包写入DMA缓冲区，写完通知CPU产生硬中断
3. 硬中断处理程序锁定当前的DMA缓冲区，然后将网络包拷贝到另一块内存区（sk_buff缓冲区），清空并解锁当前的DMA缓冲区，然后通知软中断去处理网络包

![image-20260401161018430](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260401161018430.png)

## 