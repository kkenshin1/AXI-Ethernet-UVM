`ifndef ETH_SLAVE_DRIVER_COMMON_SV
`define ETH_SLAVE_DRIVER_COMMON_SV

class eth_slave_driver_common extends eth_bfm_common ;

  `uvm_object_utils(eth_slave_driver_common)

  int m = 0 ;
  int k = 0 ;
  int err = 0 ;
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

  extern function new(string name="eth_slave_driver_common") ;
  //arp请求接收与响应
  extern task arp_response() ;
  //接收以太网帧，并保存中间数据
  //arp_en：arp使能信号，该信号拉高表示只接收arp包
  //status：接收数据状态
  extern task eth_receive(bit udp_en , output eth_trans_status status , ref eth_trans trans) ;
  //发送arp响应包
  extern task arp_send() ;
  //收集eth trans包，用于loop back test
  extern task send_eth_trans(ref eth_trans trans) ;

endclass: eth_slave_driver_common


function eth_slave_driver_common::new(string name="eth_slave_driver_common") ;
  super.new(name) ;
endfunction

//arp请求接收并响应
task eth_slave_driver_common::arp_response() ;
  eth_trans_status status ;   
  bit udp_en = 0 ;    
  eth_trans trans ;  
  eth_receive(udp_en , status , trans) ;
  if(status==ARP_SUCCESS) arp_send() ;
endtask

//接收一帧以太网帧数据
task eth_slave_driver_common::eth_receive(bit udp_en , output eth_trans_status status , ref eth_trans trans) ;
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
  case(mac)
    48'hff_ff_ff_ff_ff_ff: begin      //ARP广播包，需要进一步判断是否对应当前MAC
      //记录源MAC
      m = `MAC_LEN ;
      receive_eth_data(m) ;
      mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ; //得到应该响应的目标mac
      //开始接收帧类型、硬件类型、协议类型等信息，并存储到相应变量
      m = 10 ;
      receive_eth_data(m) ;
      eth_type = get_eth_type_enum({mon_data[0],mon_data[1]}) ;
      hw = {mon_data[2],mon_data[3]} ;
      prot_type = get_ip_prot_type_enum({mon_data[4],mon_data[5]}) ;
      hw_addr_len = mon_data[6] ;
      prot_addr_len = mon_data[7] ;
      op_type = get_op_type_enum({mon_data[8],mon_data[9]}) ;
      //判断是否满足ARP协议要求，满足则继续接收
      if(eth_type==ARP && hw==32'h0000_0001 && prot_type==IPv4 && op_type==ARP_REQ) begin
        //依次接收源mac、源ip、目标mac、目标ip
        m = `MAC_LEN ;
        receive_eth_data(m) ;
        mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ;
        m = `IP_LEN ;
        receive_eth_data(m) ;
        dut_ip = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
        m = `MAC_LEN ;
        receive_eth_data(m) ;
        m = `IP_LEN ;
        receive_eth_data(m) ;
        tb_ip = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
        if(tb_ip == cfg.dest_ip) begin    //继续接收剩余的0，并且进行crc校验判断
          m = `PADDING_LEN ;
          receive_eth_data(m) ;
          //crc_final = crc ;     //此时得到最终的crc校验结果，之后不再需要进行crc计算
          crc_final = crc32_final_reverse(crc) ;
          m = `CRC_LEN ;
          receive_eth_data(m) ;
          if({mon_data[0],mon_data[1],mon_data[2],mon_data[3]} == ~crc_final) begin
            //FCS good
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
    end
    cfg.dest_mac: begin     //如果是目标mac，则接收对应udp包
      if(~udp_en) begin      //如果开arp en，表示不再接收udp包
        @(negedge vif.rxd_ctl) ;
        status = ALL_FAIL ;
        mon_data = {} ;
        return ;
      end
      else begin            //否则接收udp，并给eth_trans
        trans.eth_hdr.dest_mac = mac ; 
        //记录源MAC
        m = `MAC_LEN ;
        receive_eth_data(m) ;
        trans.eth_hdr.source_mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ; //得到应该响应的目标mac
        //接收以太网类型
        m = 2 ;
        receive_eth_data(m) ;
        trans.eth_hdr.eth_type = get_eth_type_enum({mon_data[0],mon_data[1]}) ;
        //接收IP HDR 一次接收32bit--4字节
        m = `HDR_COMMON_LEN ;
        //IP header 0
        receive_eth_data(m) ;
        trans.ip_hdr.ip_version = mon_data[0][3:0] ;
        trans.ip_hdr.ip_hdr_len = mon_data[0][7:4] ;
        trans.ip_hdr.ip_sevice_type = mon_data[1] ;
        trans.ip_hdr.ip_len = {mon_data[2],mon_data[3]} ;
        //IP header 1
        receive_eth_data(m) ;
        trans.ip_hdr.ip_iden = {mon_data[0],mon_data[1]} ;
        trans.ip_hdr.ip_flag = mon_data[2][2:0] ;
        trans.ip_hdr.ip_offset = {mon_data[3],mon_data[2][7:3]};
        //IP header 2
        receive_eth_data(m) ;
        trans.ip_hdr.ip_ttl = mon_data[0] ;
        trans.ip_hdr.ip_trans_prot_type = get_trans_prot_type_enum(mon_data[1]) ;
        trans.ip_hdr.ip_hdr_check_sum = {mon_data[2],mon_data[3]} ;
        //IP header 3
        receive_eth_data(m) ;
        trans.ip_hdr.source_ip = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
        //IP header 4
        receive_eth_data(m) ;
        trans.ip_hdr.dest_ip = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
        //继续接收UDP header
        //UDP header 0
        receive_eth_data(m) ;
        trans.udp_hdr.source_port = {mon_data[0],mon_data[1]} ;
        trans.udp_hdr.dest_port = {mon_data[2],mon_data[3]} ;
        //UDP header 1
        receive_eth_data(m) ;
        trans.udp_hdr.udp_len = {mon_data[0],mon_data[1]} ;
        trans.udp_hdr.udp_check_sum = {mon_data[2],mon_data[3]} ;
        //开始接收payload，先清空一下mon_data
        mon_data = {} ;
        m = trans.udp_hdr.udp_len - 8 ;
        if(m<`PADDING_LEN) m=`PADDING_LEN ;
        receive_eth_data(m) ;  
        trans.payload = mon_data ;
        //最后进行CRC校验
        //crc_final = crc ;
        crc_final = crc32_final_reverse(crc) ;
        m = `CRC_LEN ;
        receive_eth_data(m) ;
        trans.crc = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
        if((trans.crc==~crc_final) && (trans.ip_hdr.dest_ip==cfg.dest_ip)) begin    //可以增加checksum等的判断
            status = UDP_SUCCESS ;
            mon_data = {} ;
            return ;
        end
        else begin
            status = UDP_FAIL ;
            mon_data = {} ;
            return ;
        end
      end
    end
    default: begin      //其他目标mac，不接收
      @(negedge vif.rxd_ctl) ;
      status = ALL_FAIL ;
      mon_data = {} ;
      return ;
    end
  endcase
endtask

task eth_slave_driver_common::arp_send() ;
  repeat (10) @(posedge vif.txd_clk) ;
  //发送前导码
  m = 7 ;
  send_data[0] = 8'h55 ;
  for(k=0 ; k<m ; k++) send_eth_data(1) ;
  send_data[0] = 8'hd5 ;
  send_eth_data(1) ;
  //此时开始crc校验
  crc = 32'hffff_ffff ;
  //发送目标mac
  m = `MAC_LEN ;
  for(k=0 ; k<m ; k++) send_data[k] = mac[(m-k-1)*8+:8] ;
  send_eth_data(m) ;
  //发送源mac
  for(k=0 ; k<m ; k++) send_data[k] = cfg.dest_mac[(m-k-1)*8+:8] ;
  send_eth_data(m) ;
  //根据接收到的信息，开始发送帧类型、硬件类型、协议类型等
  m = 10 ;
  for(k=0 ; k<m ; k++) begin
    case(k)
      0,1: send_data[k] = get_eth_type(eth_type)[(2-k-1)*8+:8] ;
      2,3: send_data[k] = hw[(2+2-k-1)*8+:8] ;
      4,5: send_data[k] = get_ip_prot_type(prot_type)[(4+2-k-1)*8+:8] ;
      6  : send_data[k] = hw_addr_len ;
      7  : send_data[k] = prot_addr_len ;
      8,9: send_data[k] = get_op_type(ARP_ACK)[(8+2-k-1)*8+:8] ;
    endcase
  end
  send_eth_data(m) ;
  //发送源mac
  m = `MAC_LEN ;
  for(k=0 ; k<m ; k++) send_data[k] = cfg.dest_mac[(m-k-1)*8+:8] ;
  send_eth_data(m) ;
  //发送源ip
  m = `IP_LEN ;
  for(k=0 ; k<m ; k++) send_data[k] = cfg.dest_ip[(m-k-1)*8+:8] ;
  send_eth_data(m) ;
  //发送目标mac
  m = `MAC_LEN ;
  for(k=0 ; k<m ; k++) send_data[k] = mac[(m-k-1)*8+:8] ;
  send_eth_data(m) ;
  //发送目标ip
  m = `IP_LEN ;
  for(k=0 ; k<m ; k++) send_data[k] = dut_ip[(m-k-1)*8+:8] ;
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
endtask

task eth_slave_driver_common::send_eth_trans(ref eth_trans trans) ;
  eth_trans_status status ;   
  bit udp_en = 1 ;    
  eth_receive(udp_en , status , trans) ;   //接收数据，判断是否有arp包
  if(status==ARP_SUCCESS) begin                  //发送arp响应，并再接收udp包
    trans.eth_status = status ;
    arp_send() ;
    eth_receive(udp_en , status , trans) ;
    if(status==UDP_SUCCESS) begin
      trans.eth_status = ALL_SUCCESS ;
    end
    else begin
      trans.eth_status = status ;
    end
  end 
  else begin
    trans.eth_status = status ;
  end
endtask


`endif