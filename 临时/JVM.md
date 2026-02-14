## 





## JVM 参数

| JVM参数                   | 描述                                                         | 疑问                              |
| ------------------------- | ------------------------------------------------------------ | --------------------------------- |
| -XX:ReservedCodeCacheSize | JIT 编译后的代码都会放在 CodeCache 里。如果这个空间不足，JIT 就无法继续编译，编译执行会变成解释执行，性能会降低一个数量级。 | 怎么查看剩余的CodeCache空间大小？ |
|                           |                                                              |                                   |
|                           |                                                              |                                   |
|                           |                                                              |                                   |

## Jdk debug版本编译

修改configure参数为 ： --with-debug-level=fastdebug

[参考编译文档](https://gitee.com/openeuler/bishengjdk-8/wikis/%E4%B8%AD%E6%96%87%E6%96%87%E6%A1%A3/%E6%AF%95%E6%98%87JDK%208%20%E6%BA%90%E7%A0%81%E6%9E%84%E5%BB%BA%E8%AF%B4%E6%98%8E)



## 复现C2退优化

```shell
/home/compile/bishengjdk-8/install/bin/java -XX:-TieredCompilation -XX:PerMethodRecompilationCutoff=3 -XX:+PrintCompilation -XX:+UnlockDiagnosticVMOptions -XX:+TraceDeoptimization  -XX:CompileThreshold=500 -XX:-UseBiasedLocking -Xmx256m -Xms256m C2Deopt_JDK8_NoTiered

# 回显
···

Uncommon trap occurred in C2Deopt_JDK8_NoTiered::compute (@0x0000ffff983eac38) thread=281473288118752 reason=unstable_if action=reinterpret unloaded_class_index=-1
    280   16             C2Deopt_JDK8_NoTiered::compute (73 bytes)   made not entrant
DEOPT PACKING thread 0x0000ffff9400e7a0 Compiled frame (sp=0x0000ffff9b5a1150 unextended sp=0x0000ffff9b5a1150, fp=0x0000ffff9b5a11f0, real_fp=0x0000ffff9b5a1180, pc=0x0000ffff983eac38)
     nmethod    281   16             C2Deopt_JDK8_NoTiered::compute (73 bytes)

     Virtual frames (innermost first):
        0 - frame( sp=0x0000ffff9b5a1150, unextended_sp=0x0000ffff9b5a1150, fp=0x0000ffff9b5a11f0, pc=0x0000ffff983eac38)
C2Deopt_JDK8_NoTiered.compute(C2Deopt_JDK8_NoTiered.java:13) - ifeq @ bci 5 
     Created vframeArray 0x0000ffff9431bcf0
DEOPT UNPACKING thread 0x0000ffff9400e7a0 vframeArray 0x0000ffff9431bcf0 mode 2
     {method} {0x0000fffd92ffe358} 'compute' '(I)I' in 'C2Deopt_JDK8_NoTiered' - ifeq @ bci 5 sp = 0x0000ffff9b5a1100

···

```



