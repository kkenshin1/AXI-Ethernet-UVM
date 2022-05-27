`ifndef ETH_SYS_SCOREBOARD_SV
`define ETH_SYS_SCOREBOARD_SV

`uvm_analysis_imp_decl(_apb_master)
`uvm_analysis_imp_decl(_axi_master)
`uvm_analysis_imp_decl(_eth_master)
`uvm_analysis_imp_decl(_eth_slave)

class eth_sys_scoreboard extends uvm_component;

  eth_sys_config cfg;
  //analysis port
  uvm_analysis_imp_apb_master #(apb_trans, eth_sys_scoreboard) apb_mst_trans_observed_imp;
  uvm_analysis_imp_axi_master #(axi_trans, eth_sys_scoreboard) axi_mst_trans_observed_imp;
  uvm_analysis_imp_eth_master #(eth_trans, eth_sys_scoreboard) eth_mst_trans_observed_imp;
  uvm_analysis_imp_eth_slave  #(eth_trans, eth_sys_scoreboard) eth_slv_trans_observed_imp;

  //中间数据缓存
  bit[`AXI_DATA_WIDTH-1:0] axi_mstwr_data_observed[$];
  bit[`AXI_DATA_WIDTH-1:0] axi_mstrd_data_observed[$];
  bit[8-1:0] eth_mstwr_data_observed[$];
  bit[8-1:0] eth_slvrd_data_observed[$];

  //监听apb master获取udp数据包长度
  int udp_wr_len = 0 ;
  int udp_rd_len = 0 ;

  int apb_master_count = 0 ;
  int axi_master_write_count = 0;
  int axi_master_read_count = 0;
  int eth_master_write_count = 0;
  int eth_slave_read_count = 0;
  int mismatch_count = 0;

  int width_ratio = `AXI_DATA_WIDTH/8 ;

  `uvm_component_utils(eth_sys_scoreboard)

  extern function new(string name = "eth_sys_scoreboard", uvm_component parent) ;
  extern function void build_phase(uvm_phase phase) ;
  extern task run_phase(uvm_phase phase) ;
  extern function void report_phase(uvm_phase phase) ;
  //write函数重写
  extern virtual function void write_apb_master(apb_trans tr) ;
  extern virtual function void write_axi_master(axi_trans tr) ;
  extern virtual function void write_eth_master(eth_trans tr) ;
  extern virtual function void write_eth_slave(eth_trans tr) ;
  //eth sys数据传输对比
  //master比对axi->eth
  //slave比对eth->axi
  extern task eth_sys_master_comparer() ;
  extern task eth_sys_slave_comparer() ;
  extern function void compare_transaction(bit[7:0] exp[$], bit[7:0] obs[$]);

endclass: eth_sys_scoreboard

function eth_sys_scoreboard::new (string name = "eth_sys_scoreboard", uvm_component parent);
  super.new(name, parent);
endfunction

