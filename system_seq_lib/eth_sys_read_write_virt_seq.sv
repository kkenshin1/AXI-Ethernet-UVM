  `ifndef ETH_SYS_READ_WRITE_VIRT_SEQ_SV
  `define ETH_SYS_READ_WRITE_VIRT_SEQ_SV

  class eth_sys_read_write_virt_seq extends eth_sys_base_sequence;
    uvm_status_e status;
    bit [31:0] udp_rd_len ;
    int rand_data_size ;
    int repeat_num = $urandom_range(6,2) ;
    int width_ratio = `AXI_DATA_WIDTH/8 ;
    axi_burst_length_enum axi_len ;

  `uvm_object_utils(eth_sys_read_write_virt_seq)

  function new (string name = "eth_sys_read_write_virt_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);

    // TODO
    `uvm_do_on(eth_sys_apb_config_seq, p_sequencer.apb_mst_sqr)
    //读测试
    repeat(repeat_num) begin
      rand_data_size = $urandom_range(256,1) ;
      //ETH MASTER发送数
      `uvm_do_on_with(eth_mst_write_seq, p_sequencer.eth_mst_sqr, 
                      {source_mac==`TB_MAC ;dest_mac==`DUT_MAC ;source_ip==`TB_IP ;
                      dest_ip==`DUT_IP ;source_port==`TB_PORT ;dest_port==`DUT_PORT ;
                      data_size==rand_data_size ;})

      //等待中断
      vif.wait_intr() ;
      $display("wait eth transfer interrupt");
      //读取寄存器值，获取接收数据量
      rgm.rx_udp_len.read(status, udp_rd_len);
      $display("ethernet transfer data size is == %d" , udp_rd_len) ;
      vif.wait_apb(10) ;
      
      axi_len = get_burst_len_enum((udp_rd_len[15:0]-1)/width_ratio) ;
      `uvm_do_on_with(axi_mst_single_rd_seq, p_sequencer.axi_mst_sqr, 
                  {addr==32'h0; trans_burst_type==INCR;trans_byte_size==BYTE_32;trans_burst_len==axi_len;})

      vif.wait_axi(200) ;
    end

    vif.wait_axi(200) ;
    
    //写测试
    repeat(repeat_num) begin
      rand_data_size = $urandom_range(256,1) ;
      axi_len = get_burst_len_enum((rand_data_size-1)/width_ratio) ;

      rgm.tx_udp_len.udp_len.set(rand_data_size) ;
      update_regs('{rgm.tx_udp_len}) ; 

      `uvm_do_on_with(axi_mst_single_wr_seq, p_sequencer.axi_mst_sqr, 
                      {addr==32'h0; trans_burst_type==INCR;trans_byte_size==BYTE_32;trans_burst_len==axi_len;})

      //dut发送使能控制
      vif.wait_axi(20) ;
      rgm.tx_ctr.tx_en.set(1'b1) ;
      update_regs('{rgm.tx_ctr}) ;
      vif.wait_axi(20) ;
      rgm.tx_ctr.mirror(status, UVM_NO_CHECK);

      vif.wait_axi(200) ;
    end

    vif.wait_axi(200) ;
    // Attach element sequences below
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  endtask

  endclass

  `endif