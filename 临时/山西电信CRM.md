

## mysql 5.7.27版本



sysbench安装测试：https://www.hikunpeng.com/document/detail/zh/kunpengdbs/testguide/tstg/kunpengsysbench_02_0007.html

mysql编译运行： https://www.hikunpeng.com/document/detail/zh/kunpengdbs/ecosystemEnable/MySQL/kunpengmysql8017_03_0013.html



- 175.11.22.3 压测 175.11.22.5 mysql机器，ut_crc32_sw热点函数存在且相对sysbench和mysql均配置在同一台机器上更高。大概率是ut_crc32_sw是与网络收发报校验有关导致的。

![image-20250816234900855](../png/image-20250816234900855.png)

![image-20250816235351303](../png/image-20250816235351303.png)



- sysbench和mysql均配置在同一台175.11.22.5 机器上

![image-20250816235129766](../png/image-20250816235129766.png)

配置CRC32: https://github.com/mysql/mysql-server/pull/136/files

![image-20250818110855017](../png/image-20250818110855017.png)

测试数据： https://docs.qq.com/sheet/DTnhwVE5FeHVRTUdv?tab=7uwyqn



单进程 500并发 openjdk

![image-20250818153855419](../png/image-20250818153855419.png)

![image-20250818153931282](../png/image-20250818153931282.png)

![image-20250818154051177](../png/image-20250818154051177.png)

![image-20250818154119847](../png/image-20250818154119847.png)

两进程 500并发 jdk fusion

![image-20250818155515716](../png/image-20250818155515716.png)

![image-20250818160316458](../png/image-20250818160316458.png)

![image-20250818160329918](../png/image-20250818160329918.png)

![image-20250818160350398](../png/image-20250818160350398.png)

![image-20250818160450565](../png/image-20250818160450565.png)





![image-20250819173632776](../png/image-20250819173632776.png)



