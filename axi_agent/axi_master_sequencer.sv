`ifndef AXI_MASTER_SEQUENCER_SV
`define AXI_MASTER_SEQUENCER_SV

class axi_master_sequencer extends uvm_sequencer #(axi_trans);

  `uvm_component_utils(axi_master_sequencer)

  virtual axi_intf vif;

  extern function new (string name, uvm_component parent);
  extern function set_interface(virtual axi_intf vif) ;

endclass: axi_master_sequencer


function axi_master_sequencer::new (string name, uvm_component parent);
  super.new(name, parent);
endfunction

function axi_master_sequencer::set_interface(virtual axi_intf vif);
  this.vif = vif ;
endfunction

`endif 