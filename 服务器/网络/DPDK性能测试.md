## TX-errors 持续增加，对端未收到任何包

发送端：

![image-20260413110131267](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260413110131267.png)

接收端：

![image-20260413110140326](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260413110140326.png)



基线命令

dpdk-testpmd -d librte_net_sp600.so -l 80-111 -n 4  -a 0000:c1:00.0 -- --nb-cores=31  --rxq=32 --txq=32 --rxd=1024 --txd=1024 --txpkts=1400 --burst=64 --mbcache=512 --mbuf-size=4096  --eth-peer=0,ac:dc:ca:7b:7a:42 --forward-mode=txonly --txonly-multi-flow --auto-start --stats-period 3 -i 



|                                        |      | bps      |
| -------------------------------------- | ---- | -------- |
| 基线                                   |      | 39.5G    |
| --rxd=2048 --txd=2048                  |      | 没啥效果 |
| --rxq=64 --txq=64                      |      | 没啥效果 |
| 退回基线                               |      |          |
| --main-lcore=1 --socket-mem=0,0,8192,0 |      | 没啥效果 |
|                                        |      |          |

