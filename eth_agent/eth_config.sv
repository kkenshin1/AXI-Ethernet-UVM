`ifndef ETH_CONFIG_SV
`define ETH_CONFIG_SV

class eth_config extends uvm_object;

  eth_agent_config eth_mst_cfg ;
  eth_agent_config eth_slv_cfg ;

  `uvm_object_utils(eth_config)

  extern function new(string name="eth_config") ;
  extern function void set_interface(virtual eth_intf vif) ;

endclass: eth_config


function eth_config::new (string name = "eth_config");
  super.new(name);
  eth_mst_cfg = eth_agent_config::type_id::create("eth_master_agent_configuration");
  eth_slv_cfg = eth_agent_config::type_id::create("eth_slave_agent_configuration");
endfunction

function void eth_config::set_interface(virtual eth_intf vif) ;
  eth_mst_cfg.set_interface(vif) ;
  eth_slv_cfg.set_interface(vif) ;
endfunction

`endif