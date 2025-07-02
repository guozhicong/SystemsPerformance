https://www.cnblogs.com/asver/p/13895779.html



下载perf工具

1. yum install perf -y 



arm环境执行：

1. perf record -e cpu-clock -g -o arm_perf_server_on_cpu.data -- sleep 10
2. perf record -e cpu-clock -g -p  $(pidof observer) -o arm_perf_observer_on_cpu.data -- sleep 10

3. perf record -e sched:sched_stat_sleep -e sched:sched_switch -e sched:sched_process_exit -g  -o arm_perf_server_off_cpu.data -- sleep 10
4. perf record -e sched:sched_stat_sleep -e sched:sched_switch -e sched:sched_process_exit -g  -p  $(pidof observer)  -o arm_perf_observer_off_cpu.data -- sleep 10



x86环境执行

1. perf record -e cpu-clock -g -o x86_perf_server_on_cpu.data -- sleep 10
2. perf record -e cpu-clock -g -p  $(pidof observer) -o x86_perf_observer_on_cpu.data -- sleep 10

3. perf record -e sched:sched_stat_sleep -e sched:sched_switch -e sched:sched_process_exit -g  -o x86_perf_server_off_cpu.data -- sleep 10
4. perf record -e sched:sched_stat_sleep -e sched:sched_switch -e sched:sched_process_exit -g  -p  $(pidof observer)  -o x86_perf_observer_off_cpu.data -- sleep 10







| 硬件   | 配置                                                |
| ------ | --------------------------------------------------- |
| 服务器 | TaiShan 200 (Model 2280)                            |
| 处理器 | Kunpeng 5250 96core 2.6GHz                          |
| 内存   | 8 * 32GB DDR4 2666MHz                               |
| 硬盘   | 2 * 480GB SATA SSD 组raid1   （是否组raid需要标注） |
| 网卡   | 2 Mellanox MT27710 10GE 组bond1                     |



