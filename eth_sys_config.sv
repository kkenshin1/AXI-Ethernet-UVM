`ifndef ETH_SYS_CONFIG_SV
`define ETH_SYS_CONFIG_SV

class eth_sys_config extends uvm_object;

  eth_sys_rgm rgm ;
  eth_config eth_cfg ;
  virtual eth_sys_intf vif ; 

  `uvm_object_utils(eth_sys_config)

  extern function new(string name= "eth_sys_config") ;
  extern function void do_eth_config() ;
  extern function void do_eth_mst_config() ;
  extern function void do_eth_slv_config() ;

endclass: eth_sys_config

function eth_sys_config::new (string name = "eth_sys_config");
  super.new(name);
  eth_cfg = eth_config::type_id::create("eth_cfg");
  do_eth_config() ;
endfunction

//对于MASTER来说，source是TB，dest是DUT
//对于SLAVE来说，source是DUT，dest是TB
function void eth_sys_config::do_eth_config() ;
  do_eth_mst_config() ;
  do_eth_slv_config() ;
endfunction

function void eth_sys_config::do_eth_mst_config() ;
  eth_cfg.eth_mst_cfg.source_mac   =   `TB_MAC   ;
  eth_cfg.eth_mst_cfg.source_ip    =   `TB_IP    ;
  eth_cfg.eth_mst_cfg.dest_mac     =   `DUT_MAC  ;
  eth_cfg.eth_mst_cfg.dest_ip      =   `DUT_IP   ;
  eth_cfg.eth_mst_cfg.source_port  =   `TB_PORT  ;
  eth_cfg.eth_mst_cfg.dest_port    =   `DUT_PORT ; 
  eth_cfg.eth_mst_cfg.is_activate  =    1'b1     ;
  eth_cfg.eth_mst_cfg.rsp_activate =    1'b0     ;
endfunction

function void eth_sys_config::do_eth_slv_config() ;
  eth_cfg.eth_slv_cfg.source_mac   =   `DUT_MAC  ;
  eth_cfg.eth_slv_cfg.source_ip    =   `DUT_IP   ;
  eth_cfg.eth_slv_cfg.dest_mac     =   `TB_MAC   ;
  eth_cfg.eth_slv_cfg.dest_ip      =   `TB_IP    ;
  eth_cfg.eth_slv_cfg.source_port  =   `DUT_PORT ;
  eth_cfg.eth_slv_cfg.dest_port    =   `TB_PORT  ; 
  eth_cfg.eth_slv_cfg.is_activate  =    1'b1     ;
  eth_cfg.eth_slv_cfg.rsp_activate =    1'b0     ;
endfunction

`endif