`ifndef ETH_DEFINES_SVH
`define ETH_DEFINES_SVH

//这里定义一些ethernet基本信息
//本地mac、目标mac、本地IP、目标IP
//子网掩码、目标网关
`define TB_MAC      48'h60_ab_c1_a2_d5_15
`define TB_IP       32'hc0_a8_00_03
`define DUT_MAC     48'h00_0a_35_01_fe_c0
`define DUT_IP      32'hc0_a8_00_02
`define GATEWAY_IP  32'hc0_a8_00_01
`define SUBNET_MASK 32'hff_ff_ff_00
`define TB_PORT     16'h1f_90
`define DUT_PORT    16'h1f_90
`define UDP_LEN     16'h20

//这里定义一些以太网发送过程中需要的固定数据
//报文标识
`define ARP_MSG     16'h0806    //ARP报文标识
`define IP_MSG      16'h0800    //IP报文标识
`define RARP_MSG    16'h8035    //RARP报文标识

//协议类型标识
`define IPv4_MSG    16'h0800    //IPv4
`define IPv6_MSG    16'h88DD    //IPv6

//上层协议
`define ICMP_PROT   8'h01       //ICMP协议
`define IGMP_PROT   8'h02       //IGMP协议
`define TCP_PROT    8'h06       //TCP协议
`define UDP_PROT    8'h11       //UDP协议
`define OSPF_PROT   8'h59       //OSPF协议


//这里定义以太网帧中某些数据字节数
`define MAC_LEN         6
`define IP_LEN          4
`define PADDING_LEN     18          //对于ARP包不够46B，需要补18B的0
`define CRC_LEN         4
`define HDR_COMMON_LEN  4



`endif