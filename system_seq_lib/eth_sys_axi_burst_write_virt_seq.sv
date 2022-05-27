`ifndef ETH_SYS_AXI_BURST_WRITE_VIRT_SEQ_SV
`define ETH_SYS_AXI_BURST_WRITE_VIRT_SEQ_SV

//AXI自增burst测试
class eth_sys_axi_burst_write_virt_seq extends eth_sys_base_sequence;

  `uvm_object_utils(eth_sys_axi_burst_write_virt_seq)

  function new (string name = "eth_sys_axi_burst_write_virt_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_apb(10);

    `uvm_do_on(eth_sys_apb_config_seq, p_sequencer.apb_mst_sqr)

    //写入burst数据长度，即所有数据全部发送
    rgm.tx_udp_len.udp_len.set(16'h60) ;
    update_regs('{rgm.tx_udp_len}) ; 

    `uvm_do_on_with(axi_mst_single_wr_seq, p_sequencer.axi_mst_sqr, 
                    {addr==32'h0; trans_burst_type==INCR;trans_byte_size==BYTE_32;trans_burst_len==LEN_3;})

    vif.wait_axi(20) ;
    rgm.tx_ctr.tx_en.set(1'b1) ;
    update_regs('{rgm.tx_ctr}) ;
    
    vif.wait_axi(600) ;

    // Attach element sequences below
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  endtask

endclass: eth_sys_axi_burst_write_virt_seq

`endif