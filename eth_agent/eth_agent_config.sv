`ifndef ETH_AGENT_CONFIG_SV
`define ETH_AGENT_CONFIG_SV

class eth_agent_config extends eth_base_config;

  bit [47:0] source_mac ;
  bit [31:0] source_ip  ;
  bit [47:0] dest_mac   ;
  bit [31:0] dest_ip    ;
  bit [31:0] gateway_ip = `GATEWAY_IP ;
  bit [31:0] subnet_mask = `SUBNET_MASK ;
  bit [15:0] source_port  ;
  bit [15:0] dest_port ; 

  bit is_activate = 1'b0 ;
  bit rsp_activate = 1'b0 ;     //loop back test mode

  virtual eth_intf vif ;

  `uvm_object_utils_begin(eth_agent_config)
    `uvm_field_int ( source_mac   , UVM_ALL_ON | UVM_BIN )
    `uvm_field_int ( source_ip    , UVM_ALL_ON | UVM_BIN )
    `uvm_field_int ( dest_mac     , UVM_ALL_ON | UVM_BIN )
    `uvm_field_int ( dest_ip      , UVM_ALL_ON | UVM_BIN )
    `uvm_field_int ( gateway_ip   , UVM_ALL_ON | UVM_BIN )
    `uvm_field_int ( subnet_mask  , UVM_ALL_ON | UVM_BIN )
    `uvm_field_int ( source_port  , UVM_ALL_ON | UVM_BIN )
    `uvm_field_int ( dest_port    , UVM_ALL_ON | UVM_BIN )
    `uvm_field_int ( is_activate  , UVM_ALL_ON | UVM_BIN )   
    `uvm_field_int ( rsp_activate , UVM_ALL_ON | UVM_BIN )   
  `uvm_object_utils_end
  
  extern function new(string name="eth_agent_config") ;
  extern function void set_interface(virtual eth_intf vif) ;
  extern function void set_srcmac(bit [47:0] mac) ;
  extern function void set_srcip(bit[31:0] ip) ;
  extern function void set_dstmac(bit [47:0] mac) ;
  extern function void set_dstip(bit[31:0] ip) ;
  extern function void set_activate(bit t) ;

endclass: eth_agent_config

function eth_agent_config::new (string name = "eth_agent_config");
  super.new(name);
endfunction

function void eth_agent_config::set_interface(virtual eth_intf vif) ;
  this.vif = vif ;
endfunction

function void eth_agent_config::set_srcmac(bit [47:0] mac) ;
  this.source_mac = mac ;
endfunction

function void eth_agent_config::set_srcip(bit[31:0] ip) ;
  this.source_ip = ip ;
endfunction

function void eth_agent_config::set_dstmac(bit [47:0] mac) ;
  this.dest_mac = mac ;
endfunction

function void eth_agent_config::set_dstip(bit[31:0] ip) ;
  this.dest_ip = ip ;
endfunction

function void eth_agent_config::set_activate(bit t) ;
  this.is_activate = t ;
endfunction

`endif