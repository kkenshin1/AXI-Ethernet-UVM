`ifndef ETH_TYPES_SV
`define ETH_TYPES_SV

//定义以太网数据包需要的数据类型
typedef bit[47:0] mac_addr_type ;
typedef bit[31:0] ip_addr_type ;

//定义ARP包需要的数据类型
typedef bit[15:0] hw_type ;   //硬件类型 以太网类型为1
typedef bit[7:0] hw_addr_len_type ;   //硬件地址长度，以字节为单位，48bit的mac地址，该值为6
typedef bit[7:0] prot_addr_len_type ;  //协议地址长度，以字节为单位，32bit的ip地址，该值为4

//定义UDP包需要的数据类型
typedef bit[15:0] port_id_type ;    //端口号
typedef bit[15:0] udp_len_type ;    //udp报文长度(payload+udp_hdr)
typedef bit[15:0] check_sum_type ;  //校验和

//定义IP包需要的数据类型
typedef bit[3:0] version_type ;   //版本号，IPv4中普遍值为4
typedef bit[3:0] hdr_len_type ;   //IP报文首部长度，以字节为单位，对于IP报文，该值为5
typedef bit[7:0] service_type ;   //服务类型，这里一般不使用
typedef bit[15:0] ip_len_type ;   //ip报文长度(payload+ip_hdr)
typedef bit[15:0] ip_iden_type ;  //ip标识
typedef bit[2:0] ip_flag_type ;   //ip标志，bit[0]--MF,bit[1]--DF
typedef bit[12:0] ip_offset_type ;  //片偏移
typedef bit[7:0] ip_ttl_type ;    //生存实践

//以太网帧类型
typedef enum bit[15:0] 
{  
  ARP  = `ARP_MSG ,
  RARP = `RARP_MSG ,
  IP   = `IP_MSG 
} eth_type_enum;

//协议类型
typedef enum bit[15:0]
{
  IPv4 = `IPv4_MSG ,
  IPv6 = `IPv6_MSG
} ip_prot_type_enum ;

//操作码
typedef enum bit[15:0]
{
  ARP_REQ = 1 ,   //ARP请求
  ARP_ACK = 2     //ARP响应
} op_type_enum ;

//传输层协议类型，即IP报文中的上层协议
typedef enum bit[7:0]
{
  ICMP = `ICMP_PROT ,
  IGMP = `IGMP_PROT ,
  TCP  = `TCP_PROT ,
  UDP  = `UDP_PROT ,
  OSPF = `OSPF_PROT
} trans_prot_type_enum ;

typedef enum bit[2:0]
{
  ARP_SUCCESS ,
  ARP_FAIL ,
  UDP_SUCCESS ,
  UDP_FAIL ,
  ALL_SUCCESS ,
  ALL_FAIL
} eth_trans_status ;

//以太网header结构体
typedef struct packed {
  mac_addr_type dest_mac ;
  mac_addr_type source_mac ;
  eth_type_enum eth_type ;
} eth_hdr_pkg;

//udp header结构体
typedef struct packed {
  port_id_type source_port ;
  port_id_type dest_port ;
  udp_len_type udp_len ;
  check_sum_type udp_check_sum ;
} udp_hdr_pkg ;

typedef struct packed {
  version_type ip_version ; 
  hdr_len_type ip_hdr_len ; 
  service_type ip_sevice_type ;  
  ip_len_type ip_len ; 
  ip_iden_type ip_iden ;  
  ip_flag_type ip_flag ; 
  ip_offset_type ip_offset ; 
  ip_ttl_type ip_ttl ;
  trans_prot_type_enum ip_trans_prot_type ;
  check_sum_type ip_hdr_check_sum ;
  ip_addr_type source_ip ;
  ip_addr_type dest_ip ;
} ip_hdr_pkg ;

