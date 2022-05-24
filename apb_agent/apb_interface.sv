`ifndef APB_INTF_SV
`define APB_INTF_SV
`timescale 1ns/1ps

interface apb_intf (input clk , input rstn) ;
    
  import uvm_pkg::* ;
  `include "uvm_macros.svh"

  logic [31:0] paddr   ;
  logic        pwrite  ;
  logic        psel    ;
  logic        penable ;
  logic [31:0] pwdata  ;
  logic [31:0] prdata  ;
  logic        pready  ;
  logic        pslverr ;

  //APB clocking block
  clocking cb_mst @(posedge clk) ;
    default input #1ns output #1ns ;
    output paddr , pwrite , psel , penable , pwdata ;
    input  prdata , pready , pslverr ;
  endclocking

  clocking cb_mon @(posedge clk) ;
    default input #1ns output #1ns ;
    input  paddr , pwrite , psel , penable , pwdata ;
    input  prdata , pready , pslverr ;
  endclocking

  //command covergroup
  covergroup cg_apb_command @(posedge clk iff rstn) ;
    pwrite: coverpoint pwrite{
      bins write = {1} ;
      bins read  = {0} ;
    }
    psel: coverpoint psel{
      bins sel = {1} ;
      bins unsel = {0} ;
    }
    cmd: cross pwrite , psel{
      bins cmd_write = binsof(pwrite.write) && binsof(psel.sel) ;
      bins cmd_read  = binsof(pwrite.read)  && binsof(psel.sel) ;
      bins cmd_idle  = binsof(psel.unsel) ;
    }
  endgroup: cg_apb_command

  //burst group
  covergroup cg_apb_burst @(posedge clk iff rstn) ;
    psel: coverpoint psel{
      bins single = (0 => 1 => 1 => 0) ;
      bins burst_2 = (0 => 1[*4] => 0) ;
      bins burst_4 = (0 => 1[*8] => 0) ;
    }
    penable: coverpoint penable{
      bins single = (0 => 1 => 0[*2:10] => 1) ;
      bins burst = (0 => 1 => 0 => 1) ;
    }
  endgroup: cg_apb_burst

  covergroup cg_apb_write_read_order @(posedge clk iff (rstn && penable)) ;
    write_read_order: coverpoint pwrite{
      bins write_write = (1 => 1) ;
      bins write_read  = (1 => 0) ;
      bins read_write  = (0 => 1) ;
      bins read_read   = (0 => 0) ;
    }
  endgroup: cg_apb_write_read_order
  
  initial begin : coverage_control
    automatic cg_apb_command apb_cg0 = new();
    automatic cg_apb_burst apb_cg1 = new();
    automatic cg_apb_write_read_order apb_cg2 = new();
  end

  // PROPERY ASSERTION
  property apb_paddr_no_x;
    @(posedge clk) psel |-> !$isunknown(paddr);
  endproperty: apb_paddr_no_x
  assert property(apb_paddr_no_x) else `uvm_error("ASSERT", "PADDR is unknown when PSEL is high")

  property apb_psel_rose_next_cycle_penable_rise;
    @(posedge clk) $rose(psel) |=> $rose(penable);
  endproperty: apb_psel_rose_next_cycle_penable_rise
  assert property(apb_psel_rose_next_cycle_penable_rise) else `uvm_error("ASSERT", "PENABLE not rose after 1 cycle PSEL rose")

  property apb_penable_rose_next_cycle_fall;
    @(posedge clk) penable && pready |=> $fell(penable);
  endproperty: apb_penable_rose_next_cycle_fall
  assert property(apb_penable_rose_next_cycle_fall) else `uvm_error("ASSERT", "PENABLE not fall after 1 cycle PENABLE rose")

  property apb_pwdata_stable_during_trans_phase;
    @(posedge clk) ((psel && !penable) ##1 (psel && penable)) |-> $stable(pwdata);
  endproperty: apb_pwdata_stable_during_trans_phase
  assert property(apb_pwdata_stable_during_trans_phase) else `uvm_error("ASSERT", "PWDATA not stable during transaction phase")

  property apb_paddr_stable_until_next_trans;
    logic[31:0] addr1, addr2;
    @(posedge clk) first_match(($rose(penable),addr1=paddr) ##1 ((psel && !penable)[=1],addr2=$past(paddr))) |-> addr1 == addr2;
  endproperty: apb_paddr_stable_until_next_trans
  assert property(apb_paddr_stable_until_next_trans) else `uvm_error("ASSERT", "PADDR not stable until next transaction start")

  property apb_pwrite_stable_until_next_trans;
    logic pwrite1, pwrite2;
    @(posedge clk) first_match(($rose(penable),pwrite1=pwrite) ##1 ((psel && !penable)[=1],pwrite2=$past(pwrite))) |-> pwrite1 == pwrite2;
  endproperty: apb_pwrite_stable_until_next_trans
  assert property(apb_pwrite_stable_until_next_trans) else `uvm_error("ASSERT", "PWRITE not stable until next transaction start")

  property apb_prdata_available_once_penable_rose;
    @(posedge clk) penable && !pwrite && pready |-> !$stable(prdata);
  endproperty: apb_prdata_available_once_penable_rose

  // PROPERTY COVERAGE
  property apb_write_during_nonburst_trans;
    @(posedge clk) $rose(penable) |-> pwrite throughout (##1 (!penable)[*2] ##1 penable[=1]);
  endproperty: apb_write_during_nonburst_trans
  cover property(apb_write_during_nonburst_trans);

  property apb_write_during_burst_trans;
    @(posedge clk) $rose(penable) |-> pwrite throughout (##2 penable);
  endproperty: apb_write_during_burst_trans
  cover property(apb_write_during_burst_trans);

  property apb_write_read_burst_trans;
    logic[31:0] addr;
    @(posedge clk) ($rose(penable) && pwrite, addr=paddr) |-> (##2 ($rose(penable) && !pwrite && addr==paddr)); 
  endproperty: apb_write_read_burst_trans
  cover property(apb_write_read_burst_trans);

  property apb_write_twice_read_burst_trans;
    logic[31:0] addr;
    @(posedge clk) ($rose(penable) && pwrite, addr=paddr) |-> (##2 ($rose(penable) && pwrite && addr==paddr) ##2 ($rose(penable) && !pwrite && addr==paddr) );
  endproperty: apb_write_twice_read_burst_trans
  cover property(apb_write_twice_read_burst_trans);

  property apb_read_during_nonburst_trans;
    @(posedge clk) $rose(penable) |-> !pwrite throughout (##1 (!penable)[*2] ##1 penable[=1]);
  endproperty: apb_read_during_nonburst_trans
  cover property(apb_read_during_nonburst_trans);

  property apb_read_during_burst_trans;
    @(posedge clk) $rose(penable) |-> !pwrite throughout (##2 penable);
  endproperty: apb_read_during_burst_trans
  cover property(apb_read_during_burst_trans);

  property apb_read_write_read_burst_trans;
    logic[31:0] addr;
    @(posedge clk) ($rose(penable) && pwrite, addr=paddr) |-> ##2 ($rose(penable) && !pwrite && addr==paddr);  
  endproperty: apb_read_write_read_burst_trans
  cover property(apb_read_write_read_burst_trans);


  initial begin: assertion_control
    fork
      forever begin
        wait(rstn == 0);
        $assertoff();
        wait(rstn == 1);
        $asserton();
      end
    join_none
  end

endinterface: apb_intf


`endif

      

