`ifndef APB_PKG_SV
`define APB_PKG_SV

package apb_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../testbench/apb_agent/apb_pkg.svh"

endpackage: apb_pkg

`include "../testbench/apb_agent/apb_interface.sv"              //APB interface
   
`endif
