`ifndef ETH_TRANS_SV
`define ETH_TRANS_SV

//对于MASTER来说，source是TB，dest是DUT
//对于SLAVE来说，source是DUT，dest是TB
//这样只需要定义一个eth trans，而不用区分master和slave
//在sequencer传输时，只需要约束trans里面的source和dest mac和ip即可

//如果在传送过程中有arp包，那么就将arp添加到eth trans里面
class eth_trans extends uvm_sequence_item ;
  //可以通过外部约束，修改ethernet数据包具体内容
  rand mac_addr_type source_mac ;   
  rand mac_addr_type dest_mac ;    
  rand ip_addr_type source_ip ;
  rand ip_addr_type dest_ip ;
  rand port_id_type source_port ;
  rand port_id_type dest_port ;
  //实际需要的ethernet数据包
  rand arp_pkg arp[2] ;     //0--arp请求包 1--arp响应包
  rand int is_arp_valid ;   //是否有arp包
  rand udp_hdr_pkg udp_hdr ;  //udp header包
  rand ip_hdr_pkg ip_hdr ;  //ip header包
  rand eth_hdr_pkg eth_hdr ;  //eth header包，这里只记录udp的eth header 
  rand bit[7:0] payload[] ;   //数据包
  rand bit[31:0] crc ;    //crc校验
  //记录两次传送间隔
  rand int ipg ; 
  //记录传输状态
  rand eth_trans_status eth_status ;

  //约束arp包
  constraint arp_valid_cstr{
    soft is_arp_valid == 1'b0 ;
  }

  constraint arp_cstr{
    //ARP 请求包约束
    arp[0].eth_hdr.dest_mac == 48'hff_ff_ff_ff_ff_ff ;
    arp[0].eth_hdr.source_mac == source_mac ;
    arp[0].eth_hdr.eth_type == ARP ;
    arp[0].arp_hw_type == 1 ;
    arp[0].arp_prot_type == IPv4 ;
    arp[0].arp_hw_addr_len == 6 ;
    arp[0].arp_prot_addr_len == 4 ;
    arp[0].arp_op_type == ARP_REQ ;
    arp[0].source_mac == source_mac ;
    arp[0].source_ip == source_ip ;
    arp[0].dest_mac == 48'h00_00_00_00_00_00 ;
    arp[0].dest_ip == dest_ip ;
    //ARP 响应包约束
    arp[1].eth_hdr.dest_mac ==  source_mac ;
    arp[1].eth_hdr.source_mac == dest_mac ;
    arp[1].eth_hdr.eth_type == ARP ;
    arp[1].arp_hw_type == 1 ;
    arp[1].arp_prot_type == IPv4 ;
    arp[1].arp_hw_addr_len == 6 ;
    arp[1].arp_prot_addr_len == 4 ;
    arp[1].arp_op_type == ARP_ACK ;
    arp[1].source_mac == dest_mac ;
    arp[1].source_ip == dest_ip ;
    arp[1].dest_mac == source_mac ;
    arp[1].dest_ip == source_ip ;      
  };

  //约束udp header
  constraint udp_hdr_cstr{
    solve payload before udp_hdr.udp_len ;
    udp_hdr.source_port == source_port ;
    udp_hdr.dest_port == dest_port ;
    udp_hdr.udp_len ==  payload.size() + 8;
  };

  //约束ip header
  constraint ip_hdr_cstr{
    solve payload before ip_hdr.ip_len ;
    ip_hdr.ip_version == 4 ; 
    ip_hdr.ip_hdr_len == 5 ; 
    ip_hdr.ip_sevice_type == 0 ;  
    ip_hdr.ip_len == payload.size() + 28; 
    ip_hdr.ip_iden == 0 ;  
    ip_hdr.ip_flag == 0 ; 
    ip_hdr.ip_offset == 0 ; 
    ip_hdr.ip_ttl == 64 ;
    ip_hdr.ip_trans_prot_type == UDP;
    ip_hdr.source_ip == source_ip ;
    ip_hdr.dest_ip == dest_ip ;
  };

  //约束ethernet header
  constraint eth_hdr_cstr{
    eth_hdr.dest_mac == dest_mac ;
    eth_hdr.source_mac == source_mac ;
    eth_hdr.eth_type ==  IP ;
  };

  //约束payload 只约束size即可
  constraint payload_cstr{
    soft payload.size == 1 ;
  };


  `uvm_object_utils_begin(eth_trans)
    `uvm_field_int (source_mac , UVM_ALL_ON)
    `uvm_field_int (dest_mac , UVM_ALL_ON)
    `uvm_field_int (source_ip , UVM_ALL_ON)
    `uvm_field_int (dest_ip , UVM_ALL_ON)
    `uvm_field_int (source_port , UVM_ALL_ON)
    `uvm_field_int (dest_port , UVM_ALL_ON)
    `uvm_field_int (is_arp_valid , UVM_ALL_ON) 
    `uvm_field_int (udp_hdr , UVM_ALL_ON) 
    `uvm_field_int (eth_hdr , UVM_ALL_ON) 
    `uvm_field_array_int (payload , UVM_ALL_ON) 
    `uvm_field_int (ipg , UVM_ALL_ON)
    `uvm_field_int (crc , UVM_ALL_ON)
    if(is_arp_valid) begin
      `uvm_field_sarray_int (arp , UVM_ALL_ON) 
    end
    `uvm_field_enum (eth_trans_status, eth_status, UVM_ALL_ON)
  `uvm_object_utils_end

  extern function new(string name = "eth_transaction_inst") ;
  //随机化后计算ip hdr和udp hdr的checksum
  extern function void post_randomize() ;   
  extern function void udp_checksum_calculate() ;
  extern function void ip_checksum_calculate() ;
  
