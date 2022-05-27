`ifndef ETH_SYS_REG_ACCESS_VIRT_SEQ_SV
`define ETH_SYS_REG_ACCESS_VIRT_SEQ_SV

class eth_sys_reg_access_virt_seq extends eth_sys_base_sequence;

  `uvm_object_utils(eth_sys_reg_access_virt_seq)

  function new (string name = "eth_sys_reg_access_virt_seq");
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
    rgm.tx_udp_len.udp_len.set(16'h61) ;


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


    rgm.local_mac0.mirror(status, UVM_CHECK);
    // Attach element sequences below
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  endtask

endclass: eth_sys_reg_access_virt_seq

`endif