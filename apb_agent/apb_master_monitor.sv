`ifndef APB_MASTER_MONITOR_SV
`define APB_MASTER_MONITOR_SV

class apb_master_monitor extends uvm_monitor;

  `uvm_component_utils(apb_master_monitor)

  virtual apb_intf vif;
  apb_trans trans_collected ;
  //连接到scoreboard的TLM端口
  uvm_analysis_port #(apb_trans) item_collected_port;

  extern function new(string name, uvm_component parent);
  extern function void set_interface(virtual apb_intf vif) ;
  extern virtual task run_phase(uvm_phase phase);
  //监听APB接口信息，并发送监听事务包
  extern virtual protected task monitor_transactions();
  //收集APB接口数据
  extern virtual protected task collect_trans();

endclass: apb_master_monitor


function apb_master_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  item_collected_port = new("item_collected_port",this);
endfunction

task apb_master_monitor::run_phase(uvm_phase phase);
  super.run_phase(phase) ;
  fork
    monitor_transactions();
  join_none
endtask

task apb_master_monitor::monitor_transactions();
  forever begin
    //收集APB接口数据并转成事务包
    collect_trans();
    //发送数据包给scoreboard
    item_collected_port.write(trans_collected);
  end
endtask
  
  
task apb_master_monitor::collect_trans();
  // Advance clock
  @(vif.cb_mon iff (vif.cb_mon.psel === 1'b1 && vif.cb_mon.penable === 1'b0));
  trans_collected = apb_trans::type_id::create("trans_collected");
  case(vif.cb_mon.pwrite)
    1'b1    : begin
                @(vif.cb_mon iff vif.cb_mon.pready === 1'b1);
                trans_collected.addr = vif.cb_mon.paddr;
                trans_collected.data = vif.cb_mon.pwdata;
                trans_collected.trans_kind = WRITE;
                trans_collected.trans_status = vif.cb_mon.pslverr === 1'b0 ? OK : ERROR;
              end 
    1'b0    : begin
                @(vif.cb_mon iff vif.cb_mon.pready === 1'b1);
                trans_collected.addr = vif.cb_mon.paddr;
                trans_collected.data = vif.cb_mon.prdata;
                trans_collected.trans_kind = READ;
                trans_collected.trans_status = vif.cb_mon.pslverr === 1'b0 ? OK : ERROR;
              end
    default : `uvm_error(get_type_name(), "ERROR pwrite signal value")
  endcase
endtask

function void apb_master_monitor::set_interface(virtual apb_intf vif) ;
  this.vif = vif ;
endfunction


`endif 

