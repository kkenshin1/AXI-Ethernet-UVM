`ifndef ETH_SYS_BASE_SEQUENCE_SV
`define ETH_SYS_BASE_SEQUENCE_SV

virtual class eth_sys_base_sequence extends uvm_sequence;

  eth_sys_rgm rgm;
  virtual eth_sys_intf vif;
  eth_sys_environment env;
  eth_sys_config cfg;

  // Register model variables:
  uvm_status_e status;

  // element sequences
  apb_master_single_write_sequence    apb_mst_single_wr_seq ;
  apb_master_single_read_sequence     apb_mst_single_rd_seq ;
  apb_master_write_read_sequence      apb_mst_wrrd_seq ;
  apb_master_burst_write_sequence     apb_mst_burst_wr_seq ;
  apb_master_burst_read_sequence      apb_mst_burst_rd_seq ;

  axi_master_single_write_sequence    axi_mst_single_wr_seq ;
  axi_master_single_read_sequence     axi_mst_single_rd_seq ;

  eth_master_write_sequence           eth_mst_write_seq ;

  eth_sys_apb_config_sequence         eth_sys_apb_config_seq ;  


  uvm_reg_hw_reset_seq                reg_rst_seq;
  uvm_reg_single_bit_bash_seq         reg_single_bit_bash_seq;
  uvm_reg_bit_bash_seq                reg_bit_bash_seq;
  uvm_reg_single_access_seq           reg_single_access_seq;
  uvm_reg_access_seq                  reg_access_seq;
  uvm_reg_shared_access_seq           reg_shared_access_seq;

  `uvm_declare_p_sequencer(eth_sys_virtual_sequencer)

  function new (string name = "eth_sys_base_sequence");
    super.new(name);
  endfunction

  virtual task body();
    rgm = p_sequencer.rgm;
    vif = p_sequencer.vif;
    cfg = p_sequencer.cfg;
    void'($cast(env, p_sequencer.m_parent));
    do_reset_callback();
    // TODO
    // Attach element sequences below
  endtask

  virtual task do_reset_callback();
    fork
      forever begin
        vif.wait_rstn_release();
        rgm.reset();
      end
    join_none
  endtask

  function bit diff_value(int val1, int val2, string id = "value_compare");
    if(val1 != val2) begin
      `uvm_error("[CMPERR]", $sformatf("ERROR! %s val1 %8x != val2 %8x", id, val1, val2)) 
      return 0;
    end
    else begin
      `uvm_info("[CMPSUC]", $sformatf("SUCCESS! %s val1 %8x == val2 %8x", id, val1, val2), UVM_LOW)
      return 1;
    end
  endfunction

  virtual task update_regs(uvm_reg regs[]);
    uvm_status_e status;
    foreach(regs[i]) regs[i].update(status);
  endtask

endclass: eth_sys_base_sequence


`endif