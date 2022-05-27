`ifndef ETH_SYS_VIRTUAL_SEQUENCER_SV
`define ETH_SYS_VIRTUAL_SEQUENCER_SV

class eth_sys_virtual_sequencer extends uvm_sequencer;
  apb_master_sequencer apb_mst_sqr ;
  axi_master_sequencer axi_mst_sqr ;
  eth_slave_sequencer eth_slv_sqr ;
  eth_master_sequencer eth_mst_sqr ;
  eth_sys_config cfg ;
  eth_sys_rgm rgm ;
  virtual eth_sys_intf vif ; 

  `uvm_component_utils(eth_sys_virtual_sequencer)

  function new (string name = "eth_sys_virtual_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(eth_sys_config)::get(this, "", "cfg", cfg)) begin
      `uvm_error("build_phase", "Unable to get rkv_i2c_config from uvm_config_db")
    end
    vif = cfg.vif;
    rgm = cfg.rgm;
  endfunction

endclass: eth_sys_virtual_sequencer

`endif
