#!/bin/bash

# 捕获第一次 numastat 输出并保存到临时文件
numastat > numastat1.txt || { echo "Error: Failed to run numastat"; exit 1; }
echo "-----------------------------------numastat1------------------------------------"
cat numastat1.txt

echo -e "\n------------------------------wait for 10 seconds-------------------------------\n"
# 等待10秒
sleep 10

# 捕获第二次 numastat 输出并保存到临时文件
numastat > numastat2.txt || { echo "Error: Failed to run numastat"; exit 1; }
echo "-----------------------------------numastat2------------------------------------"
cat numastat2.txt

echo -e "\n--------------------------------numastat result---------------------------------"
# 使用 awk 计算差值并格式化输出
awk '
# 处理第一个文件 (numastat1.txt)
NR == FNR {
    if (FNR == 1) {
        # 保存标题行
        header = $0
        next
    }
    # 保存指标名称和数值
    metric = $1
    for (i=2; i<=NF; i++) {
        values1[metric][i-1] = $i
    }
    next
}

# 处理第二个文件 (numastat2.txt)
{
    if (FNR == 1) {
        # 验证标题是否一致
        if ($0 != header) {
            print "Error: Header mismatch" > "/dev/stderr"
            exit 1
        }
        # 打印标题
        print $0
        next
    }

    metric = $1
    if (!(metric in values1)) {
        print "Error: Metric " metric " not found in first run" > "/dev/stderr"
        exit 1
    }

    # 计算差值并格式化输出
    printf "%-20s", metric
    for (i=2; i<=NF; i++) {
        diff = $i - values1[metric][i-1]
	printf "%18d", diff
    }
    printf "\n"
}
' numastat1.txt numastat2.txt

# 清理临时文件
rm -f numastat1.txt numastat2.txt
