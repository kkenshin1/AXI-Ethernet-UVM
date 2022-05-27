`ifndef ETH_SLAVE_AGENT_SV
`define ETH_SLAVE_AGENT_SV

class eth_slave_agent extends uvm_agent;

  eth_agent_config cfg;
  // The following are the verification components that make up
  // this agent
  eth_slave_driver driver;
  eth_slave_sequencer sequencer;
  eth_slave_monitor monitor;
  virtual eth_intf vif;

  `uvm_component_utils_begin(eth_slave_agent)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  extern function new (string name="eth_slave_agent", uvm_component parent=null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass: eth_slave_agent


function eth_slave_agent::new(string name="eth_slave_agent",uvm_component parent=null);
  super.new(name,parent);
endfunction

function void eth_slave_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  //获取eth slave config
  if(cfg==null && !uvm_config_db#(eth_agent_config)::get(this,"","eth_slv_cfg",cfg)) begin
    `uvm_error("build_phase","'cfg' is null. An eth_agent_config object or derivitive object must be set using the UVM configuration infrastructure.")
  end
  //将cfg传递给底层组件  
  this.cfg.inst = $sformatf("%s.monitor",this.get_full_name());
  uvm_config_db#(eth_agent_config)::set(this,"monitor","cfg",cfg);
  //只有activate才传递给driver和sequencer
  if(cfg.is_activate) begin
    this.cfg.inst=$sformatf("%s.driver",this.get_full_name());
    uvm_config_db#(eth_agent_config)::set(this,"driver","cfg",cfg);
    this.cfg.inst=$sformatf("%s.sequencer",this.get_full_name());
    uvm_config_db#(eth_agent_config)::set(this,"sequencer","cfg",cfg);
  end
  `uvm_info("build_phase","agent configuration",UVM_LOW)
  //例化底层组件
  if(cfg.is_activate) begin
    `uvm_info("build_phase","creating active agent",UVM_LOW)
    driver=eth_slave_driver::type_id::create("driver",this);
    sequencer = eth_slave_sequencer::type_id::create("sequencer",this);
    monitor = eth_slave_monitor::type_id::create("monitor",this);
  end
  else begin
    monitor = eth_slave_monitor::type_id::create("monitor",this);
  end
  `uvm_info("build_phase","eth_slave_agent: finishing...",UVM_LOW)
endfunction

function void eth_slave_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info("connect_phase","eth_slave_agent: starting...",UVM_LOW)
  if(cfg.is_activate) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
  end
  `uvm_info("connect_phase","eth_slave_agent: finishing...",UVM_LOW)
endfunction


`endif 

