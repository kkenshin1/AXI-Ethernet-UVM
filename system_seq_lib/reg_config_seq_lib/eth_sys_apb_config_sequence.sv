`ifndef ETH_SYS_APB_CONFIG_SEQUENCE_SV
`define ETH_SYS_APB_CONFIG_SEQUENCE_SV

//该seq进行基础寄存器配置
class eth_sys_apb_config_sequence extends uvm_sequence #(apb_trans) ;
  eth_sys_rgm rgm;
  uvm_status_e status;

  `uvm_declare_p_sequencer(apb_master_sequencer)
  `uvm_object_utils(eth_sys_apb_config_sequence)

  function new (string name = "eth_sys_apb_config_sequence");
    super.new(name);
  endfunction

  virtual task body();
    super.body();
    
    if(!uvm_config_db #(eth_sys_rgm)::get(m_sequencer, "", "rgm", rgm)) begin
      `uvm_error("body", "Unable to find eth_sys_rgm in uvm_config_db")
    end
    // TODO
    rgm.local_mac0.set(32'h35_01_fe_c0) ;
    rgm.local_mac1.src_mac1.set(16'h00_0a) ;
    rgm.local_ip.set(32'hc0_a8_00_02) ;
    rgm.gateway_ip.set(32'hc0_a8_00_01) ;
    rgm.subnet_mask.set(32'hff_ff_ff_00) ;
    rgm.tx_dst_ip.set(32'hc0_a8_00_03) ;
    rgm.tx_src_port.src_port.set(16'h1f_90) ;
    rgm.tx_dst_port.dst_port.set(16'h1f_90) ;
    //rgm.tx_udp_len.udp_len.set(16'h20) ;
    
    rgm.local_mac0.update(status);
    rgm.local_mac1.update(status);
    rgm.local_ip.update(status);
    rgm.gateway_ip.update(status);
    rgm.subnet_mask.update(status);
    rgm.tx_dst_ip.update(status);
    rgm.tx_src_port.update(status);
    rgm.tx_dst_port.update(status);

  endtask

endclass: eth_sys_apb_config_sequence

`endif // RKV_APB_CONFIG_SEQ_SV
