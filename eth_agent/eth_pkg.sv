`ifndef ETH_PKG_SV
`define ETH_PKG_SV

//对于MASTER来说，source是TB，dest是DUT
//对于SLAVE来说，source是DUT，dest是TB
package eth_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../testbench/eth_agent/eth_pkg.svh"

endpackage: eth_pkg

`include "../testbench/eth_agent/eth_interface.sv"             //ETH interface
   
`endif