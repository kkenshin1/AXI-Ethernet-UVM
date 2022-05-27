`ifndef ETH_MASTER_SEQ_LIB_SV
`define ETH_MASTER_SEQ_LIB_SV

class eth_master_base_sequence extends uvm_sequence #(eth_trans);

  `uvm_object_utils(eth_master_base_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction

endclass: eth_master_base_sequence 


class eth_master_write_sequence extends eth_master_base_sequence;
  rand mac_addr_type source_mac ;   
  rand mac_addr_type dest_mac ;    
  rand ip_addr_type source_ip ;
  rand ip_addr_type dest_ip ;
  rand port_id_type source_port ;
  rand port_id_type dest_port ;
  rand int data_size ;
  eth_trans_status trans_resp ;

  `uvm_object_utils(eth_master_write_sequence)

  function new(string name=""); 
    super.new(name);
  endfunction

  virtual task body();
    eth_trans req , rsp ;
    `uvm_info(get_type_name(),"starting ETH master write sequence", UVM_HIGH)
	  `uvm_do_with(req, { source_mac == local::source_mac ;
                        dest_mac == local::dest_mac ;
                        source_ip == local::source_ip ;
                        dest_ip == local::dest_ip ;
                        source_port == local::source_port ;
                        dest_port == local::dest_port ;
                        payload.size == local::data_size ;
                      })
    get_response(rsp);
    trans_resp = rsp.eth_status;
    `uvm_info(get_type_name(),$psprintf("Done sequence: %s",req.convert2string()), UVM_HIGH)
  endtask

endclass: eth_master_write_sequence

`endif