#!/bin/bash

###################################################################
# 查询BIOS是否为默认配置，适用Kunpeng 920和920B，不支持920C
#
# 使用方式：
#     使用前请安装BIOSTools: yum install BIOSTools-Kunpeng-5.1.aarch64.rpm -y
#
#     默认只输出差异点，添加参数all后，可以额外查看相同的配置项
#     bash ./bios_diff.sh 920 [all]
#     bash ./bios_diff.sh 920B [all]
#
# 更新说明
#  - 2024/04/10: 新增支持920B BIOS配置检查
###################################################################

# 920/920B/920C 默认BIOS配置
declare -A DEFAULT_920_BIOS
# 920B使用的7270Z机型
declare -A DEFAULT_920B_BIOS

# 当前机器的BIOS配置
declare -A my_bios_config
# 默认机器和当前机器的BIOS全量配置set集合
declare -a set=()
declare -a print_set=()

# 将文本BIOS配置存储到map和set集合中
function init_bios_config() {
    data=$1
    local -n bios_config=$2
    # 使用 awk 提取第一列和第三列数据并存储到 Map 中
    while IFS=':' read -r key value; do
        key=$(echo "$key" | awk '{$1=$1; print}')  # 去除key两端的空格
        # 检查set中是否已经包含该值
        if [[ ! " ${set[@]} " =~ " $key " ]]; then
            set+=("$key")  # 如果set中不包含该值，则添加到set中
        fi
        value=$(echo "$value" | awk '{$1=$1; print}')  # 去除value两端的空格
        bios_config["$key"]="${value}"  # 存储到map中
    done <<< "$data"
}

