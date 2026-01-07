## 基本概念



---

Entity Framework   类似ORM 写sql语句的

---

WPF ； WCF 组件间通信；  WF； Card Space

---

WinForms windows应用； ASP NET   web开发 ； ADO NET 数据库连接

Framework Class Library

Common Language Runtime

---

Windows

---

x86

---





- openEuler 对于.netcore 5 \ 6 \7 版本做了适配
- Web应用基本都可以适配， 但是部分功能可能不支持
- 迁移分析：
  1. IIS ： web服务器，windows特有，需要替换
  2. SQLServer： 数据库，windows特有
  3. 其他中间件： 通信、微服务、分布式等，windows特有的需要替换



## 怎么迁移

---

业务系统

---

.net framework     （native）

---

运行时

---

windows依赖： MSDTC、MSMQ、dll.   (部分.net framework 没有具体实现，具体是调用windows的内部实现)

---









## 项目迁移

- 类重复定义

  ![image-20251209161415976](../png/image-20251209161415976.png)

  解决方法： 发现安装路径下，存在大小写不同，但是名称相同的类，删除软连接即可。

```shell
# 1. 预览：仅列出当前目录下的所有软链接
find . -maxdepth 1 -type l -print

# 2. 确认无误后，执行删除
find . -maxdepth 1 -type l -delete
```



- 找不到远程依赖的类

  