`ifndef ETH_SYS_COVERAGE_MODEL_SV
`define ETH_SYS_COVERAGE_MODEL_SV

class eth_sys_coverage_model extends uvm_component;

  uvm_analysis_imp_apb_master #(apb_trans, eth_sys_coverage_model) apb_mst_trans_observed_imp;
  uvm_analysis_imp_axi_master #(axi_trans, eth_sys_coverage_model) axi_mst_trans_observed_imp;
  uvm_analysis_imp_eth_master #(eth_trans, eth_sys_coverage_model) eth_mst_trans_observed_imp;
  uvm_analysis_imp_eth_slave  #(eth_trans, eth_sys_coverage_model) eth_slv_trans_observed_imp;

  uvm_event eth_sys_field_access_fd_e; 

  eth_sys_config cfg;
  eth_sys_rgm rgm ;
  virtual eth_sys_intf vif ; 

  `uvm_component_utils(eth_sys_coverage_model)
  
  //source、dest、gateway ip cg
  covergroup srcip_and_destip_cg with function sample(bit[31:0]ip, string field);
    option.name = "srcip_and_destip_cg";
    SRC_IP: coverpoint ip iff(field == "SRC"){
      wildcard bins ip1 = {32'hc0_a8_00_xx};
      wildcard bins ip2 = {32'hc0_a8_01_xx};
    }
    DEST_IP: coverpoint ip iff(field == "DST"){
      wildcard bins ip1 = {32'hc0_a8_00_xx};
      wildcard bins ip2 = {32'hc0_a8_01_xx};
    }
    GATEWAY_IP: coverpoint ip iff(field == "GATEWAY"){
      wildcard bins ip1 = {32'hc0_a8_00_xx};
      wildcard bins ip2 = {32'hc0_a8_01_xx};
    }
  endgroup: srcip_and_destip_cg

  //source、dest port cg
  covergroup srcport_and_destport_cg with function sample(bit[15:0]port, string field);
    option.name = "srcport_and_destport_cg";
    SRC_PORT: coverpoint port iff(field == "SRC"){
      bins port1 = {16'h1f90};
    }
    DEST_PORT: coverpoint port iff(field == "DST"){
      bins port1 = {16'h1f90};
    }
  endgroup: srcport_and_destport_cg

  //tx ctr en cg
  covergroup tx_en_cg with function sample(bit en);
    option.name = "tx_en_cg";
    TX_UDP_EN: coverpoint en {
      bins tx_en_on = {1};
      bins tx_en_off = {0};
    }
  endgroup

  // tx udp len and rx udp len cg
  covergroup udp_len_cg with function sample(bit [15:0] len, string field);
    option.name = "udp_len_cg";
    TX_UDP_LEN: coverpoint len iff(field == "TX_UDP") {
      bins low_len = {[1:18]};
      bins other_len = {[19:$]};
    }
    RX_UDP_LEN: coverpoint len iff(field == "RX_UDP") {
      bins low_len = {[1:18]};
      bins other_len = {[19:$]};
    }
  endgroup

  extern function new(string name = "eth_sys_coverage_model", uvm_component parent) ;
  extern function void build_phase(uvm_phase phase) ;
  extern task run_phase(uvm_phase phase) ;
  //write函数重写
  extern virtual function void write_apb_master(apb_trans tr) ;
  extern virtual function void write_axi_master(axi_trans tr) ;
  extern virtual function void write_eth_master(eth_trans tr) ;
  extern virtual function void write_eth_slave(eth_trans tr) ;
  extern virtual task do_sample_regs() ;

endclass: eth_sys_coverage_model

function eth_sys_coverage_model::new(string name = "eth_sys_coverage_model", uvm_component parent);
  super.new(name, parent);

  srcip_and_destip_cg = new();
  srcport_and_destport_cg = new();
  tx_en_cg = new();
  udp_len_cg = new();
endfunction

function void eth_sys_coverage_model::build_phase(uvm_phase phase);
  super.build_phase(phase);

  apb_mst_trans_observed_imp = new("apb_mst_trans_observed_imp", this);
  axi_mst_trans_observed_imp = new("axi_mst_trans_observed_imp", this);
  eth_mst_trans_observed_imp = new("eth_mst_trans_observed_imp", this);
  eth_slv_trans_observed_imp = new("eth_slv_trans_observed_imp", this);

  eth_sys_field_access_fd_e = uvm_event_pool::get_global("eth_sys_field_access_fd_e");

  if(!uvm_config_db #(eth_sys_config)::get(this, "", "cfg", cfg)) begin
    `uvm_error("build_phase", "Unable to get eth_sys_config from uvm_config_db")
  end
  rgm = cfg.rgm;
  vif = cfg.vif;
endfunction

task eth_sys_coverage_model::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork
    do_sample_regs();
  join_none
endtask

function void eth_sys_coverage_model::write_apb_master(apb_trans tr);
  uvm_reg r;
  if(tr.trans_status == apb_pkg::ERROR) return;
  r = cfg.rgm.default_map.get_reg_by_offset(tr.addr);
  eth_sys_field_access_fd_e.trigger(r);
endfunction

function void eth_sys_coverage_model::write_axi_master(axi_trans tr);
  //Nothing to do
endfunction

function void eth_sys_coverage_model::write_eth_master(eth_trans tr);
  //Nothing to do
endfunction

function void eth_sys_coverage_model::write_eth_slave(eth_trans tr);
  //Nothing to do
endfunction

task eth_sys_coverage_model::do_sample_regs();
  uvm_object tmp;
  uvm_reg r;
  forever begin
    eth_sys_field_access_fd_e.wait_trigger_data(tmp);
    void'($cast(r, tmp));
    // ensure RGM mirror value has been updated by monitor transaction
    #1ps; 
    if(r.get_name() == "local_ip") begin
      srcip_and_destip_cg.sample(rgm.local_ip.get(), "SRC");
    end
    else if(r.get_name() == "tx_dst_ip") begin
      srcip_and_destip_cg.sample(rgm.tx_dst_ip.get(), "DST");
    end
    else if(r.get_name() == "gateway_ip") begin
      srcip_and_destip_cg.sample(rgm.gateway_ip.get(), "GATEWAY");
    end
    else if(r.get_name() == "tx_src_port") begin
      srcport_and_destport_cg.sample(rgm.tx_src_port.src_port.get(), "SRC");
    end
    else if(r.get_name() == "tx_dst_port") begin
      srcport_and_destport_cg.sample(rgm.tx_dst_port.dst_port.get(), "DST");
    end
    else if(r.get_name() == "tx_ctr") begin
      tx_en_cg.sample(rgm.tx_ctr.tx_en.get());
    end
    else if(r.get_name() == "tx_udp_len") begin
      udp_len_cg.sample(rgm.tx_udp_len.udp_len.get(), "TX_UDP");
    end
    else if(r.get_name() == "rx_udp_len") begin
      udp_len_cg.sample(rgm.rx_udp_len.udp_len.get(), "RX_UDP");
    end
  end
endtask

 
`endif
