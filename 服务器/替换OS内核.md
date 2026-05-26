## 下载新内核rpm包

```shell
wget https://mirrors.cmecloud.cn/bclinux/oe21.10/OS/aarch64/Packages/kernel-4.19.90-2107.6.0.0100.oe1.bclinux.aarch64.rpm 
```

## 安装新内核

```shell
rpm -ivh --force kernel-4.19.90-2107.6.0.0100.oe1.bclinux.aarch64.rpm
```

## 查询已安装内核

```shell
[root@syn-173-090-002-002 ~]# rpm -qa kernel 
kernel-4.19.90-2211.2.0.0176.oe1.aarch64
kernel-4.19.90-2107.6.0.0100.oe1.bclinux.aarch64
```

## 查询所有的内核菜单项

```shell
[root@syn-173-090-002-002 ~]# grubby --info=ALL | grep -E "^index=|^title="
index=0
title=BigCloud Enterprise Linux (4.19.90-2107.6.0.0100.oe1.bclinux.aarch64) 21.10 (LTS-SP2)
index=1
title=BigCloud Enterprise Linux (4.19.90-2211.2.0.0176.oe1.aarch64) 21.10 (LTS-SP2)
index=2
title=BigCloud Enterprise Linux (0-rescue-05480721d98046abb3300745094e869c) 21.10 (LTS-SP2)
index=3
index=4
index=5
```

## 设置默认内核

```shell
# 设 index=0（新内核）为默认
grubby --set-default-index=0
```

## 验证是否生效

```shell
grubby --default-kernel
grubby --default-title
```

## 重启验证

```shell
reboot
uname -a
```



