`ifndef AXI_MASTER_AGENT_SV
`define AXI_MASTER_AGENT_SV

class axi_master_agent extends uvm_agent;

  `uvm_component_utils(axi_master_agent)
  
  axi_master_driver    driver;
  axi_master_sequencer sequencer;
  axi_master_monitor   monitor;
  virtual axi_intf     vif;

  extern function new (string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void set_interface(virtual axi_intf vif);

endclass: axi_master_agent


function axi_master_agent::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void axi_master_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  //获取axi interface并设置
  if(!uvm_config_db#(virtual axi_intf)::get(this,"","axi_vif", vif)) begin
    `uvm_fatal("GETVIF","cannot get vif handle from config DB")
  end
  //例化底层组件
  monitor = axi_master_monitor::type_id::create("monitor",this);
  sequencer = axi_master_sequencer::type_id::create("sequencer",this);
  driver = axi_master_driver::type_id::create("driver",this);
endfunction

function void axi_master_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase) ;
  this.set_interface(vif) ;
  driver.seq_item_port.connect(sequencer.seq_item_export); 
endfunction
  
function void axi_master_agent::set_interface(virtual axi_intf vif);
  monitor.set_interface(vif) ;
  sequencer.set_interface(vif) ;
  driver.set_interface(vif) ;
endfunction

`endif