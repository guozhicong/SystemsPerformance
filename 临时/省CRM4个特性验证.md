## waas



### 安装

在所有的CRM业务计算节点执行（需要root 权限）

1. rpm -ivh --nodeps waasbooster-1.0.0-1.aarch64.rpm   # 如果没加--nodeps，则会报错没有python；（添加--nodeps接口）
2. systemctl start waasbooster
3. 查看/var/log/waasbooster.log 大量的update pod XXX ...  quota: 81000.0 即为生效



### 卸载

1. systemctl stop waasbooster
2. rpm -e waasbooster-1.0.0-1



## NUMA亲和插件



### 安装



### 卸载



