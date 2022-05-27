`ifndef ETH_SYS_INTF_SV
`define ETH_SYS_INTF_SV

interface eth_sys_intf;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  logic apb_clk;
  logic apb_rstn;
  logic axi_clk;
  logic axi_rstn;

  // Ethernet system interrupt ports 
  logic intr;

  clocking apb_ck @(posedge apb_clk);
    default input #1ps output #1ps;
  endclocking

  clocking axi_ck @(posedge axi_clk);
    default input #1ps output #1ps;
  endclocking

  task wait_apb(int n);
    repeat(n) @(apb_ck);
  endtask

  task wait_axi(int n);
    repeat(n) @(axi_ck);
  endtask

  task wait_intr();
    @(intr iff intr === 1'b1);
  endtask

  function int get_intr();
    return intr; 
  endfunction

  task wait_rstn_release();
    fork
      @(posedge apb_rstn);
      @(posedge axi_rstn);
    join
  endtask

endinterface

`endif