`ifndef ETH_SYS_ENVIRONMENT_SV
`define ETH_SYS_ENVIRONMENT_SV

class eth_sys_environment extends uvm_env;

  //ethernet system configuration
  eth_sys_config cfg ;

  virtual eth_intf eth_vif ;
  virtual eth_sys_intf eth_sys_vif ;

  apb_master_agent apb_mst ;
  axi_master_agent axi_mst ;
  eth_slave_agent  eth_slv ;
  eth_master_agent eth_mst ;

  eth_sys_scoreboard scb ;
  eth_sys_coverage_model cgm ;
  eth_sys_virtual_sequencer sqr;

  // top register model and related components
  eth_sys_rgm rgm;
  apb_reg_adapter adapter;
  uvm_reg_predictor #(apb_trans) predictor;

  `uvm_component_utils(eth_sys_environment)

  function new (string name = "eth_sys_environment", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //get ethernet system config
    if(!uvm_config_db #(eth_sys_config)::get(this, "", "cfg", cfg)) begin
      `uvm_error("build_phase", "Unable to get rkv_i2c_config from uvm_config_db")
    end

    //get ethernet intf
    void'(uvm_config_db#(virtual eth_intf)::get(this,"","eth_vif", eth_vif)) ;
    cfg.eth_cfg.set_interface(eth_vif) ;

    //get ehternet system intf
    void'(uvm_config_db#(virtual eth_sys_intf)::get(this,"","eth_sys_vif", eth_sys_vif)) ;
    cfg.vif = eth_sys_vif ;

    if(!uvm_config_db #(eth_sys_rgm)::get(this, "", "rgm", rgm)) begin
      `uvm_info("build_phase", "Unable to get eth_sys_rgm from uvm_config_db and create a RGM locally", UVM_LOW)
      rgm = eth_sys_rgm::type_id::create("rgm", this);
      rgm.build();
      rgm.lock_model();
    end
    cfg.rgm = rgm ;

    uvm_config_db#(eth_sys_rgm)::set(this,"*","rgm", rgm);
    uvm_config_db#(eth_sys_config)::set(this, "sqr", "cfg", cfg);
    uvm_config_db#(eth_sys_config)::set(this, "scb", "cfg", cfg);
    uvm_config_db#(eth_sys_config)::set(this, "cgm", "cfg", cfg);
    uvm_config_db#(eth_agent_config)::set(this, "eth_slv", "eth_slv_cfg", cfg.eth_cfg.eth_slv_cfg);
    uvm_config_db#(eth_agent_config)::set(this, "eth_mst", "eth_mst_cfg", cfg.eth_cfg.eth_mst_cfg);

    apb_mst = apb_master_agent::type_id::create("apb_mst", this) ;
    axi_mst = axi_master_agent::type_id::create("axi_mst", this) ;
    eth_slv = eth_slave_agent::type_id::create("eth_slv", this) ;
    eth_mst = eth_master_agent::type_id::create("eth_mst", this) ;
    sqr = eth_sys_virtual_sequencer::type_id::create("sqr", this) ;
    scb = eth_sys_scoreboard::type_id::create("scb", this) ;
    cgm = eth_sys_coverage_model::type_id::create("cgm", this) ;
    adapter = apb_reg_adapter::type_id::create("adapter", this);
    predictor = uvm_reg_predictor#(apb_trans)::type_id::create("predictor", this);
  endfunction


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // virtual sequencer routing with sub-sequencers
    sqr.apb_mst_sqr = apb_mst.sequencer ; 
    sqr.axi_mst_sqr = axi_mst.sequencer ;
    sqr.eth_slv_sqr = eth_slv.sequencer ;
    sqr.eth_mst_sqr = eth_mst.sequencer ;

    //analysis port connect
    apb_mst.monitor.item_collected_port.connect(scb.apb_mst_trans_observed_imp);
    axi_mst.monitor.item_collected_port.connect(scb.axi_mst_trans_observed_imp);
    eth_mst.monitor.item_collected_port.connect(scb.eth_mst_trans_observed_imp);
    eth_slv.monitor.item_collected_port.connect(scb.eth_slv_trans_observed_imp);

    //analysis port connect
    apb_mst.monitor.item_collected_port.connect(cgm.apb_mst_trans_observed_imp);
    axi_mst.monitor.item_collected_port.connect(cgm.axi_mst_trans_observed_imp);
    eth_mst.monitor.item_collected_port.connect(cgm.eth_mst_trans_observed_imp);
    eth_slv.monitor.item_collected_port.connect(cgm.eth_slv_trans_observed_imp);

    // register model integration
    rgm.default_map.set_sequencer(apb_mst.sequencer, adapter);
    apb_mst.monitor.item_collected_port.connect(predictor.bus_in);
    predictor.map = rgm.default_map;
    predictor.adapter = adapter;
  endfunction

endclass: eth_sys_environment


`endif