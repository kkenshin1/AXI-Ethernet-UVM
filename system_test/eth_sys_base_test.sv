`ifndef ETH_SYS_BASE_TEST_SV
`define ETH_SYS_BASE_TEST_SV

virtual class eth_sys_base_test extends uvm_test;

  eth_sys_config cfg ;
  eth_sys_environment env;

  function new(string name = "eth_sys_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = eth_sys_config::type_id::create("cfg");
    uvm_config_db#(eth_sys_config)::set(this,"env","cfg", cfg);
    uvm_reg::include_coverage("*", UVM_CVR_FIELD_VALS + UVM_CVR_ADDR_MAP );
    env = eth_sys_environment::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_root::get().set_report_verbosity_level_hier(UVM_HIGH);
    uvm_root::get().set_report_max_quit_count(10);
  endfunction

  task run_phase(uvm_phase phase);
    // NOTE:: raise objection to prevent simulation stopping
    phase.raise_objection(this);
    this.run_top_virtual_sequence();
    // NOTE:: drop objection to request simulation stopping
    phase.drop_objection(this);
  endtask

  virtual task run_top_virtual_sequence();
    // User to implement this task in the child tests
  endtask
endclass: eth_sys_base_test

`endif