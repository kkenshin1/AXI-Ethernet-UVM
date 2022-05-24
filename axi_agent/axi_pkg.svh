`ifndef AXI_PKG_SVH
`define AXI_PKG_SVH

`include "../testbench/axi_agent/axi_defines.svh"              //AXI基础信息定义
`include "../testbench/axi_agent/axi_types.sv"                 //AXI基础信息定义
`include "../testbench/axi_agent/axi_transaction.sv"           //AXI事务基础结构包

`include "../testbench/axi_agent/axi_master_driver.sv"         //AXI MASTER DRIVER
`include "../testbench/axi_agent/axi_master_monitor.sv"        //AXI MASTER MONITOR
`include "../testbench/axi_agent/axi_master_sequencer.sv"      //AXI MASTER SEQUENCER
`include "../testbench/axi_agent/axi_master_agent.sv"          //AXI MASTER AGENT
`include "../testbench/axi_agent/axi_master_seq_lib.sv"        //AXI MASTER SEQUENCE LIB

`endif