//arp包结构体
//这里选择将eth hdr直接放到arp pkg中，因为transactions里面的eth hdr只负责接收udp包的eth hdr
typedef struct packed {
  eth_hdr_pkg eth_hdr ;
  hw_type arp_hw_type ;     //硬件类型
  ip_prot_type_enum arp_prot_type ;  //协议类型
  hw_addr_len_type arp_hw_addr_len ; //硬件地址长度
  prot_addr_len_type arp_prot_addr_len ; //协议地址长度
  op_type_enum arp_op_type ;  //arp报文类型
  mac_addr_type source_mac ;
  ip_addr_type source_ip ;
  mac_addr_type dest_mac ;
  ip_addr_type dest_ip ;
} arp_pkg ;


function eth_type_enum get_eth_type_enum(bit[15:0] eth_type) ;
  case(eth_type)
    `ARP_MSG  : get_eth_type_enum = ARP ;
    `RARP_MSG : get_eth_type_enum = RARP ;
    `IP_MSG   : get_eth_type_enum = IP ;
    default   : $display("Error:Invalid eth_type");
  endcase
endfunction

function ip_prot_type_enum get_ip_prot_type_enum(bit[15:0] ip_prot_type) ;
  case(ip_prot_type)
    `IPv4_MSG : get_ip_prot_type_enum = IPv4 ;
    `IPv6_MSG : get_ip_prot_type_enum = IPv6 ;
    default   : $display("Error:Invalid ip_prot_type");
  endcase
endfunction

function op_type_enum get_op_type_enum(bit[15:0] op_type) ;
  case(op_type)
    1 : get_op_type_enum = ARP_REQ ;
    2 : get_op_type_enum = ARP_ACK ;
    default : $display("Error:Invalid op_type");
  endcase
endfunction

function trans_prot_type_enum get_trans_prot_type_enum(bit[7:0] trans_prot_type) ;
  case(trans_prot_type)
    `ICMP_PROT : get_trans_prot_type_enum = ICMP ;
    `IGMP_PROT : get_trans_prot_type_enum = IGMP ;
    `TCP_PROT  : get_trans_prot_type_enum = TCP  ;
    `UDP_PROT  : get_trans_prot_type_enum = UDP  ;
    `OSPF_PROT : get_trans_prot_type_enum = OSPF  ;
    default    : $display("Error:Invalid trans_prot_type");
  endcase
endfunction


function bit[15:0] get_eth_type(eth_type_enum eth_type) ;
  case(eth_type)
    ARP  : get_eth_type = `ARP_MSG ;
    RARP : get_eth_type = `RARP_MSG ;
    IP   : get_eth_type = `IP_MSG  ;
    default : $display("Error:Invalid eth_type enum");
  endcase
endfunction

function bit[15:0] get_ip_prot_type(ip_prot_type_enum ip_prot_type) ;
  case(ip_prot_type)
    IPv4 : get_ip_prot_type = `IPv4_MSG ;
    IPv6 : get_ip_prot_type = `IPv6_MSG ;
    default : $display("Error:Invalid ip_prot_type enum");
  endcase
endfunction

function bit[15:0] get_op_type(op_type_enum op_type) ;
  case(op_type)
    ARP_REQ : get_op_type = 1 ;
    ARP_ACK : get_op_type = 2 ;
    default : $display("Error:Invalid op_type enum");
  endcase
endfunction

function bit[7:0] get_trans_prot_type(trans_prot_type_enum trans_prot_type) ;
  case(trans_prot_type)
    ICMP : get_trans_prot_type = `ICMP_PROT ;
    IGMP : get_trans_prot_type = `IGMP_PROT ;
    TCP  : get_trans_prot_type = `TCP_PROT  ;
    UDP  : get_trans_prot_type = `UDP_PROT  ;
    OSPF : get_trans_prot_type = `OSPF_PROT  ;
    default : $display("Error:Invalid trans_prot_type enum");
  endcase
endfunction


`endif