`ifndef AXI_MASTER_DRIVER_SV
`define AXI_MASTER_DRIVER_SV

class axi_master_driver extends uvm_driver #(axi_trans);

  `uvm_component_utils(axi_master_driver)

  virtual axi_intf vif;

  extern function new (string name, uvm_component parent);
  extern function void set_interface(virtual axi_intf vif) ;
  extern virtual task run_phase(uvm_phase phase);
  //接收axi事务包并回应
  extern virtual protected task get_and_drive();
  //监听复位信号
  extern virtual protected task reset_listener();
  //驱动axi事务包到接口
  extern virtual protected task drive_transfer(axi_trans t);
  //实现axi写时序
  extern protected task do_write(axi_trans t);
  //实现axi读时序
  extern protected task do_read(axi_trans t);
  //AXI AW Channel Drive
  extern protected task do_aw_write(axi_aw_vec s) ;
  //AXI W Channel Drive
  extern protected task do_w_write(axi_w_vec s , axi_trans t) ;
  //AXI B Channel Drive
  extern protected task do_b_write(axi_trans t) ;
  //AXI AR Channel Drive
  extern protected task do_ar_read(axi_ar_vec s) ;
  //AXI R Channel Drive
  extern protected task do_r_read(axi_trans t) ;

endclass: axi_master_driver


function axi_master_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction 

task axi_master_driver::run_phase(uvm_phase phase);
  super.run_phase(phase) ;
  fork
    get_and_drive();
    reset_listener();
  join_none
endtask

//接收sequencer过来的事务包，并按时序发送给DUT，将结果返回给sequencer
task axi_master_driver::get_and_drive();
  axi_trans req , rsp ;
  forever begin
    seq_item_port.get_next_item(req);
    `uvm_info(get_type_name(), "sequencer got next item", UVM_HIGH)
    drive_transfer(req);
    void'($cast(rsp, req.clone()));
    rsp.set_sequence_id(req.get_sequence_id());
    rsp.set_transaction_id(req.get_transaction_id());
    seq_item_port.item_done(rsp);
    `uvm_info(get_type_name(), "sequencer item_done_triggered", UVM_HIGH)
  end
endtask

//根据axi事务包类型实现axi接口的读、写、IDLE时序
task axi_master_driver::drive_transfer(axi_trans t);
  `uvm_info(get_type_name(), "drive_transfer", UVM_HIGH)
  case(t.trans_kind)
    WRITE   : this.do_write(t);
    READ    : this.do_read(t);
    default : `uvm_error("ERRTYPE", "unrecognized transaction type")
  endcase
endtask

//axi写时序
task axi_master_driver::do_write(axi_trans t);
  axi_aw_vec s, s_clr ;
  axi_w_vec v, v_clr ; 
  `uvm_info(get_type_name(), "do_write ...", UVM_HIGH)
  get_axi_write_vec(t, s, v) ;
  get_clear_axi_write_vec(s_clr, v_clr) ;
  //AW WRITE
  do_aw_write(s) ;
  do_aw_write(s_clr) ;
  repeat(t.addr_data_delay) @(vif.cb_mst) ;
  //W WRITE
  do_w_write(v, t) ;
  do_w_write(v_clr, t) ;
  repeat(t.data_resp_delay) @(vif.cb_mst) ;
  //B WRITE
  do_b_write(t) ;
  repeat(t.trans_end_delay) @(vif.cb_mst) ;
endtask

task axi_master_driver::do_aw_write(axi_aw_vec s) ;
  @(vif.cb_mst) ;
  vif.cb_mst.aw_addr    <= s.aw_addr    ;
  vif.cb_mst.aw_prot    <= s.aw_prot    ;
  vif.cb_mst.aw_region  <= s.aw_region  ;
  vif.cb_mst.aw_len     <= s.aw_len     ;
  vif.cb_mst.aw_size    <= s.aw_size    ;
  vif.cb_mst.aw_burst   <= s.aw_burst   ;
  vif.cb_mst.aw_lock    <= s.aw_lock    ;
  vif.cb_mst.aw_cache   <= s.aw_cache   ;
  vif.cb_mst.aw_qos     <= s.aw_qos     ;
  vif.cb_mst.aw_id      <= s.aw_id      ;
  vif.cb_mst.aw_user    <= s.aw_user    ;
  vif.cb_mst.aw_valid   <= s.aw_valid   ;
  if(s.aw_valid == 1) begin
    while(vif.aw_ready != 1) begin
      @(vif.cb_mst) ;
    end
  end
endtask

