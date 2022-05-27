`ifndef ETH_SYSTEM_PKG_SV
`define ETH_SYSTEM_PKG_SV

package eth_sys_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import apb_pkg::* ;
import axi_pkg::* ;
import eth_pkg::* ;

`include "../testbench/eth_agent/eth_defines.svh"
`include "../testbench/axi_agent/axi_defines.svh"
`include "../testbench/eth_sys_pkg.svh"

endpackage: eth_sys_pkg

`include "../testbench/eth_sys_interface.sv"

`endif