`ifndef ETH_INTF_SV
`define ETH_INTF_SV

interface eth_intf;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  logic rstn ;
  //tx信号
  logic txd_clk ;
  logic txd_ctl ;
  logic [3:0] txd ;
  //rx信号
  logic rxd_clk ;
  logic rxd_ctl ;
  logic [3:0] rxd ;

  modport eth_mst_intf (
    input rstn ,
    output txd_clk ,
    output txd_ctl ,
    output txd ,
    input rxd_clk ,
    input rxd_ctl ,
    input rxd 
  );

  modport eth_slv_intf (
    input rstn ,
    input txd_clk ,
    input txd_ctl ,
    input txd ,
    output rxd_clk ,
    output rxd_ctl ,
    output rxd 
  );

  modport eth_mon_intf (
    input rstn ,
    input txd_clk ,
    input txd_ctl ,
    input txd ,
    input rxd_clk ,
    input rxd_ctl ,
    input rxd 
  );

  task wait_rstn_release();
    @(posedge rstn);
  endtask

endinterface: eth_intf

`endif