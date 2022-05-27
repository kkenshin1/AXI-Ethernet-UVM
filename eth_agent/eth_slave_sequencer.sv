`ifndef ETH_SLAVE_SEQUENCER_SV
`define ETH_SLAVE_SEQUENCER_SV

class eth_slave_sequencer extends uvm_sequencer #(eth_trans);

  eth_agent_config cfg;

  `uvm_component_utils_begin(eth_slave_sequencer)
     `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  extern function new (string name="eth_slave_sequencer",uvm_component parent=null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void reconfigure(eth_agent_config cfg);
  extern virtual function void get_cfg(ref eth_agent_config cfg);

endclass: eth_slave_sequencer

function eth_slave_sequencer::new(string name="eth_slave_sequencer",uvm_component parent=null);
  super.new(name,parent);
endfunction : new

function void eth_slave_sequencer::build_phase(uvm_phase phase);
  super.build_phase(phase);
  begin
    if(cfg == null) begin
      if(uvm_config_db#(eth_agent_config)::get(this,"","cfg",cfg) && (cfg!=null)) begin
        `uvm_info("build_phase","cfg get ok",UVM_LOW)
        if(!($cast(this.cfg,cfg.clone()))) begin
          `uvm_fatal("build_phase", "Failed when attempting to cast eth_slave_configuration");
        end
      end else begin
        `uvm_fatal("build_phase", "'cfg' is null. An eth_slave_configuration object or derivative object must be set using the configuration infrastructure or via reconfigure.");
      end
    end
  end
endfunction

function void eth_slave_sequencer::reconfigure(eth_agent_config cfg); 
  if (!$cast(this.cfg, cfg))
    `uvm_error("reconfigure", "Failed attempting to assign 'cfg' argument to sequencer 'cfg' field."); 
endfunction 

function void  eth_slave_sequencer::get_cfg(ref eth_agent_config cfg);
  cfg = this.cfg;
endfunction

`endif


