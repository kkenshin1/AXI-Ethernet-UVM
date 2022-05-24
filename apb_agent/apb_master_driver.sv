`ifndef APB_MASTER_DRIVER_SV
`define APB_MASTER_DRIVER_SV

class apb_master_driver extends uvm_driver #(apb_trans);

  `uvm_component_utils(apb_master_driver)

  virtual apb_intf vif;

  extern function new (string name, uvm_component parent);
  extern function void set_interface(virtual apb_intf vif) ;
  extern virtual task run_phase(uvm_phase phase);
  //接收APB事务包并回应
  extern virtual protected task get_and_drive();
  //监听复位信号
  extern virtual protected task reset_listener();
  //驱动APB事务包到接口
  extern virtual protected task drive_transfer(apb_trans t);
  //实现APB IDLE
  extern protected task do_idle();
  //实现APB写时序
  extern protected task do_write(apb_trans t);
  //实现APB读时序
  extern protected task do_read(apb_trans t);

endclass: apb_master_driver


function apb_master_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction 

task apb_master_driver::run_phase(uvm_phase phase);
  super.run_phase(phase) ;
  fork
    get_and_drive();
    reset_listener();
  join_none
endtask

//接收sequencer过来的事务包，并按时序发送给DUT，将结果返回给sequencer
task apb_master_driver::get_and_drive();
  apb_trans req , rsp ;
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

//根据APB事务包类型实现APB接口的读、写、IDLE时序
task apb_master_driver::drive_transfer(apb_trans t);
  `uvm_info(get_type_name(), "drive_transfer", UVM_HIGH)
  case(t.trans_kind)
    IDLE    : this.do_idle();
    WRITE   : this.do_write(t);
    READ    : this.do_read(t);
    default : `uvm_error("ERRTYPE", "unrecognized transaction type")
  endcase
endtask

//APB写时序
task apb_master_driver::do_write(apb_trans t);
  `uvm_info(get_type_name(), "do_write ...", UVM_HIGH)
  @(vif.cb_mst);
  vif.cb_mst.paddr <= t.addr;
  vif.cb_mst.pwrite <= 1;
  vif.cb_mst.psel <= 1;
  vif.cb_mst.penable <= 0;
  vif.cb_mst.pwdata <= t.data;
  @(vif.cb_mst);
  vif.cb_mst.penable <= 1;
  #10ps;
  wait(vif.pready === 1);
  #1ps;
  if(vif.pslverr === 1) begin
    t.trans_status = ERROR;
    `uvm_warning(get_type_name(), "PSLVERR asserted!")
  end
  else begin
    t.trans_status = OK;
  end
  repeat(t.idle_cycles) this.do_idle();
endtask

//APB 读时序
task apb_master_driver::do_read(apb_trans t);
  `uvm_info(get_type_name(), "do_write ...", UVM_HIGH)
  @(vif.cb_mst);
  vif.cb_mst.paddr <= t.addr;
  vif.cb_mst.pwrite <= 0;
  vif.cb_mst.psel <= 1;
  vif.cb_mst.penable <= 0;
  @(vif.cb_mst);
  vif.cb_mst.penable <= 1;
  #10ps;
  wait(vif.pready === 1);
  #1ps;
  if(vif.pslverr === 1) begin
    t.trans_status = ERROR;
    `uvm_warning(get_type_name(), "PSLVERR asserted!")
  end
  else begin
    t.trans_status = OK;
  end
  t.data = vif.prdata;
  repeat(t.idle_cycles) this.do_idle();
endtask

//IDLE
task apb_master_driver::do_idle();
  `uvm_info(get_type_name(), "do_idle ...", UVM_HIGH)
  @(vif.cb_mst);
  vif.cb_mst.psel <= 0;
  vif.cb_mst.penable <= 0;
  vif.cb_mst.pwdata <= 0;
endtask

task apb_master_driver::reset_listener();
  `uvm_info(get_type_name(), "reset_listener ...", UVM_HIGH)
  fork
    forever begin
      @(negedge vif.rstn); // ASYNC reset
      vif.paddr <= 0;
      vif.pwrite <= 0;
      vif.psel <= 0;
      vif.penable <= 0;
      vif.pwdata <= 0;
    end
  join_none
endtask

function void apb_master_driver::set_interface(virtual apb_intf vif) ;
  this.vif = vif ;
endfunction

`endif
