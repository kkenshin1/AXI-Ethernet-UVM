`ifndef ETH_SYS_AXI2ETH_BURST_WRITE_VIRT_SEQ_SV
`define ETH_SYS_AXI2ETH_BURST_WRITE_VIRT_SEQ_SV

//连续传输，不断发送axi数据和eth数据
class eth_sys_axi2eth_burst_write_virt_seq extends eth_sys_base_sequence;

  int repeat_num = $urandom_range(8,2) ;

  `uvm_object_utils(eth_sys_axi2eth_burst_write_virt_seq)

  function new (string name = "eth_sys_axi2eth_burst_write_virt_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_apb(10);

    `uvm_do_on(eth_sys_apb_config_seq, p_sequencer.apb_mst_sqr)

    rgm.tx_udp_len.udp_len.set(16'h40) ;
    update_regs('{rgm.tx_udp_len}) ; 

    repeat(repeat_num) begin
      `uvm_do_on_with(axi_mst_single_wr_seq, p_sequencer.axi_mst_sqr, 
                      {addr==32'h0; trans_burst_type==INCR;trans_byte_size==BYTE_32;trans_burst_len==LEN_2;})

      //dut发送使能控制
      vif.wait_axi(20) ;
      rgm.tx_ctr.tx_en.set(1'b1) ;
      update_regs('{rgm.tx_ctr}) ;
      vif.wait_axi(20) ;
      rgm.tx_ctr.mirror(status, UVM_NO_CHECK);

      vif.wait_axi(300) ;

    end
    
    vif.wait_axi(400) ;

    // Attach element sequences below
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  endtask

endclass: eth_sys_axi2eth_burst_write_virt_seq

`endif