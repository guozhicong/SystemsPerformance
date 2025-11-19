## 问题描述

东莞区POD1 的OB主机存在网卡中断占用过高的问题，相比POD13机器，软中断消耗增加了44%，TPS/QPS性能下降38%

- POD13正常节点

  ![image-20251113101724108](/Users/guozhicong/Library/Application Support/typora-user-images/image-20251113101724108.png)

- POD1异常节点

  ![image-20251113101750594](/Users/guozhicong/Library/Application Support/typora-user-images/image-20251113101750594.png)

  ![image-20251113144737553](/Users/guozhicong/Library/Application Support/typora-user-images/image-20251113144737553.png)

## 性能分析

1. BIOS默认配置查询

   ![image-20251113144934628](/Users/guozhicong/Library/Application Support/typora-user-images/image-20251113144934628.png)

2. 