# 初始化920/920B默认的BIOS配置
function init_default_bios_config() {
    default_bios_920_str="BenchMarkSelection                        : Custom
                          BootTypeOrder0                            : HardDiskDrive
                          BootTypeOrder1                            : DVDROMDrive
                          BootTypeOrder2                            : PXE
                          BootTypeOrder3                            : Others
                          DDRDebugLevel                             : Minimum
                          DDRFreqLimit                              : Auto
                          DdrRefreshSupport                         : Enabled
                          DdrRefreshRate                            : 32ms
                          RankMargin                                : Disabled
                          RMTPatternLength                          : 1
                          PerBITMargin                              : Disabled
                          CAMargin                                  : Disabled
                          DieInterleaving                           : Disabled
                          ChannelInterleaving                       : Enabled
                          ChannelInterleaving_3Way                  : Enabled
                          RankInterleaving                          : 4-way Interleave
                          NUMAEn                                    : Enabled
                          CkeProgramming                            : Disabled
                          CkeIdleTimer                              : 20
                          HWMemTest                                 : Enabled
                          WarmBootFastSupport                       : Enabled
                          ColdBootFastSupport                       : Enabled
                          BMCWDTEnable                              : Disabled
                          BMCWDTTimeout                             : 15
                          BMCWDTAction                              : HardReset
                          OSWDTEnable                               : Disabled
                          OSWDTTimeout                              : 5
                          OSWDTAction                               : HardReset
                          PXEOnly                                   : Disabled
                          PXE1Setting                               : Enabled
                          PXE2Setting                               : Enabled
                          PXE3Setting                               : Enabled
                          PXE4Setting                               : Enabled
                          Eth1ConfigSwitch                          : Disabled
                          Eth2ConfigSwitch                          : Disabled
                          Eth3ConfigSwitch                          : Disabled
                          Eth4ConfigSwitch                          : Disabled
                          Port1AdaptiveLink                         : Disabled
                          Port2AdaptiveLink                         : Disabled
                          Port3AdaptiveLink                         : Disabled
                          Port4AdaptiveLink                         : Disabled
                          Port1AutoNegotitation                     : NotSet
                          Port2AutoNegotitation                     : NotSet
                          Port3AutoNegotitation                     : NotSet
                          Port4AutoNegotitation                     : NotSet
                          Port1SpeedAndFEC                          : NotSet
                          Port2SpeedAndFEC                          : NotSet
                          Port3SpeedAndFEC                          : NotSet
                          Port4SpeedAndFEC                          : NotSet
                          Port1LinkSpeed                            : NotSet
                          Port2LinkSpeed                            : NotSet
                          Port3LinkSpeed                            : NotSet
                          Port4LinkSpeed                            : NotSet
                          Port1TqpNumber                            : 4
                          Port2TqpNumber                            : 4
                          Port3TqpNumber                            : 4
                          Port4TqpNumber                            : 4
                          Port1FuncNumber                           : 4
                          Port2FuncNumber                           : 4
                          Port3FuncNumber                           : 4
                          Port4FuncNumber                           : 4
                          Port1BdNumber                             : 1024
                          Port2BdNumber                             : 1024
                          Port3BdNumber                             : 1024
                          Port4BdNumber                             : 1024
                          Port1BuffSize                             : 2K
                          Port2BuffSize                             : 2K
                          Port3BuffSize                             : 2K
                          Port4BuffSize                             : 2K
                          PXE5Setting                               : Enabled
                          PXE6Setting                               : Enabled
                          PXE7Setting                               : Enabled
                          PXE8Setting                               : Enabled
                          PXE9Setting                               : Enabled
                          Eth5ConfigSwitch                          : Disabled
                          Eth6ConfigSwitch                          : Disabled
                          Eth7ConfigSwitch                          : Disabled
                          Eth8ConfigSwitch                          : Disabled
                          Eth9ConfigSwitch                          : Disabled
                          Port5AdaptiveLink                         : Disabled
                          Port6AdaptiveLink                         : Disabled
                          Port7AdaptiveLink                         : Disabled
                          Port8AdaptiveLink                         : Disabled
                          Port9AdaptiveLink                         : Disabled
                          Port5AutoNegotitation                     : NotSet
                          Port6AutoNegotitation                     : NotSet
                          Port7AutoNegotitation                     : NotSet
                          Port8AutoNegotitation                     : NotSet
                          Port9AutoNegotitation                     : NotSet
                          Port5SpeedAndFEC                          : NotSet
                          Port6SpeedAndFEC                          : NotSet
                          Port7SpeedAndFEC                          : NotSet
                          Port8SpeedAndFEC                          : NotSet
                          Port9SpeedAndFEC                          : NotSet
                          Port5LinkSpeed                            : NotSet
                          Port6LinkSpeed                            : NotSet
                          Port7LinkSpeed                            : NotSet
                          Port8LinkSpeed                            : NotSet
                          Port9LinkSpeed                            : NotSet
                          Port5TqpNumber                            : 256
                          Port6TqpNumber                            : 256
                          Port7TqpNumber                            : 256
                          Port8TqpNumber                            : 256
                          Port9TqpNumber                            : 0
                          Port5FuncNumber                           : 8
                          Port6FuncNumber                           : 8
                          Port7FuncNumber                           : 8
                          Port8FuncNumber                           : 8
                          Port9FuncNumber                           : 0
                          Port5BdNumber                             : 1024
                          Port6BdNumber                             : 1024
                          Port7BdNumber                             : 1024
                          Port8BdNumber                             : 1024
                          Port9BdNumber                             : 1024
                          Port5BuffSize                             : 2K
                          Port6BuffSize                             : 2K
                          Port7BuffSize                             : 2K
                          Port8BuffSize                             : 2K
                          Port9BuffSize                             : 2K
                          PXENetworkProtocol                        : UEFIIPv4
                          IPv4PXESupport                            : Enabled
                          IPv6PXESupport                            : Disabled
                          IPv6DuidType                              : DUID-UUID
                          PCIEDPCSupport                            : Disabled
                          DPCWorkAround                             : Enabled
                          PCIeSRIOVSupport                          : Enabled
                          SrIovSystemPageSize                       : 4K
                          PcieSlotPxeControl[0]                     : Enable
                          PcieSlotPxeControl[1]                     : Enable
                          PcieSlotPxeControl[2]                     : Enable
                          PcieSlotPxeControl[3]                     : Enable
                          PcieSlotPxeControl[4]                     : Enable
                          PcieSlotPxeControl[5]                     : Enable
                          PcieSlotPxeControl[6]                     : Enable
                          PcieSlotPxeControl[7]                     : Enable
                          PCIEPort[0]                               : Enabled
                          PCIELinkSpeedPort[0]                      : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[0]                 : LEVEL-256B
                          PCIEPort[1]                               : Enabled
                          PCIELinkSpeedPort[1]                      : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[1]                 : LEVEL-256B
                          PCIEPort[2]                               : Enabled
                          PCIELinkSpeedPort[2]                      : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[2]                 : LEVEL-256B
                          PCIEPort[3]                               : Enabled
                          PCIELinkSpeedPort[3]                      : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[3]                 : LEVEL-256B
                          PCIEPort[4]                               : Enabled
                          PCIELinkSpeedPort[4]                      : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[4]                 : LEVEL-256B
                          PCIEPort[5]                               : Enabled
                          PCIELinkSpeedPort[5]                      : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[5]                 : LEVEL-256B
                          PCIEPort[6]                               : Enabled
                          PCIELinkSpeedPort[6]                      : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[6]                 : LEVEL-256B
                          PCIEPort[7]                               : Enabled
                          PCIELinkSpeedPort[7]                      : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[7]                 : LEVEL-256B
                          PCIEPort[8]                               : Enabled
                          PCIELinkSpeedPort[8]                      : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[8]                 : LEVEL-256B
                          PCIEPort[10]                              : Enabled
                          PCIELinkSpeedPort[10]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[10]                : LEVEL-256B
                          PCIEPort[12]                              : Enabled
                          PCIELinkSpeedPort[12]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[12]                : LEVEL-256B
                          PCIEPort[13]                              : Enabled
                          PCIELinkSpeedPort[13]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[13]                : LEVEL-256B
                          PCIEPort[14]                              : Enabled
                          PCIELinkSpeedPort[14]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[14]                : LEVEL-256B
                          PCIEPort[15]                              : Enabled
                          PCIELinkSpeedPort[15]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[15]                : LEVEL-256B
                          PCIEPort[16]                              : Enabled
                          PCIELinkSpeedPort[16]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[16]                : LEVEL-256B
                          PCIEPort[17]                              : Enabled
                          PCIELinkSpeedPort[17]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[17]                : LEVEL-256B
                          PCIEPort[18]                              : Enabled
                          PCIELinkSpeedPort[18]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[18]                : LEVEL-256B
                          PCIEPort[20]                              : Enabled
                          PCIELinkSpeedPort[20]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[20]                : LEVEL-256B
                          PCIEPort[21]                              : Enabled
                          PCIELinkSpeedPort[21]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[21]                : LEVEL-256B
                          PCIEPort[22]                              : Enabled
                          PCIELinkSpeedPort[22]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[22]                : LEVEL-256B
                          PCIEPort[23]                              : Enabled
                          PCIELinkSpeedPort[23]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[23]                : LEVEL-256B
                          PCIEPort[24]                              : Enabled
                          PCIELinkSpeedPort[24]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[24]                : LEVEL-256B
                          PCIEPort[25]                              : Enabled
                          PCIELinkSpeedPort[25]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[25]                : LEVEL-256B
                          PCIEPort[26]                              : Enabled
                          PCIELinkSpeedPort[26]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[26]                : LEVEL-256B
                          PCIEPort[27]                              : Enabled
                          PCIELinkSpeedPort[27]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[27]                : LEVEL-256B
                          PCIEPort[28]                              : Enabled
                          PCIELinkSpeedPort[28]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[28]                : LEVEL-256B
                          PCIEPort[29]                              : Enabled
                          PCIELinkSpeedPort[29]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[29]                : LEVEL-256B
                          PCIEPort[30]                              : Enabled
                          PCIELinkSpeedPort[30]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[30]                : LEVEL-256B
                          PCIEPort[31]                              : Enabled
                          PCIELinkSpeedPort[31]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[31]                : LEVEL-256B
                          PCIEPort[32]                              : Enabled
                          PCIELinkSpeedPort[32]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[32]                : LEVEL-256B
                          PCIEPort[33]                              : Enabled
                          PCIELinkSpeedPort[33]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[33]                : LEVEL-256B
                          PCIEPort[34]                              : Enabled
                          PCIELinkSpeedPort[34]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[34]                : LEVEL-256B
                          PCIEPort[35]                              : Enabled
                          PCIELinkSpeedPort[35]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[35]                : LEVEL-256B
                          PCIEPort[36]                              : Enabled
                          PCIELinkSpeedPort[36]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[36]                : LEVEL-256B
                          PCIEPort[37]                              : Enabled
                          PCIELinkSpeedPort[37]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[37]                : LEVEL-256B
                          PCIEPort[38]                              : Enabled
                          PCIELinkSpeedPort[38]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[38]                : LEVEL-256B
                          PCIEPort[39]                              : Enabled
                          PCIELinkSpeedPort[39]                     : GEN4(16GT/s)
                          PCIEMaxPayloadSizePort[39]                : LEVEL-256B
                          EnableSMMU                                : Disabled
                          EnableGOP                                 : Enabled
                          EnableSpcr                                : Enabled
                          SYSDBGLevel                               : Debug
                          CREnable                                  : Enabled
                          CPUPrefetchConfig                         : Enabled
                          AdaptivePrefetch                          : Disabled
                          StorePrefetch                             : Disabled
                          DupBootOptionPolicy                       : Back
                          EnRasSupport                              : Enabled
                          EnPoison                                  : Enabled
                          PatrolScrub                               : Enabled
                          PatrolScrubDuration                       : 24
                          ScrubCEMaskInterrupt                      : Disabled
                          DemandScrubMode                           : Enabled
                          X8MisCorrEn                               : Disabled
                          PowerOnTime                               : 10
                          DimmTime                                  : 10
                          CorrectErrorThreshold                     : 6000
                          FunnelPeriod                              : Enabled
                          AdvanceDeviceCorrection                   : Disabled
                          EcrcFeature                               : Disabled
                          HotPlug                                   : Enabled
                          NoBootResetSetting                        : Disabled
                          SpecialBoot                               : Disabled
                          SPBoot                                    : Enabled
                          ExtrNicBoot                               : Enabled
                          PxeRetry                                  : 1
                          LOMDid                                    : Disable
                          ProcessorFlexibleRatioOverrideEnable      : Disabled
                          ProcessorFlexibleRatio                    : 26
                          UsbControllerEnable                       : Enabled
                          OneNumaEnable                             : Disabled
                          SktInterleaving                           : Disabled
                          MemoryInitType                            : Parallel
                          HaltOnMemoryError                         : Disable
                          ExmbistSupport                            : Disable
                          MultiBankErrorThreshold                   : 65535
                          PcieLinkDeEmphasisPortX6000[0]            : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[1]            : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[2]            : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[3]            : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[4]            : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[5]            : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[6]            : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[7]            : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[8]            : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[10]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[12]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[13]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[14]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[15]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[16]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[17]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[18]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[20]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[21]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[22]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[23]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[24]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[25]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[26]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[27]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[28]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[29]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[30]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[31]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[32]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[33]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[34]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[35]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[36]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[37]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[38]           : Level-6.0dB
                          PcieLinkDeEmphasisPortX6000[39]           : Level-6.0dB
                          CoreLabeling                              : Packed
                          PcieResourceDsm5                          : BIOS Reserve
                          CpuCoreNumber                             : Disabled
                          DmiVendorChange                           : Disabled
                          EnFdmSupport                              : Enable
                          CoreIsolateOnlineFlag                     : Disable
                          CoreIsolateOnlineShow                     : No
                          CustomPowerPolicy                         : Efficiency
                          DemtMode                                  : Disabled
                          SecureBoot                                : Disabled
                          RedfishSupport                            : Disable
                          CertificateWarningTime                    : 90
                          CacheMode                                 : in:partition out:share
                          StreamWrite                               : Allocate share LLC
                          StreamWriteValue                          : threshold: 12 lines
                          HHASpecConfig                             : Enabled
                          DvfsSupport                               : Enabled
                          DvfsFlag                                  : No
                          SsbsSupport                               : Disabled
                          DisplayMode                               : On Board Graphics
                          SpeEn                                     : Disabled
                          SlitTableVersion                          : Version2
                          Type2VersionCustom                        : Disabled
                          UsbPort1                                  : Enabled
                          UsbPort2                                  : Enabled
                          UsbPort3                                  : Enabled
                          UsbPort4                                  : Enabled
                          BaudRate                                  : 115200
                          DataBits                                  : 8
                          Parity                                    : NO
                          StopBits                                  : 1
                          FlowControl                               : NO
                          TerminalType                              : ANSI
                          OnboardPXEDisable                         : Enable All
                          PfNumConfig1                              : 4
                          PfNumConfig2                              : 4
                          MlxPort0                                  : Enable
                          MlxPort1                                  : Enable
                          SmmuWorkAround                            : Disabled
                          Support40Bit                              : Disabled
                          Support44Bit                              : Disabled
                          MemoryPreAlloc                            : Disabled
                          SpdDataRepair                             : Enabled
                          KaslrSupport                              : Disabled
                          Slot1BandWidth                            : Disable
                          Slot2BandWidth                            : Disable
                          Slot3BandWidth                            : Disable
                          Slot4BandWidth                            : Disable
                          Slot5BandWidth                            : Disable
                          Slot6BandWidth                            : Disable
                          BbuNvSize                                 : 16G
                          BbuHddNum                                 : 2
                          TpmClear                                  : Disabled
                          OemTpmEnable                              : No Action
                          TpmAvailability                           : Available
                          PciePortPolicy                            : Auto
                          BBUPresent                                : No
                          NVMeGen4Workaround                        : Disable
                          CusFlag                                   : Disabled
                          LoadCustomDefaults                        : NoAction
                          EnableL2PMU                               : Disabled
                          Type4SocketName                           : Disabled
                          TpmAcpiFormat                             : NoHID
                          CustomizedFeatures                        : Disabled
                          SPIFrequency                              : 10
                          TeeSupport                                : Disable
                          TeeMemSize                                : 1G
                          PxeTimeoutRetryControl                    : Disabled
                          SupportBusAdjustment                      : Enable
                          SetCustomDefaults                         : NoAction
                          PageIsolation                             : Disabled
                          Mem2BitErrCorrEn                          : Enabled
                          CeReportPolicyEn                          : Disabled
                          SmcccVersionWorkAround                    : Default
                          SriovBusResWorkAround                     : Disabled"

    default_bios_920B_str="Slot31BandWidth                           : Disabled
                           Port8TqpNumber                            : 0
                           Port5FuncNumber                           : 0
                           Port2SpeedAndFEC                          : NotSet
                           Slot26BandWidth                           : Disabled
                           Port7AdaptiveLink                         : NotSet
                           Slot1BandWidth                            : Disabled
                           HotPlug                                   : Enabled
                           CacheMode                                 : in:partition out:share
                           Port2BdNumber                             : 1024
                           DdrDebugLevel                             : Minimum
                           Port2AutoNegotitation                     : ON
                           Port4SpeedAndFEC                          : NotSet
                           MultiBankErrorThreshold                   : 65535
                           Port1BdNumber                             : 1024
                           DemandScrubMode                           : Enabled
                           RxMultipleTunnel                          : Enabled
                           EcrcFeature                               : Disabled
                           Slot27BandWidth                           : Disabled
                           NUMAEn                                    : Enabled
                           PXE6Setting                               : Enabled
                           PXE4Setting                               : Enabled
                           OSWDTAction                               : HardReset
                           HiBoostProfile                            : Auto
                           SYSDBGLevel                               : Disabled
                           MbistMpprEn                               : Disabled
                           BMCWDTTimeout                             : 15
                           HiBoostEn                                 : Disabled
                           Port4AdaptiveLink                         : NotSet
                           Slot33BandWidth                           : Disabled
                           IPv6HttpsEn                               : Enabled
                           BMCWDTEnable                              : Disabled
                           Slot28BandWidth                           : Disabled
                           FunnelPeriod                              : Enabled
                           DemtMode                                  : OS Mode
                           PxeTimeoutRetryControl                    : Disabled
                           Port5AutoNegotitation                     : NotSet
                           PXE5Setting                               : Enabled
                           Port5SpeedDuplex                          : NotSet
                           AddressMirrorNuma5                        : 0
                           SMT2En                                    : Enabled
                           HWMemTest                                 : Enabled
                           Port5TqpNumber                            : 0
                           Slot11BandWidth                           : Disabled
                           PCIeSRIOVSupport                          : Enabled
                           Port6LinkMode                             : GE mode
                           OemTpmEnable                              : NoAction
                           NoBootResetSetting                        : Disabled
                           PXE2Setting                               : Enabled
                           UFSProfile                                : Fast
                           ChannelInterleaving_3Way                  : Enabled
                           CdnSupport                                : Enabled
                           ErrInjEn                                  : Disabled
                           Port4AutoNegotitation                     : ON
                           Port4SccAlgorithmMode                     : DCQCN
                           Port8LinkSpeed                            : NotSet
                           Port8SpeedDuplex                          : NotSet
                           Port1SpeedAndFEC                          : NotSet
                           PatrolScrub                               : Enabled
                           Slot35BandWidth                           : Disabled
                           AutoSelfRefresh                           : 40
                           IPv6PXESupport                            : Enabled
                           NetworkProtocol                           : UEFIIPv4IPv6
                           KaslrSupport                              : Enabled
                           BootTypeOrder3                            : Others
                           Port3SpeedDuplex                          : 1000M_FULL
                           CoreIsolateNoCmtEn                        : Enabled
                           Slot20BandWidth                           : Disabled
                           Slot10BandWidth                           : Disabled
                           OnlineCoreIsolateSwitch                   : Enabled
                           Port5LinkMode                             : GE mode
                           Port1BuffSize                             : 2K
                           Slot32BandWidth                           : Disabled
                           ClkFreq                                   : 100MHz
                           AdaptivePrefetch                          : Enabled
                           CoreLabeling                              : Packed
                           Port1LinkMode                             : GE mode
                           Port6SpeedDuplex                          : NotSet
                           Port2BuffSize                             : 2K
                           Parity                                    : None
                           TpmClear                                  : Disabled
                           PcieAspm                                  : L1
                           Port8LinkMode                             : GE mode
                           Port1PfNumConfig                          : 4
                           SrIovSystemPageSize                       : 64K
                           AclsEn                                    : Enabled
                           PcieResourceDsm5                          : BIOS Reserve
                           SpecialBoot                               : Disabled
                           Port6SpeedAndFEC                          : NotSet
                           SPBoot                                    : Enabled
                           DDRFreqLimit                              : Auto
                           BootTypeOrder2                            : PXE
                           EnFdmSupport                              : Enable
                           Port8AdaptiveLink                         : NotSet
                           Port6TqpNumber                            : 0
                           ProcessorFlexibleRatio                    : 58
                           CoreIsolatePostEn                         : Enabled
                           Slot17BandWidth                           : Disabled
                           EnableSMMU                                : Disabled
                           HaltOnMemoryError                         : Disable
                           IPv4PXESupport                            : Enabled
                           SataRate                                  : 6.0Gbps
                           ProcessorFlexibleRatioOverrideEnable      : Disabled
                           Port4TqpNumber                            : 4
                           Port6AdaptiveLink                         : NotSet
                           PXE8Setting                               : Enabled
                           PXE7Setting                               : Enabled
                           OneNumaEnable                             : Disabled
                           Port8BdNumber                             : 0
                           CREnable                                  : Enabled
                           Port4FuncNumber                           : 4
                           WarmBootFastSupport                       : Enabled
                           Slot12BandWidth                           : Disabled
                           ExtrNicBoot                               : Enabled
                           Port6BdNumber                             : 0
                           PowerPolicy                               : Custom
                           MemoryInitType                            : Parallel
                           PatrolScrubDuration                       : 24
                           RankMargin                                : Disabled
                           DimmOverTempThroEn                        : Enabled
                           Port6SccAlgorithmMode                     : DCQCN
                           Port1AutoNegotitation                     : ON
                           Port8AutoNegotitation                     : NotSet
                           IoBypassLlcEn                             : Disabled
                           FlexIOControl                             : Enable All
                           AddressMirrorNuma2                        : 0
                           Port3LinkMode                             : GE mode
                           Port4LinkMode                             : GE mode
                           Port8SpeedAndFEC                          : NotSet
                           Port7FuncNumber                           : 0
                           CpuCoreNumber                             : Disabled
                           Slot22BandWidth                           : Disabled
                           Support44Bit                              : Disabled
                           Port2FuncNumber                           : 4
                           Port1SccAlgorithmMode                     : DCQCN
                           DdrRefreshRate                            : Auto
                           WrCrcEn                                   : Disabled
                           Port1AdaptiveLink                         : NotSet
                           Slot38BandWidth                           : Disabled
                           Slot19BandWidth                           : Disabled
                           PxeClients                                : HW Client
                           Port5BdNumber                             : 0
                           Port4LinkSpeed                            : 1GE
                           Port1SpeedDuplex                          : 1000M_FULL
                           CoreIsolateOnlineFlag                     : Disable
                           Slot8BandWidth                            : Disabled
                           Port8FuncNumber                           : 0
                           PerBITMargin                              : Disabled
                           BaudRate                                  : 115200
                           Port6LinkSpeed                            : NotSet
                           PerByteMargin                             : Disabled
                           Slot4BandWidth                            : Disabled
                           Slot6BandWidth                            : Disabled
                           Slot18BandWidth                           : Disabled
                           PprType                                   : Disabled
                           Port3BuffSize                             : 2K
                           Slot21BandWidth                           : Disabled
                           OSWDTTimeout                              : 5
                           Port3AdaptiveLink                         : NotSet
                           Slot23BandWidth                           : Disabled
                           BMCWDTAction                              : HardReset
                           Slot29BandWidth                           : Disabled
                           Port5LinkSpeed                            : NotSet
                           BenchMarkSelection                        : Custom
                           HiBoostFreqSelect                         : 120
                           DemtProfile                               : Balanced Performance
                           Port2LinkMode                             : GE mode
                           Slot13BandWidth                           : Disabled
                           SetCustomDefaults                         : NoAction
                           Port2SpeedDuplex                          : 1000M_FULL
                           Port7SpeedDuplex                          : NotSet
                           Slot9BandWidth                            : Disabled
                           Slot15BandWidth                           : Disabled
                           LoadCustomDefaults                        : NoAction
                           CusFlag                                   : Disabled
                           Slot39BandWidth                           : Disabled
                           DdrRefreshSupport                         : Enabled
                           TeeMemSize                                : AUTO
                           TeeSupport                                : Disable
                           Port5SccAlgorithmMode                     : DCQCN
                           TpmAvailability                           : Available
                           PXE1Setting                               : Enabled
                           Port1TqpNumber                            : 4
                           SecureBoot                                : Disabled
                           CertificateWarningTime                    : 90
                           OSWDTEnable                               : Disabled
                           Slot16BandWidth                           : Disabled
                           Port5AdaptiveLink                         : NotSet
                           Port7BdNumber                             : 0
                           MemIsolationEn                            : Enabled
                           Slot37BandWidth                           : Disabled
                           Port3LinkSpeed                            : 1GE
                           PxeRetry                                  : 1
                           LPIEn                                     : Enabled
                           Port4BdNumber                             : 1024
                           Slot5BandWidth                            : Disabled
                           Slot3BandWidth                            : Disabled
                           EcsEtc                                    : 256
                           Port2SccAlgorithmMode                     : DCQCN
                           Port5SpeedAndFEC                          : NotSet
                           Port3FuncNumber                           : 4
                           AdvMemTestOptions                         : 0
                           AddressMirrorNuma0                        : 0
                           PXE3Setting                               : Enabled
                           MirrorMode                                : Disabled
                           Port7AutoNegotitation                     : NotSet
                           Port6FuncNumber                           : 0
                           EcsEn                                     : Enabled
                           Slot24BandWidth                           : Disabled
                           AddressMirrorNuma4                        : 0
                           Slot2BandWidth                            : Disabled
                           EcsCountMode                              : Row Mode
                           Port3TqpNumber                            : 4
                           Port2AdaptiveLink                         : NotSet
                           CorrectErrorThreshold                     : 6000
                           Port2LinkSpeed                            : 1GE
                           Port4BuffSize                             : 2K
                           Port3AutoNegotitation                     : ON
                           PcieRasReportConfig                       : BIOS Handle First
                           AutoSelfRefreshEn                         : Disabled
                           EnRasSupport                              : Enabled
                           IPv4HttpsEn                               : Enabled
                           HCCSL0pEn                                 : Disabled
                           Port7SpeedAndFEC                          : NotSet
                           PwdExpirPolicy                            : Disabled
                           OnlinePprEn                               : Enabled
                           AddressMirrorNuma6                        : 0
                           Port1FuncNumber                           : 4
                           RMTPatternLength                          : 1
                           Port7LinkMode                             : GE mode
                           EnableSpcr                                : Enabled
                           DataBits                                  : 8
                           Slot7BandWidth                            : Disabled
                           Slot14BandWidth                           : Disabled
                           UceErrLogEn                               : Enabled
                           StopBits                                  : 1
                           Slot30BandWidth                           : Disabled
                           FunnelSecond                              : 1
                           BootTypeOrder0                            : HardDiskDrive
                           Gicv4Version                              : 4.0
                           Port3BdNumber                             : 1024
                           DieInterleaving                           : Disabled
                           SpdDataRepair                             : Enabled
                           TerminalType                              : PC_ANSI
                           CAMargin                                  : Disabled
                           Port1LinkSpeed                            : 1GE
                           DpcEn                                     : Disabled
                           FlowControl                               : None
                           UFSEn                                     : Enabled
                           Port7SccAlgorithmMode                     : DCQCN
                           DefaultState                              : 0
                           Slot34BandWidth                           : Disabled
                           Port4SpeedDuplex                          : 1000M_FULL
                           Slot36BandWidth                           : Disabled
                           AddressMirrorNuma1                        : 0
                           AddressMirrorNuma3                        : 0
                           CeReportPolicyEn                          : Disabled
                           RankSparingEn                             : Disabled
                           Port2TqpNumber                            : 4
                           Port7TqpNumber                            : 0
                           Slot25BandWidth                           : Disabled
                           AdvanceDeviceCorrection                   : SR
                           CPUPrefetchConfig                         : Enabled
                           Port7LinkSpeed                            : NotSet
                           Port3SccAlgorithmMode                     : DCQCN
                           ColdBootFastSupport                       : Enabled
                           BootTypeOrder1                            : DVDROMDrive
                           PageIsolation                             : Disabled
                           Port3SpeedAndFEC                          : NotSet
                           AddressMirrorNuma7                        : 0
                           Port6AutoNegotitation                     : NotSet
                           IPv6DuidType                              : DUID-UUID
                           Port8SccAlgorithmMode                     : DCQCN"
    if [ "$1" == "920" ]; then
        init_bios_config "$default_bios_920_str" DEFAULT_920_BIOS
    elif [ "$1" == "920B" ] || [ "$1" == "920b" ]; then
        init_bios_config "$default_bios_920B_str" DEFAULT_920B_BIOS
    else
        return
    fi
}

