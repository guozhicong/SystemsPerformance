## 常用链接

> [!NOTE]
>
> storclie64 工具的使用前，需要先确定你使用的RAID型号，因为不同RAID支持的命令存在差异（虽然大部分是一致，但是有一些例外情况，比如部分RAID支持打开RAID缓存，部分不支持）

[MegaRAID 9560-8i RAID卡 storcli64工具常用命令](https://support.huawei.com/enterprise/zh/doc/EDOC1100048779/b0bd353e)

[MegaRAID 9560-8i RAID卡storcli64工具下载链接（选择Management Software and Tools中的Latest Storcli for all OS进行下载）](https://www.broadcom.com/products/storage/raid-controllers/megaraid-9560-8i)

[查看RAID卡是否存在cache & RAID卡命名后缀含义](https://support.huawei.com/enterprise/zh/doc/EDOC1100048779/6e1b6151)


## storcli64安装
1. 下载并解压 [StorCLI.zip](./007.1507.0000.0000_Unified_StorCLI.zip), 并安装Unified_storcli_all_os/ARM/Linux/storcli-007.1507.0000.0000-1.aarch64.rpm

```shell
cd ./Unified_storcli_all_os/ARM/Linux
rpm -ivh storcli-007.1507.0000.0000-1.aarch64.rpm
```

2. storcli64的使用（也可以参考上面的常用链接）
```shell
/opt/MegaRAID/storcli/storcli64 help
```