task axi_master_driver::do_w_write(axi_w_vec s, axi_trans t) ;
  if(s.w_valid == 0) begin
    @(vif.cb_mst) ;
    vif.cb_mst.w_valid <= s.w_valid ;
    vif.cb_mst.w_data  <= 'b0 ;
    vif.cb_mst.w_strb  <= s.w_strb  ;
    vif.cb_mst.w_user  <= s.w_user  ;
    vif.cb_mst.w_last  <= s.w_last  ;
    #10ps ;
  end
  else begin
    foreach(t.data[i]) begin
      @(vif.cb_mst) ;
      vif.cb_mst.w_valid <= s.w_valid ;
      vif.cb_mst.w_data  <= t.data[i] ;
      vif.cb_mst.w_strb  <= s.w_strb  ;
      vif.cb_mst.w_user  <= s.w_user  ;
      if(i == (t.data.size()-1)) 
        vif.cb_mst.w_last <= s.w_last ;
      else 
        vif.cb_mst.w_last <= 'b0 ;
      while(vif.w_ready != 1) begin
        @(vif.cb_mst) ;
      end
    end
  end
endtask

task axi_master_driver::do_b_write(axi_trans t) ;
  @(vif.cb_mst) ;
  wait(vif.b_valid === 1) ;
  if(vif.b_resp == 0)
    t.trans_resp_type = OKAY ;
  else 
    t.trans_resp_type = EXOKAY ;
  vif.cb_mst.b_ready <= 'b1 ;
  @(vif.cb_mst) ;
  vif.cb_mst.b_ready <= 'b0 ;
endtask

//axi 读时序
task axi_master_driver::do_read(axi_trans t);
  axi_ar_vec s, s_clr ;
  `uvm_info(get_type_name(), "do_write ...", UVM_HIGH)
  get_axi_read_vec(t, s) ;
  get_clear_axi_read_vec(s_clr) ;
  //AR READ
  do_ar_read(s) ;
  do_ar_read(s_clr) ;
  repeat(t.addr_data_delay) @(vif.cb_mst) ;
  //R READ
  do_r_read(t) ;
  repeat(t.trans_end_delay) @(vif.cb_mst) ;
endtask

task axi_master_driver::do_ar_read(axi_ar_vec s) ;
  @(vif.cb_mst) ;
  vif.cb_mst.ar_addr    <= s.ar_addr    ;
  vif.cb_mst.ar_prot    <= s.ar_prot    ;
  vif.cb_mst.ar_region  <= s.ar_region  ;
  vif.cb_mst.ar_len     <= s.ar_len     ;
  vif.cb_mst.ar_size    <= s.ar_size    ;
  vif.cb_mst.ar_burst   <= s.ar_burst   ;
  vif.cb_mst.ar_lock    <= s.ar_lock    ;
  vif.cb_mst.ar_cache   <= s.ar_cache   ;
  vif.cb_mst.ar_qos     <= s.ar_qos     ;
  vif.cb_mst.ar_id      <= s.ar_id      ;
  vif.cb_mst.ar_user    <= s.ar_user    ;
  vif.cb_mst.ar_valid   <= s.ar_valid   ;
  if(s.ar_valid == 1) begin
    while(vif.ar_ready != 1) begin
      @(vif.cb_mst) ;
    end
  end
endtask

task axi_master_driver::do_r_read(axi_trans t) ;
  int i = 0 ;
  do begin
    @(vif.cb_mst) ;
    wait(vif.r_valid===1) ;
    vif.cb_mst.r_ready <= 'b1 ;
    t.data[i] = vif.r_data ;
    t.trans_resp_type = OKAY ;
    i++ ;
    #10ps;
  end while(vif.r_last != 1) ;
  @(vif.cb_mst) ;
  vif.cb_mst.r_ready <= 'b0 ;
endtask


task axi_master_driver::reset_listener();
  `uvm_info(get_type_name(), "reset_listener ...", UVM_HIGH)
  fork
    forever begin
      @(negedge vif.rstn); // ASYNC reset
      vif.aw_addr <= 'b0 ;
      vif.aw_prot <= 'b0 ;
      vif.aw_region <= 'b0 ;
      vif.aw_len <= 'b0 ;
      vif.aw_size <= 'b0 ;
      vif.aw_burst <= 'b0 ;
      vif.aw_lock <= 'b0 ;
      vif.aw_cache <= 'b0 ;
      vif.aw_qos <= 'b0 ;
      vif.aw_id <= 'b0 ;
      vif.aw_user <= 'b0 ;
      vif.aw_valid <= 'b0 ;
      vif.w_valid <= 'b0 ;
      vif.w_data <= 'b0 ;
      vif.w_strb <= 'b0 ;
      vif.w_user <= 'b0 ;
      vif.w_last <= 'b0 ;
      vif.b_ready <= 'b0 ;
      vif.ar_addr <= 'b0 ;
      vif.ar_prot <= 'b0 ;
      vif.ar_region <= 'b0 ;
      vif.ar_len <= 'b0 ;
      vif.ar_size <= 'b0 ;
      vif.ar_burst <= 'b0 ;
      vif.ar_lock <= 'b0 ;
      vif.ar_cache <= 'b0 ;
      vif.ar_qos <= 'b0 ;
      vif.ar_id <= 'b0 ;
      vif.ar_user <= 'b0 ;
      vif.ar_valid <= 'b0 ;
      vif.r_ready <= 'b0 ;
    end
  join_none
endtask

function void axi_master_driver::set_interface(virtual axi_intf vif) ;
  this.vif = vif ;
endfunction

`endif
