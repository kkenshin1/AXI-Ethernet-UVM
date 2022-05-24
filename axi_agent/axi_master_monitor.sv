`ifndef AXI_MASTER_MONITOR_SV
`define AXI_MASTER_MONITOR_SV

class axi_master_monitor extends uvm_monitor;

  `uvm_component_utils(axi_master_monitor)

  virtual axi_intf vif;
  axi_trans trans_collected ;
  //连接到scoreboard的TLM端口
  uvm_analysis_port #(axi_trans) item_collected_port;

  extern function new(string name, uvm_component parent);
  extern function void set_interface(virtual axi_intf vif) ;
  extern virtual task run_phase(uvm_phase phase);
  //监听axi接口信息，并发送监听事务包
  extern virtual protected task monitor_transactions();

endclass: axi_master_monitor


function axi_master_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  item_collected_port = new("item_collected_port",this);
endfunction

task axi_master_monitor::run_phase(uvm_phase phase);
  super.run_phase(phase) ;
  fork
    monitor_transactions();
  join_none
endtask

//监测AXI读写事务
task axi_master_monitor::monitor_transactions();
  int i = 0 ;
  forever begin
    @(vif.cb_mon);
    //WRITE monitor
    if(vif.cb_mon.aw_valid===1 && vif.cb_mon.aw_ready===1) begin
      i = 0 ;
      trans_collected = axi_trans::type_id::create("trans_collected");
      trans_collected.addr = vif.cb_mon.aw_addr ;
      trans_collected.trans_kind = WRITE ;
      trans_collected.trans_burst_type = get_burst_type_enum(vif.cb_mon.aw_burst) ;
      trans_collected.trans_byte_size = get_byte_size_enum(vif.cb_mon.aw_size) ;
      trans_collected.trans_burst_len = get_burst_len_enum(vif.cb_mon.aw_len) ;
      trans_collected.set_data_size() ;
      do begin
        @(vif.cb_mon iff (vif.cb_mon.w_valid===1 && vif.cb_mon.w_ready===1)) ;
        trans_collected.data[i] = vif.cb_mon.w_data ;
        if(trans_collected.trans_burst_type==FIXED) i = i ;
        else if(trans_collected.trans_burst_type==INCR) i++ ;
      end while(vif.cb_mon.w_last!=1) ;
      @(vif.cb_mon iff (vif.cb_mon.b_valid===1 && vif.cb_mon.b_ready===1)) ;
      trans_collected.trans_resp_type = get_resp_type_enum(vif.cb_mon.b_resp) ;
      item_collected_port.write(trans_collected);
    end
    if(vif.cb_mon.ar_valid===1 && vif.cb_mon.ar_ready===1) begin
      i = 0 ;
      trans_collected = axi_trans::type_id::create("trans_collected");
      trans_collected.addr = vif.cb_mon.ar_addr ;
      trans_collected.trans_kind = READ ;
      trans_collected.trans_burst_type = get_burst_type_enum(vif.cb_mon.ar_burst) ;
      trans_collected.trans_byte_size = get_byte_size_enum(vif.cb_mon.ar_size) ;
      trans_collected.trans_burst_len = get_burst_len_enum(vif.cb_mon.ar_len) ;
      trans_collected.set_data_size() ;
      do begin
        @(vif.cb_mon iff (vif.cb_mon.r_valid===1 && vif.cb_mon.r_ready===1)) ;
        trans_collected.data[i] = vif.cb_mon.r_data ;
        if(trans_collected.trans_burst_type==FIXED) i = i ;
        else if(trans_collected.trans_burst_type==INCR) i++ ;
      end while(vif.cb_mon.r_last!=1) ;
      trans_collected.trans_resp_type = get_resp_type_enum(vif.cb_mon.r_resp) ;
      item_collected_port.write(trans_collected);
    end
  end
endtask

function void axi_master_monitor::set_interface(virtual axi_intf vif) ;
  this.vif = vif ;
endfunction


`endif 