# 打印BIOS配置与默认配置的比较结果
function print_result() {
    declare -n DEFAULT_BIOS
    if [ "$1" == "920" ]; then
        DEFAULT_BIOS=DEFAULT_920_BIOS
    elif [ "$1" == "920B" ] || [ "$1" == "920b" ]; then
        DEFAULT_BIOS=DEFAULT_920B_BIOS
    else
        return
    fi

    # 输出BIOS配置对比结果
    sorted_set=($(printf "%s\n" "${set[@]}" | sort))
    echo "---------------------------------关键差异点（KEY DIFFERENCES）-------------------------------------"
    printf "\n%-50s %-30s %-30s\n" "CONFIG ITEM" "VALUE" "DEFAULT"
    for item in "${sorted_set[@]}"; do
        if { [ -n "${my_bios_config[$item]}" ] && [ -n "${DEFAULT_BIOS[$item]}" ]; } && [ "${my_bios_config[$item]}" != "${DEFAULT_BIOS[$item]}" ]; then
            printf "\e[31m%-50s %-30s %-30s\e[0m\n" "$item" "${my_bios_config[$item]}" "${DEFAULT_BIOS[$item]}"
            print_set+=("$item")
        fi
    done
    if [ ${#print_set[@]} -eq 0 ]; then
        echo -e "\n\n\nnone\n\n\n"
    fi
    print_key_size=${#print_set[@]}
    echo "------------------------------------------------------------------------------------------------"

    echo "---------------------------------其他差异点（OTHER DIFFERENCES）----------------------------------"
    printf "\n%-50s %-30s %-30s\n" "CONFIG ITEM" "VALUE" "DEFAULT"
    for item in "${sorted_set[@]}"; do
        config="-"
        default_val="-"
        if [ -n "${my_bios_config[$item]}" ]; then
            config=${my_bios_config[$item]}
        fi
        if [ -n "${DEFAULT_BIOS[$item]}" ]; then
            default_val=${DEFAULT_BIOS[$item]}
        fi

        if [[ ! " ${print_set[@]} " =~ " $item " ]] && { [ "$config" == "-" ] || [ "$default_val" == "-" ]; }; then
            print_set+=("$item")
            printf "\033[33m%-50s %-30s %-30s\033[0m\n" "$item" "$config" "$default_val"
        fi
    done
    if [ ${#print_set[@]} -eq 0 ] || [ ${#print_set[@]} -eq $print_key_size ]; then
        echo -e "\n\n\nnone\n\n\n"
    fi
    echo "------------------------------------------------------------------------------------------------"

    if [ ! -z "$2" ] && [ "$2" == "all" ]; then
        echo "------------------------------相同配置（IDENTICAL CONFIGURATION）---------------------------------"
        printf "\n%-50s %-30s %-30s\n" "CONFIG ITEM" "VALUE" "DEFAULT"
        for item in "${sorted_set[@]}"; do

            if [[ ! " ${print_set[@]} " =~ " $item " ]]; then
                print_set+=("$item")
                printf "%-50s %-30s %-30s\n" "$item" "${my_bios_config[$item]}" "${DEFAULT_BIOS[$item]}"
            fi

        done
        echo "------------------------------------------------------------------------------------------------"
    fi
}

function main() {
    # 判断参数是否正确
    if [ ! -z "$1" ] ; then
        if [ "$1" != "920" ] && [ "$1" != "920B" ] && [ "$1" != "920b" ]; then
            echo "请输入正确的鲲鹏型号：920/920B"
            return
        fi
    fi

    # 初始化默认BIOS配置
    init_default_bios_config "$1"

    # 获取当前机器的BIOS配置
    if ! command -v BIOSTools &> /dev/null
    then
        echo -e "\e[31mPlease install kernel-devel and BIOSTools. \nYou can try to fix the problem by following the command below: \e[0m\n"
        echo -e "yum install kernel-devel -y"
        echo "yum install BIOSTools-Kunpeng-5.1.aarch64.rpm -y"
        return
    else
        echo "Get bios config of this device..."
        BIOSTools -D getbios > bios_config.txt
    fi

    this_device_config=$(sed '/INFO  :\|-----/d' ./bios_config.txt)
    init_bios_config "$this_device_config" my_bios_config

    ## 输出当前机器的BIOS配置与默认BIOS配置比较的结果
    print_result "$1" "$2"
}

main "$1" "$2"