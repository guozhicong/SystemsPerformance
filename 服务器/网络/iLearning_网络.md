

## JAVA进程

``````java
@RestController
@RequestMapping("/api/hello")
public class HelloController {

    @GetMapping("/message")
    public String getHelloMessage() {
        return "Hello, Spring Boot Controller!";
    }
}

``````

```shell
[root@hostname-bk7uh home]# java -jar demo-0.0.1-SNAPSHOT.jar & 
[2] 103758
[root@hostname-bk7uh home]# 
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/

 :: Spring Boot ::                (v3.5.4)

2025-09-09T04:35:04.284Z  INFO 103758 --- [demo] [           main] com.example.demo.DemoApplication         : Starting DemoApplication v0.0.1-SNAPSHOT using Java 17.0.16 with PID 103758 (/home/demo-0.0.1-SNAPSHOT.jar started by root in /home)
2025-09-09T04:35:04.288Z  INFO 103758 --- [demo] [           main] com.example.demo.DemoApplication         : No active profile set, falling back to 1 default profile: "default"
2025-09-09T04:35:05.416Z  INFO 103758 --- [demo] [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port 8819 (http)
2025-09-09T04:35:05.435Z  INFO 103758 --- [demo] [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2025-09-09T04:35:05.435Z  INFO 103758 --- [demo] [           main] o.apache.catalina.core.StandardEngine    : Starting Servlet engine: [Apache Tomcat/10.1.43]
2025-09-09T04:35:05.476Z  INFO 103758 --- [demo] [           main] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2025-09-09T04:35:05.479Z  INFO 103758 --- [demo] [           main] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 1116 ms
2025-09-09T04:35:05.958Z  WARN 103758 --- [demo] [           main] ConfigServletWebServerApplicationContext : Exception encountered during context initialization - cancelling refresh attempt: org.springframework.context.ApplicationContextException: Failed to start bean 'webServerStartStop'
2025-09-09T04:35:05.978Z  INFO 103758 --- [demo] [           main] .s.b.a.l.ConditionEvaluationReportLogger : 
```



## JMeter

安装部署： https://www.hikunpeng.com/ecosystem/compatibility   搜索apache-jmeter 下载rpm包后直接yum install安装即可

配置指导： https://www.cnblogs.com/stulzq/p/8971531.html 先在windows机器上配置jmeter，再导出jmx文件到linux服务器





## Nginx

安装部署:  参考依赖安装和通过镜像站Yum命令安装两个章节即可，其他不需要管 https://www.hikunpeng.com/document/detail/zh/kunpengwebs/ecosystemEnable/Nginx/kunpengnginx_02_0005.html



修改nginx配置文件： /etc/nginx/nginx.conf



涉及server_name和location的修改

```shell
    server {
        listen       80;
        listen       [::]:80;
        server_name  localhost;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
                proxy_pass http://localhost:8819;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
```



nginx启动命令： systemctl restart nginx





## 压测命令

压测命令： jmeter -n -t  ./message_demo.jmx -l result.txt



![image-20250909124131716](../../png/image-20250909124131716.png)