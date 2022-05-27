`ifndef ETH_MASTER_MONITOR_COMMON
`define ETH_MASTER_MONITOR_COMMON

class eth_master_monitor_common extends eth_bfm_common;
  `uvm_object_utils(eth_master_monitor_common)

  int m = 0 ;
  int k = 0 ;
  int err = 0 ;
  int arp_en ;
  mac_addr_type mac ;

  extern function new(string name="eth_master_monitor_common") ;
  extern task collect_transfer(ref eth_trans trans) ;
  extern task eth_receive(input bit reverse , output eth_trans_status status , ref eth_trans trans) ;

endclass: eth_master_monitor_common

function eth_master_monitor_common::new(string name="eth_master_monitor_common") ;
  super.new(name) ;
endfunction

//需要接收到完整的udp包才能结束一次监听
task eth_master_monitor_common::collect_transfer(ref eth_trans trans) ;
  eth_trans_status status ;   
  eth_receive(0 , status , trans) ;     //接收一帧以太网帧
  if(status==ARP_SUCCESS) begin     //如果是arp，并且成功
    eth_receive(1 , status , trans) ;   //接收arp响应包
    if(status==ARP_SUCCESS) eth_receive(0 , status , trans) ; //如果arp监听正确，再接收udp包
  end
  trans.eth_status = status ; //否则，接受的就是udp包，或者arp失败，这些都直接返回即可
endtask


//接收一帧以太网帧数据
task eth_master_monitor_common::eth_receive(input bit reverse , output eth_trans_status status , ref eth_trans trans) ;
  status = ALL_FAIL ;
  //ethernet一帧数据的开始
  if(reverse) begin
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
  end
  else begin
    @(posedge vif.txd_ctl) ;
    #10ps;
    mon_data[0][3:0] = vif.txd ;
    @(negedge vif.txd_clk) ;
    #10ps;
    mon_data[0][7:4] = vif.txd ;
    //前导码判断
    while(mon_data[0] != 8'hd5) begin
      @(posedge vif.txd_clk) ;
      #10ps;
      mon_data[0][3:0] = vif.txd ;
      @(negedge vif.txd_clk) ;
      #10ps;
      mon_data[0][7:4] = vif.txd ;
    end
    //接收目标MAC
    crc = 32'hffff_ffff ;     //开始crc校验
    m = `MAC_LEN ;
    receive_tx_eth_data(m) ;
    mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ;
  end
  case(mac)
    48'hff_ff_ff_ff_ff_ff: begin      //监听arp广播包，且必须是tb ip地址
      //记录源MAC
      trans.is_arp_valid = 1 ;
      trans.arp[0].eth_hdr.dest_mac = mac ;
      m = `MAC_LEN ;
      receive_tx_eth_data(m) ;
      trans.arp[0].eth_hdr.source_mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ; //得到应该响应的目标mac
      //开始接收帧类型、硬件类型、协议类型等信息，并存储到相应变量
      m = 10 ;
      receive_tx_eth_data(m) ;
      trans.arp[0].eth_hdr.eth_type = get_eth_type_enum({mon_data[0],mon_data[1]}) ;
      trans.arp[0].arp_hw_type = {mon_data[2],mon_data[3]} ;
      trans.arp[0].arp_prot_type = get_ip_prot_type_enum({mon_data[4],mon_data[5]}) ;
      trans.arp[0].arp_hw_addr_len = mon_data[6] ;
      trans.arp[0].arp_prot_addr_len = mon_data[7] ;
      trans.arp[0].arp_op_type = get_op_type_enum({mon_data[8],mon_data[9]}) ;
      //判断是否满足ARP协议要求，满足则继续接收
      if(trans.arp[0].eth_hdr.eth_type==ARP && trans.arp[0].arp_hw_type==32'h0000_0001 && trans.arp[0].arp_prot_type==IPv4 && trans.arp[0].arp_op_type==ARP_REQ) begin
        //依次接收源mac、源ip、目标mac、目标ip
        m = `MAC_LEN ;
        receive_tx_eth_data(m) ;
        trans.arp[0].source_mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ;
        m = `IP_LEN ;
        receive_tx_eth_data(m) ;
        trans.arp[0].source_ip = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
        m = `MAC_LEN ;
        receive_tx_eth_data(m) ;
        trans.arp[0].dest_mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ;
        m = `IP_LEN ;
        receive_tx_eth_data(m) ;
        trans.arp[0].dest_ip = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
        if(trans.arp[0].dest_ip == cfg.dest_ip) begin    //继续接收剩余的0，并且进行crc校验判断
          m = `PADDING_LEN ;
          receive_tx_eth_data(m) ;
          //crc_final = crc ;     //此时得到最终的crc校验结果，之后不再需要进行crc计算
          crc_final = crc32_final_reverse(crc) ;
          m = `CRC_LEN ;
          receive_tx_eth_data(m) ;
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
          @(negedge vif.txd_ctl) ;
          status = ARP_FAIL ;
          mon_data = {} ;
          return ;
        end
      end
      else begin
        @(negedge vif.txd_ctl) ;
        status = ARP_FAIL ;
        mon_data = {} ;
        return ;
      end
    end
    cfg.source_mac: begin     //监听arp响应包
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
    cfg.dest_mac: begin     //监听udp包
      //否则接收udp，并给eth_trans
      trans.eth_hdr.dest_mac = mac ; 
      //记录源MAC
      m = `MAC_LEN ;
      receive_tx_eth_data(m) ;
      trans.eth_hdr.source_mac = {mon_data[0],mon_data[1],mon_data[2],mon_data[3],mon_data[4],mon_data[5]} ; //得到应该响应的目标mac
      //接收以太网类型
      m = 2 ;
      receive_tx_eth_data(m) ;
      trans.eth_hdr.eth_type = get_eth_type_enum({mon_data[0],mon_data[1]}) ;
      if(trans.eth_hdr.eth_type==IP) begin
        //接收IP HDR 一次接收32bit--4字节
        m = `HDR_COMMON_LEN ;
        //IP header 0
        receive_tx_eth_data(m) ;
        trans.ip_hdr.ip_version = mon_data[0][3:0] ;
        trans.ip_hdr.ip_hdr_len = mon_data[0][7:4] ;
        trans.ip_hdr.ip_sevice_type = mon_data[1] ;
        trans.ip_hdr.ip_len = {mon_data[2],mon_data[3]} ;
        //IP header 1
        receive_tx_eth_data(m) ;
        trans.ip_hdr.ip_iden = {mon_data[0],mon_data[1]} ;
        trans.ip_hdr.ip_flag = mon_data[2][2:0] ;
        trans.ip_hdr.ip_offset = {mon_data[3],mon_data[2][7:3]};
        //IP header 2
        receive_tx_eth_data(m) ;
        trans.ip_hdr.ip_ttl = mon_data[0] ;
        trans.ip_hdr.ip_trans_prot_type = get_trans_prot_type_enum(mon_data[1]) ;
        trans.ip_hdr.ip_hdr_check_sum = {mon_data[2],mon_data[3]} ;
        //IP header 3
        receive_tx_eth_data(m) ;
        trans.ip_hdr.source_ip = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
        //IP header 4
        receive_tx_eth_data(m) ;
        trans.ip_hdr.dest_ip = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
        //继续接收UDP header
        //UDP header 0
        receive_tx_eth_data(m) ;
        trans.udp_hdr.source_port = {mon_data[0],mon_data[1]} ;
        trans.udp_hdr.dest_port = {mon_data[2],mon_data[3]} ;
        //UDP header 0
        receive_tx_eth_data(m) ;
        trans.udp_hdr.udp_len = {mon_data[0],mon_data[1]} ;
        trans.udp_hdr.udp_check_sum = {mon_data[2],mon_data[3]} ;
        //开始接收payload，先清空一下mon_data
        mon_data = {} ;
        m = trans.udp_hdr.udp_len - 8 ;
        if(m<`PADDING_LEN) m=`PADDING_LEN ;
        receive_tx_eth_data(m) ;  
        trans.payload = mon_data ;
        //最后进行CRC校验
        crc_final = crc32_final_reverse(crc) ;
        m = `CRC_LEN ;
        receive_tx_eth_data(m) ;
        trans.crc = {mon_data[0],mon_data[1],mon_data[2],mon_data[3]} ;
        if((trans.crc==~crc_final) && (trans.ip_hdr.dest_ip==cfg.dest_ip)) begin    //可以增加checksum等的判断
            status = ALL_SUCCESS ;
            mon_data = {} ;
            return ;
        end
        else begin
            status = UDP_FAIL ;
            mon_data = {} ;
            return ;
        end
      end
      else begin
        @(negedge vif.txd_ctl) ;
        status = ALL_FAIL ;
        mon_data={} ;
        return ;
      end
    end
    default: begin      //其他目标mac，不接收
      @(negedge vif.txd_ctl) ;
      status = ALL_FAIL ;
      mon_data = {} ;
      return ;
    end
  endcase
endtask

`endif