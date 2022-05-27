`ifndef ETH_SLAVE_DRIVER_SV
`define ETH_SLAVE_DRIVER_SV

class eth_slave_driver extends uvm_driver #(eth_trans);

  eth_agent_config cfg;
  eth_slave_driver_common common;   
  
  `uvm_component_utils_begin(eth_slave_driver)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  extern function new(string name="eth_slave_driver", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task consume_from_seq_item_port();
  extern task reconfigure_via_task(eth_agent_config cfg);
  extern function void set_common_interface();

endclass: eth_slave_driver


function eth_slave_driver::new (string name="eth_slave_driver", uvm_component parent);
  super.new(name, parent);
endfunction

function void eth_slave_driver::build_phase(uvm_phase phase);
  super.build_phase(phase) ;
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
  common = eth_slave_driver_common::type_id::create("common"); 
  common.cfg = this.cfg;
  this.set_common_interface();

  `uvm_info("build_phase", $sformatf("%s: finishing...",get_type_name()), UVM_LOW)
endfunction


task eth_slave_driver::consume_from_seq_item_port();
  eth_trans req , rsp ;
  forever begin
    if(cfg.rsp_activate) begin
      seq_item_port.get_next_item(req);
      common.send_eth_trans(req);
      $cast(rsp,req.clone());
      rsp.set_sequence_id(req.get_sequence_id());
      rsp.set_transaction_id(req.get_transaction_id());
      seq_item_port.item_done(rsp);
      `uvm_info("consume_from_seq_item_port", "Transaction Process in Driver Complete...", UVM_DEBUG)
    end
    else begin
      `uvm_info("consume_from_seq_item_port", "Ethernet Slave Driver Respond to ARP Package...", UVM_DEBUG)
      common.arp_response() ;
    end
  end
endtask


task eth_slave_driver::run_phase(uvm_phase phase);
  super.run_phase(phase);
  `uvm_info("run_phase", "eth_slave_driver::Starting...", UVM_LOW)
  `uvm_info("run_phase", "Wait for Reset...", UVM_DEBUG)
  //common.reset_listener(); 
  common.wait_for_reset(); 
  `uvm_info("run_phase", "Wait for Observed...", UVM_DEBUG)
  fork
    consume_from_seq_item_port();
  join_none
  `uvm_info("run_phase", "eth_slave_driver::Finishing...", UVM_LOW)
endtask

task eth_slave_driver::reconfigure_via_task(eth_agent_config cfg);
  if(!$cast(this.cfg, cfg))
    `uvm_fatal("CASTFAIL", "ETH agent configuration handle type inconsistence")
  common.reconfigure_via_task(cfg);
endtask

function void eth_slave_driver::set_common_interface();
  common.set_interface(cfg.vif); 
endfunction
  

`endif 
