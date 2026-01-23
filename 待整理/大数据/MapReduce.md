## MapReduce 计算

MapReduce将计算分为两个阶段： Map和Reduce

1. Map阶段并行处理数据
2. Reduce阶段对Map结果进行汇总

## MapReduce核心编程思想

![image-20260116112715762](/Users/guozhicong/Library/Application Support/typora-user-images/image-20260116112715762.png)

## MapReduce进程

- MrAppMaster： 资源协调、管理MapTask和ReduceTask
- MapTask
- ReduceTask