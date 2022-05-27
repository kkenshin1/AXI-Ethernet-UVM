`ifndef ETH_PKG_SVH
`define ETH_PKG_SVH

`include "../testbench/eth_agent/eth_defines.svh"                  //eth基本信息定义
`include "../testbench/eth_agent/eth_types.sv"                     //eth基本类型
`include "../testbench/eth_agent/eth_base_config.sv"               //eth基本配置模块
`include "../testbench/eth_agent/eth_agent_config.sv"              //eth agent配置模块
`include "../testbench/eth_agent/eth_config.sv"                    //eth总配置模块(包括eth master和slave cfg)
`include "../testbench/eth_agent/eth_transaction.sv"               //eth基础事务包
`include "../testbench/eth_agent/eth_bfm_common.sv"                //eth基础总线模型


`include "../testbench/eth_agent/eth_master_driver_common.sv"      //eth master driver总线模型
`include "../testbench/eth_agent/eth_master_driver.sv"             //eth master driver
`include "../testbench/eth_agent/eth_master_monitor_common.sv"     //eth master monitor总线模型
`include "../testbench/eth_agent/eth_master_monitor.sv"            //eth master monitor
`include "../testbench/eth_agent/eth_master_sequencer.sv"          //eth master sequencer
`include "../testbench/eth_agent/eth_master_agent.sv"              //eth master agent
`include "../testbench/eth_agent/eth_master_seq_lib.sv"            //eth master sequence library


`include "../testbench/eth_agent/eth_slave_driver_common.sv"       //eth slave driver总线模型
`include "../testbench/eth_agent/eth_slave_driver.sv"              //eth slave driver
`include "../testbench/eth_agent/eth_slave_monitor_common.sv"      //eth slave monitor总线模型
`include "../testbench/eth_agent/eth_slave_monitor.sv"             //eth slave monitor
`include "../testbench/eth_agent/eth_slave_sequencer.sv"           //eth slave sequencer
`include "../testbench/eth_agent/eth_slave_agent.sv"               //eth slave agent
//`include "../testbench/eth_agent/eth_slave_seq_lib.sv"             //eth slave sequence library

`endif