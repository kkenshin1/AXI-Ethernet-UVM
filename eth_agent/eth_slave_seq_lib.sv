`ifndef ETH_SLAVE_SEQ_LIB_SV
`define ETH_SLAVE_SEQ_LIB_SV

class eth_slave_base_sequence extends uvm_sequence #(axi_trans);

  `uvm_object_utils(eth_slave_base_sequence)    
  function new(string name="eth_slave_base_sequence"); 
    super.new(name);
  endfunction

endclass: eth_slave_base_sequence 



`endif