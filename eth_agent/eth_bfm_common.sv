`ifndef ETH_BFM_COMMON_SV
`define ETH_BFM_COMMON_SV

class eth_bfm_common extends uvm_object;

  virtual eth_intf vif;
  eth_agent_config cfg;

  bit [7:0] mon_data[$] = {} ;
  bit [7:0] send_data[$] = {} ;
  bit [31:0] crc ;
  bit [31:0] crc_final ;

  `uvm_object_utils(eth_bfm_common)

  extern function new(string name="eth_bfm_common");
  extern virtual function void set_interface(virtual eth_intf vif);
  extern virtual task reconfigure_via_task(eth_agent_config cfg) ;
  extern virtual task wait_for_reset();
  extern virtual task reset_listener() ;
  //接收以太网数据，x表示接收多少字节
  extern virtual task receive_eth_data(int x) ;
  //监听tx端口数据
  extern virtual task receive_tx_eth_data(int x) ;
  //data表示发送的数据，x表示重复次数
  extern virtual task send_eth_data(int x) ;
  extern virtual function void crc32_compute(bit[7:0]data , ref bit[31:0]crc_ref) ;
  extern virtual function bit[31:0] crc32_final_reverse(bit[31:0]crc_in) ;

endclass: eth_bfm_common

function eth_bfm_common::new(string name = "eth_bfm_common");
  super.new(name);
endfunction

function void eth_bfm_common::set_interface(virtual eth_intf vif);
  this.vif = vif;
endfunction

task eth_bfm_common::reconfigure_via_task(eth_agent_config cfg);
  this.cfg = cfg;
endtask

task eth_bfm_common::wait_for_reset();
  vif.wait_rstn_release() ;
endtask

task eth_bfm_common::reset_listener();
  wait_for_reset() ;
  vif.txd_ctl <= 'b0 ;
  vif.txd <= 'b0 ;
endtask

function void eth_bfm_common::crc32_compute(bit[7:0]data , ref bit[31:0]crc_ref) ;
  bit [31:0] crc_tmp ;
  bit tmp ;
  //reverse data
  for(int j = 0 ; j < 4 ; j++) begin
    tmp = data[j] ;
    data[j] = data[7-j] ;
    data[7-j] = tmp ;
  end

  crc_tmp = crc_ref ^ {data,24'h0} ;

  for(int i = 0 ; i < 8 ; i++) begin
    if(crc_tmp[31])
      crc_tmp = (crc_tmp<<1) ^ 32'h04c1_1db7 ;
    else 
      crc_tmp = crc_tmp << 1 ;
  end
  crc_ref = crc_tmp ;
  return ;
endfunction

function bit[31:0] eth_bfm_common::crc32_final_reverse(bit [31:0] crc_in) ;
  bit tmp ;
  bit [7:0] tmp_q ;
  //reverse
  for(int i = 0 ; i < 16 ; i++) begin
    tmp = crc_in[i] ;
    crc_in[i] = crc_in[31-i] ;
    crc_in[31-i] = tmp ;
  end
  //适配以太网接收数据
  //这里数据按照8bit翻转
  for(int j = 0 ; j < 2 ; j++) begin
    tmp_q = crc_in[j*8+:8] ;
    crc_in[j*8+:8] = crc_in[(3-j)*8+:8] ;
    crc_in[(3-j)*8+:8] = tmp_q ;
  end
  return crc_in ;
endfunction

task eth_bfm_common::receive_eth_data(int x);
  int i = 0;
  while(i!=x) begin
    @(posedge vif.rxd_clk) ;
    mon_data[i][3:0] = vif.rxd ;
    @(negedge vif.rxd_clk) ;
    mon_data[i][7:4] = vif.rxd ;
    crc32_compute(mon_data[i] , crc) ;
    i++ ;
  end
endtask

task eth_bfm_common::send_eth_data(int x) ;
  int i = 0 ;
  while(i!=x) begin
    @(posedge vif.txd_clk) ;
    vif.txd_ctl <= 1'b1 ;     //直接拉高使能信号
    vif.txd <= send_data[i][3:0] ;
    @(negedge vif.txd_clk) ;
    vif.txd <= send_data[i][7:4] ;
    crc32_compute(send_data[i] , crc) ;
    i++ ;
  end
endtask

task eth_bfm_common::receive_tx_eth_data(int x);
  int i = 0;
  while(i!=x) begin
    @(posedge vif.txd_clk) ;
    #10ps;
    mon_data[i][3:0] = vif.txd ;
    @(negedge vif.txd_clk) ;
    #10ps;
    mon_data[i][7:4] = vif.txd ;
    crc32_compute(mon_data[i] , crc) ;
    i++ ;
  end
endtask


`endif

