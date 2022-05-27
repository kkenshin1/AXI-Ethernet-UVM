`timescale 1ns/1ns

module eth_tb_top() ;
  parameter real apb_clk_peroid = 20ns ;          //50M
  parameter real axi_clk_peroid = 20ns ;          //50M
  parameter real eth_clk_peroid = 8ns  ;          //125M

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import eth_sys_pkg::*;

  logic apb_clk  ;
  logic apb_rstn ;
  logic axi_clk  ;
  logic axi_rstn ;
  logic eth_clk  ;
  logic led ;

  GTP_GRS GRS_INST(
    .GRS_N(1'b1)
  );

  axi_ethernet_v3 dut(
  //AXI-4 Slave Signals
    .aclk(axi_clk),
    .aresetn(axi_rstn),

    .aw_addr(axi_if.aw_addr),
    .aw_prot(axi_if.aw_prot),
    .aw_region(axi_if.aw_region),
    .aw_len(axi_if.aw_len),
    .aw_size(axi_if.aw_size),
    .aw_burst(axi_if.aw_burst),
    .aw_lock(axi_if.aw_lock),
    .aw_cache(axi_if.aw_cache),
    .aw_qos(axi_if.aw_qos),
    .aw_id(axi_if.aw_id),
    .aw_user(axi_if.aw_user),
    .aw_ready(axi_if.aw_ready),
    .aw_valid(axi_if.aw_valid),

    .ar_addr(axi_if.ar_addr),
    .ar_prot(axi_if.ar_prot),
    .ar_region(axi_if.ar_region),
    .ar_len(axi_if.ar_len),
    .ar_size(axi_if.ar_size),
    .ar_burst(axi_if.ar_burst),
    .ar_lock(axi_if.ar_lock),
    .ar_cache(axi_if.ar_cache),
    .ar_qos(axi_if.ar_qos),
    .ar_id(axi_if.ar_id),
    .ar_user(axi_if.ar_user),
    .ar_ready(axi_if.ar_ready),
    .ar_valid(axi_if.ar_valid),

    .w_valid(axi_if.w_valid),
    .w_data(axi_if.w_data),
    .w_strb(axi_if.w_strb),
    .w_user(axi_if.w_user),
    .w_last(axi_if.w_last),
    .w_ready(axi_if.w_ready),

    .r_data(axi_if.r_data),
    .r_resp(axi_if.r_resp),
    .r_last(axi_if.r_last),
    .r_id(axi_if.r_id),
    .r_user(axi_if.r_user),
    .r_ready(axi_if.r_ready),
    .r_valid(axi_if.r_valid),

    .b_resp(axi_if.b_resp),
    .b_id(axi_if.b_id),
    .b_user(axi_if.b_user),
    .b_ready(axi_if.b_ready),
    .b_valid(axi_if.b_valid),

    .free_clk(axi_clk),
    .phy_rst_n(eth_if.rstn),
    .rx_clki(eth_if.txd_clk),
    .phy_rx_dv(eth_if.txd_ctl),
    .phy_rxd0(eth_if.txd[0]),
    .phy_rxd1(eth_if.txd[1]),  
    .phy_rxd2(eth_if.txd[2]),  
    .phy_rxd3(eth_if.txd[3]),  
    .tx_clko(eth_if.rxd_clk),
    .phy_tx_en(eth_if.rxd_ctl),
    .phy_txd0(eth_if.rxd[0]),
    .phy_txd1(eth_if.rxd[1]),
    .phy_txd2(eth_if.rxd[2]),
    .phy_txd3(eth_if.rxd[3]),
    .led(led),

  //APB Interface
    .pclk(apb_clk),
    .presetn(apb_rstn),
    .paddr(apb_if.paddr),
    .pwrite(apb_if.pwrite),
    .psel(apb_if.psel),
    .penable(apb_if.penable),
    .pwdata(apb_if.pwdata),
    .prdata(apb_if.prdata),
    .pready(apb_if.pready),
    .pslverr(apb_if.pslverr),

    .irq(eth_sys_if.intr)

  );

  //clock control 
  initial begin
    apb_clk <= 0 ;
    axi_clk <= 0 ;
    eth_clk <= 0 ;
    fork
      forever begin
        #(apb_clk_peroid/2) apb_clk <= ~ apb_clk ;
      end
      forever begin
        #(axi_clk_peroid/2) axi_clk <= ~ axi_clk ;
      end
      forever begin
        #(eth_clk_peroid/2) eth_clk <= ~ eth_clk ;
      end
    join_none  
  end

  //reset control
  initial begin
    #10ns ;
    apb_rstn <= 0 ;
    axi_rstn <= 0 ;
    repeat(10) @(posedge apb_clk) ;
    apb_rstn <= 1 ;
    axi_rstn <= 1 ;
  end

  apb_intf apb_if(apb_clk , apb_rstn) ;
  axi_intf axi_if(axi_clk , axi_rstn) ;
  eth_intf eth_if() ;
  eth_sys_intf eth_sys_if() ;
  assign eth_sys_if.apb_clk  = apb_clk ;
  assign eth_sys_if.apb_rstn = apb_rstn ;
  assign eth_sys_if.axi_clk  = axi_clk ;
  assign eth_sys_if.axi_rstn = axi_rstn ;
  assign eth_if.txd_clk = eth_clk ;


  initial begin 
    // do interface configuration from top tb (HW) to verification env (SW)
    uvm_config_db#(virtual apb_intf)::set(uvm_root::get(), "uvm_test_top.env.apb_mst*", "apb_vif", apb_if);
    uvm_config_db#(virtual axi_intf)::set(uvm_root::get(), "uvm_test_top.env.axi_mst*", "axi_vif", axi_if);
    uvm_config_db#(virtual eth_intf)::set(uvm_root::get(), "uvm_test_top.env", "eth_vif", eth_if);
    uvm_config_db#(virtual eth_sys_intf)::set(uvm_root::get(), "uvm_test_top.env", "eth_sys_vif", eth_sys_if);
    run_test("eth_sys_read_write_test");
  end


endmodule: eth_tb_top