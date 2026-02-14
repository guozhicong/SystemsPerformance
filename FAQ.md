## CMake版本升级

安装指定版本/更换版本 (推荐)

```shell
# cmake-3.16.8-Linux-x86_64.tar.gz压缩包里的文件是已经编译过的，解压就可以用！
wget https://cmake.org/files/v3.16/cmake-3.16.8-Linux-x86_64.tar.gz
# 解压
tar zxvf cmake-3.16.8-Linux-x86_64.tar.gz
# 设置软链接: 解压路径 -> /usr/bin/cmake
#   如果提示已经存在则删除老版本：rm /usr/bin/cmake
sudo ln -s /home/software/cmake-3.16.8-Linux-x86_64/bin/cmake /usr/bin/cmake
cmake --version
```



## ClickHouse编译安装

ClickHouse官方提供的arm版本RPM包仅能在920新型号（920B）上安装部署，在920上无法正常使用。猜测是部分指令集在920型号机型上不支持，导致安装过程中有coredump问题。

参考： https://www.hikunpeng.com/document/detail/zh/kunpengbds/ecosystemEnable/ClickHouse/kunpengclickhouse_02_0007.html



## CentOS RPM 包链接无法打开

http://mirror.centos.org/altarch/7/os/aarch64/Packages/openssl-libs-1.0.2k-19.el7.aarch64.rpm 无法访问

已转移至 https://vault.centos.org/altarch/7/os/aarch64/Packages/

