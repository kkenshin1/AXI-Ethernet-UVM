`ifndef AXI_PKG_SV
`define AXI_PKG_SV

package axi_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../testbench/axi_agent/axi_pkg.svh"

endpackage: axi_pkg

`include "../testbench/axi_agent/axi_interface.sv"             //AXI interface
   
`endif
