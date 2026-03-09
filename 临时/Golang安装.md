## 官网

https://go.dev/doc/install

## 安装

```shell
wget https://dl.google.com/go/go1.25.0.linux-arm64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.25.0.linux-arm64.tar.gz 
export PATH=$PATH:/usr/local/go/bin

# 安装完成
[root@hostname-skiuw cloud-native]# go version
go version go1.25.0 linux/arm64
```





## FAQ 

Q： 执行go mod tidy 报错

```shell
go: kunpeng.huawei.com/kunpeng-cloud-computing/pkg/kunpeng-perf-monitor/collector tested by
        kunpeng.huawei.com/kunpeng-cloud-computing/pkg/kunpeng-perf-monitor/collector.test imports
        github.com/stretchr/testify/require: github.com/stretchr/testify@v1.11.1: Get "https://proxy.golang.org/github.com/stretchr/testify/@v/v1.11.1.zip": dial tcp 142.251.34.209:443: i/o timeout
```

A: 执行 

```shell
go env -w GOPROXY=https://goproxy.cn
```





