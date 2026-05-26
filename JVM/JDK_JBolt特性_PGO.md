

## topdown的bolt优化

|       | 基线    | Bolt |
| ----- | ------- | ---- |
| 测试1 | 75342ms |      |
| 测试2 | 75339ms |      |
|       |         |      |

### 两步式

java -XX:+UnlockExperimentalVMOptions -XX:+UseJBolt -XX:+JBoltDumpMode -XX:JBoltOrderFile=dump.log OrderAmountCalculator

java -XX:+UnlockExperimentalVMOptions -XX:+UseJBolt -XX:+JBoltLoadMode -XX:JBoltOrderFile=dump.log OrderAmountCalculator

### 一步式

java -XX:+UnlockExperimentalVMOptions -XX:+UseJBolt OrderAmountCalculator

```shell

# 基线
perf start: 2026-03-18 03:32:42.401
====================== TopDown Metric ======================
---------------------- frontend bound ----------------------
frontend_bound:                           1.29%
frontend_latency_bound:                    |--  1.08%
frontend_bandwidth_bound:                  |--  0.21%
------------------------- bad spec -------------------------
bad_spec:                                 5.21%
mispred:                                   |--  5.20%
mclear:                                    |--  0.01%
------------------------- retiring -------------------------
retiring:                                20.07%
----------------------- backendbound -----------------------
backend_bound:                           73.43%
core_bound:                                |-- 46.63%
core_fsu_bound:                                  |--  0.05%
core_other_bound:                                |-- 46.58%
mem_bound:                                 |-- 26.79%
mem_l1_bound:                                    |-- 26.77%
mem_l2_bound:                                    |--  0.00%
mem_l3_dram_bound:                               |--  0.02%
mem_store_bound:                                 |--  0.00%
perf start: 2026-03-18 03:32:43.519
============ Cache Performance Metrics ===========
-------------------- missrate --------------------
l1i_missrate                                0.01 %
l1d_missrate                                0.00 %
l2i_missrate                                7.40 %
l2d_missrate                               18.66 %
---------------------- mpki ----------------------
l1i_mpki                                      0.01
l1d_mpki                                      0.00
l2i_mpki                                      0.00
l2d_mpki                                      0.00
-------------------- bandwidth -------------------
l1d_bandwidth                         9316.91 MB/s
l2d_bandwidth                            2.20 MB/s
perf start: 2026-03-18 03:32:44.589
=========== TLB Performance Metrics ===========
------------------ missrate -------------------
l1i_tlb_missrate:                        0.00 %
l1d_tlb_missrate:                        0.00 %
l2i_tlb_missrate:                        0.39 %
l2d_tlb_missrate:                       10.43 %
------------------ walk rate ------------------
itlb_walk_rate:                          0.01 %
dtlb_walk_rate:                          0.00 %
-------------------- mpki ---------------------
l1i_tlb_mpki:                              0.00
l1d_tlb_mpki:                              0.00
l2i_tlb_mpki:                              0.00
l2d_tlb_mpki:                              0.00
itlb_walk_mpki:                            0.02
dtlb_walk_mpki:                            0.00
perf start: 2026-03-18 03:32:45.657
============== Instruction Mix ===============
ld_mix:                                 15.90%
st_mix:                                  9.86%
dp_mix:                                 60.56%
ase_mix:                                 0.00%
vfp_mix:                                 4.11%
br_imm_mix:                             10.28%
br_ret_mix:                              0.00%
br_ind_mix:                              0.00%
strex_fail_mix:                          0.00%
crypto_mix:                              0.00%
svc_mix:                                 0.00%
perf start: 2026-03-18 03:32:47.044
=================== unCore Metrics ====================
---------------------- missrate -----------------------
l3_missrate_0:                                  43.19 %
l3_missrate_1:                                  55.39 %
l3_missrate_2:                                  54.23 %
l3_missrate_3:                                  47.00 %
l3_missrate_4:                                  53.61 %
l3_missrate_5:                                  56.03 %
l3_missrate_6:                                  44.70 %
l3_missrate_7:                                  54.41 %
l3_missrate_8:                                  46.98 %
l3_missrate_9:                                  52.63 %
l3_missrate_10:                                 47.71 %
l3_missrate_11:                                 58.15 %
l3_missrate_12:                                 45.39 %
l3_missrate_13:                                 55.67 %
l3_missrate_14:                                 63.03 %
l3_missrate_15:                                 57.79 %
l3_missrate_16:                                 50.84 %
l3_missrate_17:                                 53.91 %
l3_missrate_18:                                 61.62 %
l3_missrate_19:                                 55.04 %
l3_missrate_20:                                 57.81 %
l3_missrate_21:                                 58.20 %
l3_missrate_22:                                 60.44 %
l3_missrate_23:                                 62.55 %
l3_missrate_24:                                 46.80 %
l3_missrate_25:                                 58.96 %
l3_missrate_26:                                 56.45 %
l3_missrate_27:                                 61.19 %
l3_missrate_28:                                 59.23 %
l3_missrate_29:                                 56.80 %
l3_missrate_30:                                 57.99 %
l3_missrate_31:                                 44.87 %
l3_missrate_total:                              52.28 %
---------------------- bandwidth ----------------------
l3_bandwidth_0:                               5.20 MB/s
l3_bandwidth_1:                               0.66 MB/s
l3_bandwidth_2:                               0.36 MB/s
l3_bandwidth_3:                               0.37 MB/s
l3_bandwidth_4:                               0.39 MB/s
l3_bandwidth_5:                               0.29 MB/s
l3_bandwidth_6:                               0.28 MB/s
l3_bandwidth_7:                               0.66 MB/s
l3_bandwidth_8:                               0.68 MB/s
l3_bandwidth_9:                               0.40 MB/s
l3_bandwidth_10:                              0.38 MB/s
l3_bandwidth_11:                              0.34 MB/s
l3_bandwidth_12:                              0.51 MB/s
l3_bandwidth_13:                              0.48 MB/s
l3_bandwidth_14:                              1.18 MB/s
l3_bandwidth_15:                              0.80 MB/s
l3_bandwidth_16:                              2.04 MB/s
l3_bandwidth_17:                              0.32 MB/s
l3_bandwidth_18:                              0.35 MB/s
l3_bandwidth_19:                              0.32 MB/s
l3_bandwidth_20:                              0.32 MB/s
l3_bandwidth_21:                              0.35 MB/s
l3_bandwidth_22:                              0.34 MB/s
l3_bandwidth_23:                              0.35 MB/s
l3_bandwidth_24:                              0.49 MB/s
l3_bandwidth_25:                              0.34 MB/s
l3_bandwidth_26:                              0.31 MB/s
l3_bandwidth_27:                              2.30 MB/s
l3_bandwidth_28:                              0.31 MB/s
l3_bandwidth_29:                              0.30 MB/s
l3_bandwidth_30:                              0.31 MB/s
l3_bandwidth_31:                              0.65 MB/s
l3_bandwidth_total                           22.36 MB/s
------------------- cross sccl rate -------------------
hha_cross_sccl_rate_0:                          38.76 %
hha_cross_sccl_rate_1:                          90.13 %
hha_cross_sccl_rate_2:                          20.20 %
hha_cross_sccl_rate_3:                          20.04 %
hha_cross_sccl_rate_4:                          25.00 %
hha_cross_sccl_rate_5:                          23.43 %
hha_cross_sccl_rate_6:                          11.53 %
hha_cross_sccl_rate_7:                           9.77 %
hha_cross_sccl_rate_total:                      62.72 %
------------------ cross socket rate ------------------
hha_cross_socket_rate_0:                        28.75 %
hha_cross_socket_rate_1:                         4.74 %
hha_cross_socket_rate_2:                        35.91 %
hha_cross_socket_rate_3:                        34.85 %
hha_cross_socket_rate_4:                        45.43 %
hha_cross_socket_rate_5:                        47.16 %
hha_cross_socket_rate_6:                        40.39 %
hha_cross_socket_rate_7:                        43.45 %
hha_cross_socket_rate_total:                    18.45 %
---------------------- bandwidth ----------------------
ddrc_rd_bandwidth_0:                          0.74 MB/s
ddrc_rd_bandwidth_1:                          0.68 MB/s
ddrc_rd_bandwidth_2:                          0.70 MB/s
ddrc_rd_bandwidth_3:                          0.76 MB/s
ddrc_rd_bandwidth_4:                          0.81 MB/s
ddrc_rd_bandwidth_5:                          0.79 MB/s
ddrc_rd_bandwidth_6:                          0.83 MB/s
ddrc_rd_bandwidth_7:                          0.81 MB/s
ddrc_rd_bandwidth_8:                          0.61 MB/s
ddrc_rd_bandwidth_9:                          0.67 MB/s
ddrc_rd_bandwidth_10:                         0.56 MB/s
ddrc_rd_bandwidth_11:                         0.67 MB/s
ddrc_rd_bandwidth_12:                         0.36 MB/s
ddrc_rd_bandwidth_13:                         0.40 MB/s
ddrc_rd_bandwidth_14:                         0.34 MB/s
ddrc_rd_bandwidth_15:                         0.42 MB/s
ddrc_rd_bandwidth_total                      10.15 MB/s
ddrc_wr_bandwidth_0:                          0.14 MB/s
ddrc_wr_bandwidth_1:                          0.15 MB/s
ddrc_wr_bandwidth_2:                          0.20 MB/s
ddrc_wr_bandwidth_3:                          0.22 MB/s
ddrc_wr_bandwidth_4:                          0.33 MB/s
ddrc_wr_bandwidth_5:                          0.31 MB/s
ddrc_wr_bandwidth_6:                          0.32 MB/s
ddrc_wr_bandwidth_7:                          0.34 MB/s
ddrc_wr_bandwidth_8:                          0.15 MB/s
ddrc_wr_bandwidth_9:                          0.25 MB/s
ddrc_wr_bandwidth_10:                         0.14 MB/s
ddrc_wr_bandwidth_11:                         0.19 MB/s
ddrc_wr_bandwidth_12:                         0.14 MB/s
ddrc_wr_bandwidth_13:                         0.21 MB/s
ddrc_wr_bandwidth_14:                         0.14 MB/s
ddrc_wr_bandwidth_15:                         0.22 MB/s
ddrc_wr_bandwidth_total                       3.46 MB/s

# Bolt

```

