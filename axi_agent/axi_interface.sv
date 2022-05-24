`ifndef AXI_INTF_SV
`define AXI_INTF_SV
`timescale 1ns/1ps

interface axi_intf (input clk , input rstn) ;

  import uvm_pkg::* ;
  `include "uvm_macros.svh"

  //AW channel
  logic [`AXI_ADDR_WIDTH-1:0]   aw_addr    ;
  logic [`AXI_PROT_WIDTH-1:0]   aw_prot    ;
  logic [`AXI_REGION_WIDTH-1:0] aw_region  ;
  logic [`AXI_LEN_WIDTH-1:0]    aw_len     ;
  logic [`AXI_SIZE_WIDTH-1:0]   aw_size    ;
  logic [`AXI_BURST_WIDTH-1:0]  aw_burst   ;
  logic                         aw_lock    ;
  logic [`AXI_CACHE_WIDTH-1:0]  aw_cache   ;
  logic [`AXI_QOS_WIDTH-1:0]    aw_qos     ;
  logic [`AXI_ID_WIDTH-1:0]     aw_id      ;
  logic [`AXI_USER_WIDTH-1:0]   aw_user    ;
  logic                         aw_ready   ;
  logic                         aw_valid   ;

  //AR channel
  logic [`AXI_ADDR_WIDTH-1:0]   ar_addr    ;
  logic [`AXI_PROT_WIDTH-1:0]   ar_prot    ;
  logic [`AXI_REGION_WIDTH-1:0] ar_region  ;
  logic [`AXI_LEN_WIDTH-1:0]    ar_len     ;
  logic [`AXI_SIZE_WIDTH-1:0]   ar_size    ;
  logic [`AXI_BURST_WIDTH-1:0]  ar_burst   ;
  logic                         ar_lock    ;
  logic [`AXI_CACHE_WIDTH-1:0]  ar_cache   ;
  logic [`AXI_QOS_WIDTH-1:0]    ar_qos     ;
  logic [`AXI_ID_WIDTH-1:0]     ar_id      ;
  logic [`AXI_USER_WIDTH-1:0]   ar_user    ;
  logic                         ar_ready   ;
  logic                         ar_valid   ;

  //W channel
  logic                        w_valid    ;
  logic [`AXI_DATA_WIDTH-1:0]  w_data     ;
  logic [`AXI_STRB_WIDTH-1:0]  w_strb     ;
  logic [`AXI_USER_WIDTH-1:0]  w_user     ;
  logic                        w_last     ;
  logic                        w_ready    ;

  //R channel
  logic [`AXI_DATA_WIDTH-1:0]  r_data     ;
  logic [`AXI_RESP_WIDTH-1:0]  r_resp     ;
  logic                        r_last     ;
  logic [`AXI_ID_WIDTH-1:0]    r_id       ;
  logic [`AXI_USER_WIDTH-1:0]  r_user     ;
  logic                        r_ready    ;
  logic                        r_valid    ;

  //B channel
  logic [`AXI_RESP_WIDTH-1:0]  b_resp     ;
  logic [`AXI_ID_WIDTH-1:0]    b_id       ;
  logic [`AXI_USER_WIDTH-1:0]  b_user     ;
  logic                        b_ready    ;
  logic                        b_valid    ;

  //AXI clocking block
  clocking cb_mst @(posedge clk) ;
    default input #1ns output #1ns ;
    //AW channel
    output  aw_addr, aw_prot, aw_region, aw_len, aw_size, aw_burst, 
            aw_lock, aw_cache, aw_qos, aw_id, aw_user, aw_valid ;
    input   aw_ready ;
    //W channel
    output  w_valid, w_data, w_strb, w_user, w_last ;
    input   w_ready  ;
    //B channel
    output  b_ready  ;
    input   b_resp, b_id, b_user, b_valid ;
    //AR channel
    output  ar_addr, ar_prot, ar_region, ar_len, ar_size, ar_burst, 
            ar_lock, ar_cache, ar_qos, ar_id, ar_user, ar_valid ;
    input   ar_ready ;
    //R channel
    output  r_ready  ;
    input   r_data, r_resp, r_last, r_id, r_user, r_valid ;
  endclocking: cb_mst


  clocking cb_mon @(posedge clk) ;
    default input #1ns output #1ns ;
    //AW channel
    input   aw_addr, aw_prot, aw_region, aw_len, aw_size, aw_burst, 
            aw_lock, aw_cache, aw_qos, aw_id, aw_user, aw_valid ;
    input   aw_ready ;
    //W channel
    input   w_valid, w_data, w_strb, w_user, w_last ;
    input   w_ready  ;
    //B channel
    input   b_ready  ;
    input   b_resp, b_id, b_user, b_valid ;
    //AR channel
    input   ar_addr, ar_prot, ar_region, ar_len, ar_size, ar_burst, 
            ar_lock, ar_cache, ar_qos, ar_id, ar_user, ar_valid ;
    input   ar_ready ;
    //R channel
    input   r_ready  ;
    input   r_data, r_resp, r_last, r_id, r_user, r_valid ;
  endclocking: cb_mon

  covergroup cg_axi_command @(posedge clk iff rstn) ;
    axi_write_en: coverpoint aw_valid{
      bins write_en_on  = {1} ;
      bins write_en_off = {0} ;
    }
    axi_write_rsp: coverpoint aw_ready{
      bins write_rsp_on  = {1} ;
      bins write_rsp_off = {0} ;
    }
    axi_read_en: coverpoint ar_valid{
      bins read_en_on  = {1} ;
      bins read_en_off = {0} ;
    }
    axi_read_rsp: coverpoint ar_ready{
      bins read_rsp_on  = {1} ;
      bins read_rsp_off = {0} ;
    }
    cmd: cross axi_write_en,axi_write_rsp,axi_read_en,axi_read_rsp{
      bins cmd_write = binsof(axi_write_en.write_en_on) && binsof(axi_write_rsp.write_rsp_on) ;
      bins cmd_read  = binsof(axi_read_en.read_en_on)  && binsof(axi_read_rsp.read_rsp_on) ;
      bins cmd_write_idle = binsof(axi_write_en.write_en_off) ;
      bins cmd_read_idle = binsof(axi_read_en.read_en_off) ;
    }
  endgroup: cg_axi_command

  covergroup cg_axi_write_type @(posedge clk iff (rstn && aw_valid && aw_ready)) ;
    axi_wr_burst_type: coverpoint aw_burst{
      bins burst_fixed = {2'b00} ;
      bins burst_incr = {2'b01} ;
      bins burst_wrap = {2'b10} ;
      ignore_bins burst_reserved = {2'b11} ;
    }
    axi_wr_burst_len: coverpoint aw_len{
      bins low_len = {[0:3]} ;
      bins middle_len = {[4:11]} ;
      bins high_len = {[12:15]} ;
      ignore_bins ig_len = {[16:$]} ;
    }
    axi_wr_byte_size: coverpoint aw_size{
      bins low_size = {0,1,2} ;
      bins middle_size = {3,4,5} ;
      bins high_size = {6,7} ;
    }
    write_type: cross axi_wr_burst_type,axi_wr_burst_len,axi_wr_byte_size ;
  endgroup: cg_axi_write_type

  covergroup cg_axi_read_type @(posedge clk iff (rstn && ar_valid && ar_ready)) ;
    axi_rd_burst_type: coverpoint ar_burst{
      bins burst_fixed = {2'b00} ;
      bins burst_incr = {2'b01} ;
      bins burst_wrap = {2'b10} ;
      ignore_bins burst_reserved = {2'b11} ;
    }
    axi_rd_burst_len: coverpoint ar_len{
      bins low_len = {[0:3]} ;
      bins middle_len = {[4:11]} ;
      bins high_len = {[12:15]} ;
      ignore_bins ig_len = {[16:$]} ;
    }
    axi_rd_byte_size: coverpoint ar_size{
      bins low_size = {0,1,2} ;
      bins middle_size = {3,4,5} ;
      bins high_size = {6,7} ;
    }
    read_type: cross axi_rd_burst_type,axi_rd_burst_len,axi_rd_byte_size ;
  endgroup: cg_axi_read_type

  initial begin : coverage_control
    automatic cg_axi_command axi_cg0 = new();
    automatic cg_axi_write_type axi_cg1 = new();
    automatic cg_axi_read_type axi_cg2 = new();
  end

  // PROPERY ASSERTION
  property axi_wraddr_no_x;
    @(posedge clk) (aw_valid && aw_ready) |-> !$isunknown(aw_addr) ;
  endproperty: axi_wraddr_no_x
  assert property(axi_wraddr_no_x) else `uvm_error("ASSERT", "AWADDR is unknown when AWVALID and AWREADY is high")

  property axi_wdata_no_x;
    @(posedge clk) (w_valid && w_ready) |-> !$isunknown(w_data) ;
  endproperty: axi_wdata_no_x
  assert property(axi_wdata_no_x) else `uvm_error("ASSERT", "WDATA is unknown when WVALID and WREADY is high")

  property axi_bresp_no_x;
    @(posedge clk) (b_valid && b_ready) |-> !$isunknown(b_resp) ;
  endproperty: axi_bresp_no_x
  assert property(axi_bresp_no_x) else `uvm_error("ASSERT", "BRESP is unknown when BVALID and BREADY is high")

  property axi_araddr_no_x;
    @(posedge clk) (ar_valid && ar_ready) |-> !$isunknown(ar_addr) ;
  endproperty: axi_araddr_no_x
  assert property(axi_araddr_no_x) else `uvm_error("ASSERT", "ARADDR is unknown when ARVALID and ARREADY is high")

  property axi_rdata_no_x;
    @(posedge clk) (r_valid && r_ready) |-> !$isunknown(r_data) ;
  endproperty: axi_rdata_no_x
  assert property(axi_rdata_no_x) else `uvm_error("ASSERT", "RDATA is unknown when RVALID and RREADY is high")

  initial begin: assetion_control
    fork
      forever begin
        wait(rstn == 0);
        $assertoff();
        wait(rstn == 1);
        $asserton();
      end
    join_none
  end

    
endinterface: axi_intf


`endif