endclass: eth_trans

function eth_trans::new(string name = "eth_transaction_inst") ;
  super.new(name) ;
endfunction

function void eth_trans::post_randomize() ;
  udp_checksum_calculate() ;  
  ip_checksum_calculate() ;
endfunction

//计算udp校验和，需要包括udp header和payload
function void eth_trans::udp_checksum_calculate() ;
  bit [31:0] tmp = 'b0 ;
  //udp首部校验和计算
  tmp = source_ip[31:16] + source_ip[15:0] ;
  for(int i=0 ; i<8 ; i++) begin
    case(i)
      0 : tmp = tmp + dest_ip[15:0] ;
      1 : tmp = tmp + dest_ip[31:16] ;
      2 : tmp = tmp + 16'h0011 ;
      3 : tmp = tmp + udp_hdr.udp_len ;
      4 : tmp = tmp + udp_hdr.source_port ;
      5 : tmp = tmp + udp_hdr.dest_port ;
      6 : tmp = tmp + udp_hdr.udp_len ;
      7 : tmp = tmp + 16'h0000 ;
    endcase
  end
  //payload校验和计算
  for(int i=0 ; i<((payload.size()+1)/2) ; i++) begin
    if(i!=(((payload.size()+1)/2)-1)) begin
      tmp = tmp + {payload[2*i] , payload[2*i+1]} ;
    end
    else begin
      if(payload.size()%2)
        tmp = tmp + {payload[2*i] , 8'h0} ;
      else
        tmp = tmp + {payload[2*i] , payload[2*i+1]} ;
    end
  end
  //取反
  tmp = tmp[31:16] + tmp[15:0] ;
  tmp = tmp[15:0] + tmp[16] ;
  tmp = (~tmp) & 16'hffff ;
  udp_hdr.udp_check_sum = tmp[15:0] ;
endfunction

//计算ip校验和，只需要计算ip header
function void eth_trans::ip_checksum_calculate() ;
  bit [31:0] tmp = 'b0 ;
  tmp = {ip_hdr.ip_version,ip_hdr.ip_hdr_len,ip_hdr.ip_sevice_type} + ip_hdr.ip_len ;
  for(int i=0 ; i<8 ; i++) begin
    case(i)
      0 : tmp = tmp + ip_hdr.ip_iden ;
      1 : tmp = tmp + {ip_hdr.ip_flag , ip_hdr.ip_offset} ;
      2 : tmp = tmp + {ip_hdr.ip_ttl , get_trans_prot_type(ip_hdr.ip_trans_prot_type)} ;
      3 : tmp = tmp + 16'h0000 ;
      4 : tmp = tmp + ip_hdr.source_ip[31:16] ;
      5 : tmp = tmp + ip_hdr.source_ip[15:0] ;
      6 : tmp = tmp + ip_hdr.dest_ip[31:16] ;
      7 : tmp = tmp + ip_hdr.dest_ip[15:0] ;
    endcase
  end
  //取反
  tmp = tmp[31:16] + tmp[15:0] ;
  tmp = tmp[15:0] + tmp[16] ;
  tmp = (~tmp) & 16'hffff ;
  ip_hdr.ip_hdr_check_sum = tmp[15:0] ;
endfunction



`endif