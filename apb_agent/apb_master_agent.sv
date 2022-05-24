`ifndef APB_MASTER_AGENT_SV
`define APB_MASTER_AGENT_SV

class apb_master_agent extends uvm_agent;

  `uvm_component_utils(apb_master_agent)
  
  apb_master_driver    driver;
  apb_master_sequencer sequencer;
  apb_master_monitor   monitor;
  virtual apb_intf     vif;

  extern function new (string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void set_interface(virtual apb_intf vif);

endclass: apb_master_agent


function apb_master_agent::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void apb_master_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  //获取apb interface并设置
  if(!uvm_config_db#(virtual apb_intf)::get(this,"","apb_vif", vif)) begin
    `uvm_fatal("GETVIF","cannot get vif handle from config DB")
  end
  //例化底层组件
  monitor = apb_master_monitor::type_id::create("monitor",this);
  sequencer = apb_master_sequencer::type_id::create("sequencer",this);
  driver = apb_master_driver::type_id::create("driver",this);
endfunction

function void apb_master_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase) ;
  this.set_interface(vif) ;
  driver.seq_item_port.connect(sequencer.seq_item_export); 
endfunction
  
function void apb_master_agent::set_interface(virtual apb_intf vif);
  monitor.set_interface(vif) ;
  sequencer.set_interface(vif) ;
  driver.set_interface(vif) ;
endfunction

`endif

