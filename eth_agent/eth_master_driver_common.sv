`ifndef ETH_MASTER_DRIVER_COMMON_SV
`define ETH_MASTER_DRIVER_COMMON_SV

class eth_master_driver_common extends eth_bfm_common ;

  `uvm_object_utils(eth_master_driver_common)

  int m = 0 ;
  int k = 0 ;
  int err = 0 ;
  int arp_exist ;
  //这里定义接收arp包时需要记录的数据
  mac_addr_type mac ;
  ip_addr_type dut_ip ;
  ip_addr_type tb_ip ;
  eth_type_enum eth_type ;
  hw_type hw ;
  ip_prot_type_enum prot_type ;
  hw_addr_len_type hw_addr_len ;
  prot_addr_len_type prot_addr_len ;
  op_type_enum op_type ;

  mac_addr_type arp_cache [ip_addr_type] ;        //arp cache关联数组定义

  extern function new(string name="eth_master_driver_common") ;
  //arp请求接收与响应
  //接收以太网帧，并保存中间数据
  //arp_en：arp使能信号，该信号拉高表示只接收arp包
  //status：接收数据状态
  //eth master  driver发送以太网包
  extern task send_eth_trans(ref eth_trans trans) ;
  extern task eth_send(output eth_trans_status status , ref eth_trans trans) ;
  extern task arp_receive(output eth_trans_status status , ref eth_trans trans) ;

endclass: eth_master_driver_common


function eth_master_driver_common::new(string name="eth_master_driver_common") ;
  super.new(name) ;
endfunction

//eth master bfm发送数据包
task eth_master_driver_common::send_eth_trans(ref eth_trans trans) ;
  eth_trans_status status ;   
  eth_send(status , trans) ;
  if(status==ARP_SUCCESS) begin
    trans.eth_status = status ;
    arp_receive(status , trans) ;
    if(status==ARP_SUCCESS) begin
      eth_send(status , trans) ;
      trans.eth_status = status ;
    end
    else begin
      trans.eth_status = status ;
    end
  end
  else begin
    trans.eth_status = status ;
  end
endtask

task eth_master_driver_common::eth_send(output eth_trans_status status , ref eth_trans trans) ;
  repeat (20) @(posedge vif.txd_clk) ;
  status = ALL_FAIL ;
  //首先应判断arp_cache里面是否有目标mac
  arp_exist = arp_cache.exists(trans.dest_ip) ;
  if(arp_exist) mac = arp_cache[trans.dest_ip] ;
  else mac = 48'hff_ff_ff_ff_ff_ff ;
  if(~arp_exist && ~trans.is_arp_valid) trans.is_arp_valid=1 ;
  case(arp_exist)
    0 : begin     //发送arp包
      //发送前导码
      m = 7 ;
      for(k=0 ; k<m ; k++) send_data[k] = 8'h55 ;
      send_eth_data(m) ;
      send_data[0] = 8'hd5 ;
      send_eth_data(1) ;
      //此时开始crc校验
      crc = 32'hffff_ffff ;
      //发送目标mac
      m = `MAC_LEN ;
      for(k=0 ; k<m ; k++) send_data[k] = mac[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //发送源mac
      for(k=0 ; k<m ; k++) send_data[k] = trans.arp[0].eth_hdr.source_mac[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //根据接收到的信息，开始发送帧类型、硬件类型、协议类型等
      m = 10 ;
      for(k=0 ; k<m ; k++) begin
        case(k)
          0,1: send_data[k] = get_eth_type(trans.arp[0].eth_hdr.eth_type)[(2-k-1)*8+:8] ;
          2,3: send_data[k] = trans.arp[0].arp_hw_type[(2+2-k-1)*8+:8] ;
          4,5: send_data[k] = get_ip_prot_type(trans.arp[0].arp_prot_type)[(4+2-k-1)*8+:8] ;
          6  : send_data[k] = trans.arp[0].arp_hw_addr_len ;
          7  : send_data[k] = trans.arp[0].arp_prot_addr_len ;
          8,9: send_data[k] = get_op_type(trans.arp[0].arp_op_type)[(8+2-k-1)*8+:8] ;
        endcase
      end
      send_eth_data(m) ;
      //发送源mac
      m = `MAC_LEN ;
      for(k=0 ; k<m ; k++) send_data[k] = trans.arp[0].source_mac[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //发送源ip
      m = `IP_LEN ;
      for(k=0 ; k<m ; k++) send_data[k] = trans.arp[0].source_ip[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //发送目标mac
      m = `MAC_LEN ;
      for(k=0 ; k<m ; k++) send_data[k] = trans.arp[0].dest_mac[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //发送目标ip
      m = `IP_LEN ;
      for(k=0 ; k<m ; k++) send_data[k] = trans.arp[0].dest_ip[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //发送padding
      m = `PADDING_LEN ;
      for(k=0 ; k<m ; k++) send_data[k] = 8'h00 ;
      send_eth_data(m) ;
      //获取crc结果，并发送crc校验码
      //crc_final = crc ;
      crc_final = crc32_final_reverse(crc) ;
      m = `CRC_LEN ;
      for(k=0 ; k<m ;k++) send_data[k] = ~crc_final[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //arp包发送结束
      @(posedge vif.txd_clk) ;
      vif.txd_ctl <= 1'b0 ;
      send_data = {} ;
      status = ARP_SUCCESS ;
    end
    1 : begin   //发送udp包
      //发送前导码
      m = 7 ;
      for(k=0 ; k<m ; k++) send_data[k] = 8'h55 ;
      send_eth_data(m) ;
      send_data[0] = 8'hd5 ;
      send_eth_data(1) ;
      //此时开始crc校验
      crc = 32'hffff_ffff ;
      m = `MAC_LEN ;
      for(k=0 ; k<m ; k++) send_data[k] = mac[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //发送源mac
      for(k=0 ; k<m ; k++) send_data[k] = trans.eth_hdr.source_mac[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //以太网类型
      m = 2 ;
      for(k=0 ; k<m ; k++) send_data[k] = get_eth_type(trans.eth_hdr.eth_type)[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //开始发送IP HDR
      //IP header 0
      m = `HDR_COMMON_LEN ;
      for(k=0 ; k<m ; k++) begin
        case(k)
          0: begin 
            send_data[k][3:0] = trans.ip_hdr.ip_hdr_len ;
            send_data[k][7:4] = trans.ip_hdr.ip_version ;
          end 
          1: send_data[k] = trans.ip_hdr.ip_sevice_type ;
          2,3: send_data[k] = trans.ip_hdr.ip_len[(2+2-k-1)*8+:8] ;
        endcase
      end
      send_eth_data(m) ;
      //IP header 1
      for(k=0 ; k<m ; k++) begin
        case(k)
          0,1: send_data[k] = trans.ip_hdr.ip_iden[(2-k-1)*8+:8] ;
          2: begin
            send_data[k][2:0] = trans.ip_hdr.ip_flag ;
            send_data[k][7:3] = trans.ip_hdr.ip_offset[4:0] ;
          end
          3: send_data[k] = trans.ip_hdr.ip_offset[12:5] ;
        endcase
      end
      send_eth_data(m) ;
      //IP header 2
      for(k=0 ; k<m ; k++) begin
        case(k)
          0: send_data[k] = trans.ip_hdr.ip_ttl ;
          1: send_data[k] = get_trans_prot_type(trans.ip_hdr.ip_trans_prot_type) ;
          2,3: send_data[k] = trans.ip_hdr.ip_hdr_check_sum[(2+2-k-1)*8+:8] ;
        endcase
      end
      send_eth_data(m) ;
      //IP header 3
      for(k=0 ; k<m ; k++) send_data[k] = trans.ip_hdr.source_ip[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //IP header 4
      for(k=0 ; k<m ; k++) send_data[k] = trans.ip_hdr.dest_ip[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //开始发送UDP HDR
      //UDP header 0
      for(k=0 ; k<m ; k++) begin
        case(k)
          0,1: send_data[k] = trans.udp_hdr.source_port[(2-k-1)*8+:8] ;
          2,3: send_data[k] = trans.udp_hdr.dest_port[(2+2-k-1)*8+:8] ;
        endcase
      end
      send_eth_data(m) ;
      //UDP header 1
      for(k=0 ; k<m ; k++) begin
        case(k)
          0,1: send_data[k] = trans.udp_hdr.udp_len[(2-k-1)*8+:8] ;
          2,3: send_data[k] = trans.udp_hdr.udp_check_sum[(2+2-k-1)*8+:8] ;
        endcase
      end
      send_eth_data(m) ;   
      //开始发送payload
      m = trans.udp_hdr.udp_len - 8 ;
      send_data = {} ;
      send_data = trans.payload ; 
      if(m<`PADDING_LEN) begin
        m=`PADDING_LEN ;
        for(int p = 0 ; p < m-trans.payload.size ; p++) send_data[trans.payload.size+p] = 8'b0 ;
      end
      send_eth_data(m) ;
      //最后进行CRC校验
      crc_final = crc32_final_reverse(crc) ;
      m = `CRC_LEN ;
      for(k=0 ; k<m ;k++) send_data[k] = ~crc_final[(m-k-1)*8+:8] ;
      send_eth_data(m) ;
      //udp包发送结束
      @(posedge vif.txd_clk) ;
      vif.txd_ctl <= 1'b0 ;
      send_data = {} ;
      status = ALL_SUCCESS ;
    end
  endcase
endtask


//接收arp包
task eth_master_driver_common::arp_receive(output eth_trans_status status , ref eth_trans trans) ;
  status = ALL_FAIL ;
  //ethernet一帧数据的开始
  @(posedge vif.rxd_ctl) ;
  mon_data[0][3:0] = vif.rxd ;
  @(negedge vif.rxd_clk) ;
  mon_data[0][7:4] = vif.rxd ;
  //前导码判断
  while(mon_data[0] != 8'hd5) begin
    @(posedge vif.rxd_clk) ;
    mon_data[0][3:0] = vif.rxd ;
    @(negedge vif.rxd_clk) ;
    mon_data[0][7:4] = vif.rxd ;
  end
  //接收目标MAC
  crc = 32'hffff_ffff ;     //开始crc校验
  m = `MAC_LEN ;
  receive_eth_data(m) ;
  mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ;
  if(mac==cfg.source_mac) begin     //开始接收arp响应包
    //接收响应包目标mac
    trans.arp[1].eth_hdr.dest_mac = mac ;
    m = `MAC_LEN ;
    receive_eth_data(m) ;
    trans.arp[1].eth_hdr.source_mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ; //得到应该响应的目标mac
    //开始接收帧类型、硬件类型、协议类型等信息，并存储到相应变量
    m = 10 ;
    receive_eth_data(m) ;
    trans.arp[1].eth_hdr.eth_type = get_eth_type_enum({mon_data[0],mon_data[1]}) ;
    trans.arp[1].arp_hw_type = {mon_data[2],mon_data[3]} ;
    trans.arp[1].arp_prot_type = get_ip_prot_type_enum({mon_data[4],mon_data[5]}) ;
    trans.arp[1].arp_hw_addr_len = mon_data[6] ;
    trans.arp[1].arp_prot_addr_len = mon_data[7] ;
    trans.arp[1].arp_op_type = get_op_type_enum({mon_data[8],mon_data[9]}) ;
    //判断是否满足ARP协议要求，满足则继续接收
    if(trans.arp[1].eth_hdr.eth_type==ARP && trans.arp[1].arp_hw_type==32'h0000_0001 && trans.arp[1].arp_prot_type==IPv4 && trans.arp[1].arp_op_type==ARP_ACK) begin
      //依次接收源mac、源ip、目标mac、目标ip
      m = `MAC_LEN ;
      receive_eth_data(m) ;
      trans.arp[1].source_mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ;
      m = `IP_LEN ;
      receive_eth_data(m) ;
      trans.arp[1].source_ip = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
      m = `MAC_LEN ;
      receive_eth_data(m) ;
      trans.arp[1].dest_mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ;
      m = `IP_LEN ;
      receive_eth_data(m) ;
      trans.arp[1].dest_ip = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
      m = `PADDING_LEN ;
      receive_eth_data(m) ;
      //crc_final = crc ;     //此时得到最终的crc校验结果，之后不再需要进行crc计算
      crc_final = crc32_final_reverse(crc) ;
      m = `CRC_LEN ;
      receive_eth_data(m) ;
      if({mon_data[0],mon_data[1],mon_data[2],mon_data[3]} == ~crc_final) begin
        //FCS good
        //记录到arp cache
        arp_cache[trans.arp[1].source_ip] = trans.arp[1].source_mac ;
        status = ARP_SUCCESS ;
        mon_data = {} ;
        return ;
      end
      else begin
        //FCS bad
        status = ARP_FAIL ;
        mon_data = {} ;
        return ;
      end
    end
    else begin
      @(negedge vif.rxd_ctl) ;
      status = ARP_FAIL ;
      mon_data = {} ;
      return ;
    end
  end
  else begin
    @(negedge vif.rxd_ctl) ;
    status = ARP_FAIL ;
    mon_data = {} ;
    return ;
  end
endtask

`endif