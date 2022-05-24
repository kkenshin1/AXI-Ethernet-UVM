`ifndef APB_MASTER_SEQUENCER_SV
`define APB_MASTER_SEQUENCER_SV

class apb_master_sequencer extends uvm_sequencer #(apb_trans);

  `uvm_component_utils(apb_master_sequencer)

  virtual apb_intf vif;

  extern function new (string name, uvm_component parent);
  extern function void set_interface(virtual apb_intf vif) ;

endclass: apb_master_sequencer


function apb_master_sequencer::new (string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void apb_master_sequencer::set_interface(virtual apb_intf vif);
  this.vif = vif ;
endfunction

`endif 


