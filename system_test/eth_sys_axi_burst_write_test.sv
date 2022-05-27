`ifndef ETH_SYS_AXI_BURST_WRITE_TEST_SV
`define ETH_SYS_AXI_BURST_WRITE_TEST_SV

class eth_sys_axi_burst_write_test extends eth_sys_base_test;

  `uvm_component_utils(eth_sys_axi_burst_write_test)

  function new(string name = "eth_sys_axi_burst_write_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // TODO
    // modify components' configurations
  endfunction

  task run_phase(uvm_phase phase);
    eth_sys_axi_burst_write_virt_seq seq = eth_sys_axi_burst_write_virt_seq::type_id::create("seq");
    phase.raise_objection(this);
    `uvm_info("SEQ", "sequence starting", UVM_LOW)
    seq.start(env.sqr);
    `uvm_info("SEQ", "sequence finished", UVM_LOW)
    phase.drop_objection(this);
  endtask

endclass: eth_sys_axi_burst_write_test


`endif