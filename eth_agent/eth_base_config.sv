`ifndef ETH_BASE_CONFIG_SV
`define ETH_BASE_CONFIG_SV

class eth_base_config extends uvm_object;

  string inst ;

  `uvm_object_utils_begin(eth_base_config)
    `uvm_field_string(inst, UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name = "eth_base_config");
    super.new(name);
  endfunction

endclass: eth_base_config

`endif