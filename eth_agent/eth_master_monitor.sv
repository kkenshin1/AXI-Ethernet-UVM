`ifndef ETH_MASTER_MONITOR_SVH
`define ETH_MASTER_MONITOR_SVH

class eth_master_monitor extends uvm_monitor;

  eth_agent_config cfg;
  eth_trans trans_collected ;
  eth_master_monitor_common common;  
  uvm_analysis_port #(eth_trans) item_collected_port;

  `uvm_component_utils_begin(eth_master_monitor)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end
    
  extern function new(string name="eth_master_monitor", uvm_component parent=null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task received_and_send();
  extern virtual task reconfigure_via_task(eth_agent_config cfg);
  extern function void set_common_interface() ;

endclass : eth_master_monitor


function eth_master_monitor::new(string name="eth_master_monitor",uvm_component parent=null);
    super.new(name,parent);
    item_collected_port = new("item_collected_port", this);
endfunction

function void eth_master_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info("build_phase", $sformatf("%s: starting...",get_type_name()), UVM_LOW)
  //get eth agent config
  if(!uvm_config_db#(eth_agent_config)::get(this, "", "cfg", cfg)) begin
    `uvm_fatal("build_phase", "Unable to get the slave agent configuration and failed to extract config info from the object")
  end
  //判断是否有interface
  if(cfg.vif == null) begin
    `uvm_fatal("build_phase", "A virtual interface was not received through the config object")
  end
  //例化eth slave bfm common 
  common = eth_master_monitor_common::type_id::create("common"); 
  common.cfg = this.cfg;
  this.set_common_interface();

  `uvm_info("build_phase", $sformatf("%s: finishing...",get_type_name()), UVM_LOW)
  endfunction


task eth_master_monitor::received_and_send();
  eth_trans trans , trans_tmp ;
  trans = eth_trans::type_id::create("eth_trans");
  trans.randomize() with {is_arp_valid == 1'b1 ;
                          source_mac == cfg.source_mac ;
                          dest_mac == cfg.dest_mac ;
                          source_ip == cfg.source_ip ;
                          dest_ip == cfg.dest_ip ;
                          source_port == cfg.source_port ;
                          dest_port == cfg.dest_port ; } ;
  //trans_tmp.randomize() with {is_arp_valid == 1'b1 ;} ;  
  forever begin
    common.collect_transfer(trans);
    $cast(trans_tmp,trans.clone());
    if(trans_tmp.eth_status==ALL_SUCCESS) item_collected_port.write(trans_tmp);
  end
endtask

task eth_master_monitor::run_phase(uvm_phase phase);
  super.run_phase(phase);
  `uvm_info("run_phase", "eth_master_monitor::Starting...", UVM_LOW)
  `uvm_info("run_phase", "Wait for Reset...", UVM_DEBUG)
  common.wait_for_reset(); 
  `uvm_info("run_phase", "Wait for Observed...", UVM_DEBUG)
  fork
    received_and_send();
  join_none
  
  `uvm_info("run_phase", "eth_master_monitor::Finishing...", UVM_LOW)
endtask

task eth_master_monitor::reconfigure_via_task(eth_agent_config cfg);
  if(!$cast(this.cfg, cfg))
    `uvm_fatal("CASTFAIL", "ETH agent configuration handle type inconsistence")
  common.reconfigure_via_task(cfg);
endtask

function void eth_master_monitor::set_common_interface();
  common.set_interface(cfg.vif); 
endfunction

`endif

