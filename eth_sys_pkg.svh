`ifndef ETH_SYSTEM_PKG_SVH
`define ETH_SYSTEM_PKG_SVH


`include "../testbench/system_reg/eth_sys_regmodel.sv"                //ethernet system寄存器模型
`include "../testbench/eth_sys_config.sv"                             //ehternet system configuration

`include "../testbench/system_env/eth_sys_virtual_sequencer.sv"       //ethernet system virtual sequencer
`include "../testbench/system_env/eth_sys_scoreboard.sv"              //ethernet system scoreboard
`include "../testbench/system_env/eth_sys_coverage_model.sv"              //ethernet system scoreboard
`include "../testbench/system_env/eth_sys_environment.sv"             //ethernet system environment


`include "../testbench/system_seq_lib/reg_config_seq_lib/eth_sys_apb_config_sequence.sv" //ethernet system reg access sequence
`include "../testbench/system_seq_lib/eth_sys_base_sequence.sv"       //ethernet system base virtual sequence
`include "../testbench/system_seq_lib/eth_sys_reg_access_virt_seq.sv" //ethernet system reg access sequence
`include "../testbench/system_seq_lib/eth_sys_axi_single_write_virt_seq.sv"  //ethernet system axi write sequence
`include "../testbench/system_seq_lib/eth_sys_axi_burst_write_virt_seq.sv"  //ethernet system axi write sequence
`include "../testbench/system_seq_lib/eth_sys_axi_burst_read_virt_seq.sv"  //ethernet system axi write sequence
`include "../testbench/system_seq_lib/eth_sys_axi_fixed_burst_write_virt_seq.sv"  //ethernet system axi write sequence
`include "../testbench/system_seq_lib/eth_sys_axi2eth_unalign_write_virt_seq.sv"  //ethernet system axi write sequence
`include "../testbench/system_seq_lib/eth_sys_axi2eth_burst_write_virt_seq.sv"  //ethernet system axi write sequence
`include "../testbench/system_seq_lib/eth_sys_axi2eth_change_udplen_write_virt_seq.sv"  //ethernet system axi write sequence
`include "../testbench/system_seq_lib/eth_sys_axi2eth_narrow_data_write_virt_seq.sv"  //ethernet system axi write sequence
`include "../testbench/system_seq_lib/eth_sys_eth2axi_single_read_virt_seq.sv"  //ethernet system master write sequence
`include "../testbench/system_seq_lib/eth_sys_eth2axi_narrow_data_read_virt_seq.sv"  //ethernet system axi write sequence
`include "../testbench/system_seq_lib/eth_sys_eth2axi_burst_read_virt_seq.sv"  //ethernet system axi write sequence
`include "../testbench/system_seq_lib/eth_sys_read_write_virt_seq.sv"  //ethernet system axi write sequence


`include "../testbench/system_test/eth_sys_base_test.sv"              //ethernet system base test
`include "../testbench/system_test/eth_sys_reg_access_test.sv"        //ethernet system reg access test
`include "../testbench/system_test/eth_sys_axi_single_write_test.sv"         //ethernet system axi write test
`include "../testbench/system_test/eth_sys_axi_burst_write_test.sv"         //ethernet system axi write test
`include "../testbench/system_test/eth_sys_axi_burst_read_test.sv"         //ethernet system axi write test
`include "../testbench/system_test/eth_sys_axi_fixed_burst_write_test.sv"         //ethernet system axi write test
`include "../testbench/system_test/eth_sys_axi2eth_unalign_write_test.sv"         //ethernet system axi write test
`include "../testbench/system_test/eth_sys_axi2eth_burst_write_test.sv"         //ethernet system axi write test
`include "../testbench/system_test/eth_sys_axi2eth_change_udplen_write_test.sv"         //ethernet system axi write test
`include "../testbench/system_test/eth_sys_axi2eth_narrow_data_write_test.sv"         //ethernet system axi write test
`include "../testbench/system_test/eth_sys_eth2axi_single_read_test.sv"         //ethernet system master write test
`include "../testbench/system_test/eth_sys_eth2axi_narrow_data_read_test.sv"         //ethernet system master write test
`include "../testbench/system_test/eth_sys_eth2axi_burst_read_test.sv"         //ethernet system master write test
`include "../testbench/system_test/eth_sys_read_write_test.sv"         //ethernet system master write test


`endif