function void eth_sys_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);

  apb_mst_trans_observed_imp = new("apb_mst_trans_observed_imp", this);
  axi_mst_trans_observed_imp = new("axi_mst_trans_observed_imp", this);
  eth_mst_trans_observed_imp = new("eth_mst_trans_observed_imp", this);
  eth_slv_trans_observed_imp = new("eth_slv_trans_observed_imp", this);

  if(!uvm_config_db #(eth_sys_config)::get(this, "", "cfg", cfg)) begin
    `uvm_error("build_phase", "Unable to get eth_sys_config from uvm_config_db")
  end

endfunction

task eth_sys_scoreboard::run_phase(uvm_phase phase);
  fork
    eth_sys_master_comparer();
    eth_sys_slave_comparer();
  join_none
endtask

//apb包只需要检测udp_len的寄存器即可
function void eth_sys_scoreboard::write_apb_master(apb_trans tr);
  uvm_reg r;
  r = cfg.rgm.default_map.get_reg_by_offset(tr.addr);
  if(r.get_name() == "tx_udp_len")
    udp_wr_len = tr.data ;
  else if(r.get_name() == "rx_udp_len")
    udp_rd_len = tr.data ;
  apb_master_count++ ;
endfunction

//axi包需要区分读写，并放到不同队列
function void eth_sys_scoreboard::write_axi_master(axi_trans tr);
  if(tr.trans_kind==axi_pkg::WRITE) begin
    foreach(tr.data[i]) begin
      axi_mstwr_data_observed.push_back(tr.data[i]) ;
    end
    if(tr.trans_burst_type==FIXED && tr.trans_burst_len!=LEN_1)
      for(int j = 0 ; j < get_burst_len(tr.trans_burst_len)+1 ; j++)
        axi_mstwr_data_observed.push_back('b0) ;
    axi_master_write_count++ ;
  end
  else if(tr.trans_kind==axi_pkg::READ) begin
    foreach(tr.data[j]) begin
      axi_mstrd_data_observed.push_back(tr.data[j]) ;
    end
    axi_master_read_count++ ;
  end
endfunction

//eth包只要放payload即可
function void eth_sys_scoreboard::write_eth_master(eth_trans tr);
  foreach(tr.payload[i]) begin
    eth_mstwr_data_observed.push_back(tr.payload[i]) ;
  end
  eth_master_write_count++ ;
endfunction

function void eth_sys_scoreboard::write_eth_slave(eth_trans tr);
  foreach(tr.payload[i]) begin
    eth_slvrd_data_observed.push_back(tr.payload[i]) ;
  end
  eth_slave_read_count++ ;
endfunction


function void eth_sys_scoreboard::report_phase(uvm_phase phase);

  `uvm_info(get_type_name(),
  $sformatf("\n\
            ----------------------------------------------\n\
            | ScoreBoard(Enabled) Report                  |\n\
            ---------------------------------------------- \n\
            | Transactions  wr/rd  by  APB Interface %5d  |\n\
            | Transactions  write  by  AXI Interface %5d  |\n\
            | Transactions   read  by  AXI Interface %5d  |\n\
            | Transactions  write  by  Eth Interface %5d  |\n\
            | Transactions   read  by  Eth Interface %5d  |\n\
            | Mismatch in transactions               %5d  |\n\
            ---------------------------------------------- ",
            apb_master_count, axi_master_write_count, axi_master_read_count, 
            eth_master_write_count, eth_slave_read_count , mismatch_count), UVM_LOW);

  if(axi_mstwr_data_observed.size() != 0) begin
    `uvm_error(get_type_name(),$sformatf("Scoreboard Error : AXI write transaction queue still have %0d pending transaction",axi_mstwr_data_observed.size()))
  end
  if(axi_mstrd_data_observed.size() != 0) begin
    `uvm_error(get_type_name(),$sformatf("Scoreboard Error : AXI read transaction queue still have %0d pending transaction",axi_mstrd_data_observed.size()))
  end
  if(eth_mstwr_data_observed.size() != 0) begin
    `uvm_error(get_type_name(),$sformatf("Scoreboard Error : ETH write transaction queue still have %0d pending transaction",eth_mstwr_data_observed.size()))
  end
  if(eth_slvrd_data_observed.size() != 0) begin
    `uvm_error(get_type_name(),$sformatf("Scoreboard Error : ETH read transaction queue still have %0d pending transaction",eth_slvrd_data_observed.size()))
  end

endfunction

task eth_sys_scoreboard::eth_sys_master_comparer();
  int axi_len , eth_len ;
  bit [`AXI_DATA_WIDTH-1:0] axi_data ;
  bit [8-1:0] eth_data ;
  bit [8-1:0] eth_queue[$] ;
  bit [8-1:0] axi_queue[$] ;
  forever begin
    wait(axi_mstwr_data_observed.size() > 0) ;
    axi_len = (udp_wr_len+width_ratio-1)/width_ratio ;
    eth_len = udp_wr_len ;
    fork
      begin
        wait(axi_mstwr_data_observed.size() > axi_len-1) ;
        for(int i = 0 ; i < axi_len ; i++) begin
          axi_data = axi_mstwr_data_observed.pop_front();
          for(int j = 0 ; j < width_ratio ; j++) begin
            if(i*width_ratio+j==eth_len) break ;
            axi_queue.push_back(axi_data[j*8+:8]) ; 
          end
        end        
      end
      begin
        wait(eth_slvrd_data_observed.size() > eth_len-1) ;
        for(int k = 0 ; k < eth_len ; k++)
          eth_queue.push_back(eth_slvrd_data_observed.pop_front()) ;
        if(eth_len<`PADDING_LEN)
          for(int l = 0 ; l < `PADDING_LEN-eth_len ; l++)
            eth_slvrd_data_observed.pop_front() ;
      end
    join
    compare_transaction(axi_queue, eth_queue);
    axi_queue = {} ;
    eth_queue = {} ;
  end
endtask

task eth_sys_scoreboard::eth_sys_slave_comparer();
  int axi_len , eth_len ;
  bit [`AXI_DATA_WIDTH-1:0] axi_data ;
  bit [8-1:0] eth_data ;
  bit [8-1:0] eth_queue[$] ;
  bit [8-1:0] axi_queue[$] ;
  forever begin
    wait(axi_mstrd_data_observed.size() > 0) ;
    axi_len = (udp_rd_len+width_ratio-1)/width_ratio ;
    eth_len = udp_rd_len ;
    fork
      begin
        wait(axi_mstrd_data_observed.size() > axi_len-1) ;
        for(int i = 0 ; i < axi_len ; i++) begin
          axi_data = axi_mstrd_data_observed.pop_front();
          for(int j = 0 ; j < width_ratio ; j++) begin
            if(i*width_ratio+j==udp_rd_len) break ;
            axi_queue.push_back(axi_data[j*8+:8]) ;
          end
        end   
      end
      begin
        wait(eth_mstwr_data_observed.size() > eth_len-1) ;
        for(int k = 0 ; k < eth_len ; k++)
          eth_queue.push_back(eth_mstwr_data_observed.pop_front()) ;
        if(eth_len<`PADDING_LEN)
          for(int l = 0 ; l < `PADDING_LEN-eth_len ; l++)
            eth_mstwr_data_observed.pop_front() ;
      end
    join
    compare_transaction(axi_queue, eth_queue);
    axi_queue = {} ;
    eth_queue = {} ;
  end
endtask


function void eth_sys_scoreboard::compare_transaction(bit[7:0] exp[$], bit[7:0] obs[$]);
  bit mismatch_detected = 0 ;

  if(exp != obs) begin
    `uvm_error(get_type_name(), $sformatf("Byte transferred different in expected value is %p and slave observed value is %p", exp, obs))
    mismatch_detected = 1;
  end

  // check for no mismatch
  if(!mismatch_detected)
    `uvm_info(get_type_name(), $sformatf("Trans match between expected %p and observed %p", exp, obs), UVM_LOW)
  else
    mismatch_count++;
endfunction


`endif
