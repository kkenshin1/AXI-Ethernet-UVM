`ifndef ETH_SYS_AXI_SINGLE_WRITE_VIRT_SEQ_SV
`define ETH_SYS_AXI_SINGLE_WRITE_VIRT_SEQ_SV

class eth_sys_axi_single_write_virt_seq extends eth_sys_base_sequence;

  `uvm_object_utils(eth_sys_axi_single_write_virt_seq)

  function new (string name = "eth_sys_axi_single_write_virt_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);

    // TODO
    rgm.local_mac0.set(32'h35_01_fe_c0) ;
    rgm.local_mac1.src_mac1.set(16'h00_0a) ;
    rgm.local_ip.set(32'hc0_a8_00_02) ;
    rgm.gateway_ip.set(32'hc0_a8_00_01) ;
    rgm.subnet_mask.set(32'hff_ff_ff_00) ;
    rgm.tx_dst_ip.set(32'hc0_a8_00_03) ;
    rgm.tx_src_port.src_port.set(16'h1f_90) ;
    rgm.tx_dst_port.dst_port.set(16'h1f_90) ;
    rgm.tx_udp_len.udp_len.set(16'h20) ;


    update_regs('{
      rgm.local_mac0 ,
      rgm.local_mac1 ,
      rgm.local_ip ,
      rgm.gateway_ip ,
      rgm.subnet_mask ,
      rgm.tx_dst_ip ,
      rgm.tx_src_port ,
      rgm.tx_dst_port ,
      rgm.tx_udp_len 
    });

    `uvm_do_on_with(axi_mst_single_wr_seq, p_sequencer.axi_mst_sqr, 
                    {addr==32'h0; trans_burst_type==FIXED;trans_byte_size==BYTE_32;trans_burst_len==LEN_1;})

    vif.wait_axi(20) ;
    rgm.tx_ctr.tx_en.set(1'b1) ;
    update_regs('{rgm.tx_ctr}) ;
    
    vif.wait_axi(400) ;

    // Attach element sequences below
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  endtask

endclass: eth_sys_axi_single_write_virt_seq

`endif