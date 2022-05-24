`ifndef AXI_MASTER_SEQ_LIB_SV
`define AXI_MASTER_SEQ_LIB_SV

class axi_master_base_sequence extends uvm_sequence #(axi_trans);

  `uvm_object_utils(axi_master_base_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction

endclass: axi_master_base_sequence 

class axi_master_single_write_sequence extends axi_master_base_sequence;
  rand bit [31:0]         addr;
  rand axi_burst_type_enum     trans_burst_type ;    
  rand axi_byte_size_enum      trans_byte_size  ;    
  rand axi_burst_length_enum   trans_burst_len  ;    
  rand axi_response_enum       trans_resp_type  ;  
  axi_response_enum            trans_resp;

  `uvm_object_utils(axi_master_single_write_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction

  virtual task body();
    axi_trans req , rsp ;
    `uvm_info(get_type_name(),"starting AXI single write sequence", UVM_HIGH)
    `uvm_do_with(req, { trans_kind == WRITE; 
                        addr == local::addr; 
                        trans_burst_type == local::trans_burst_type ;
                        trans_byte_size == local::trans_byte_size ;
                        trans_burst_len == local::trans_burst_len ;
                        data.size == get_burst_len(local::trans_burst_len)+1 ;
                      })
    get_response(rsp);
    trans_resp = rsp.trans_resp_type;
    `uvm_info(get_type_name(),$psprintf("Done sequence: %s",req.convert2string()), UVM_HIGH)
  endtask

endclass: axi_master_single_write_sequence

class axi_master_single_read_sequence extends axi_master_base_sequence;
  rand bit [31:0]         addr;
	rand axi_burst_type_enum     trans_burst_type ;    
  rand axi_byte_size_enum      trans_byte_size  ;    
  rand axi_burst_length_enum   trans_burst_len  ;    
  rand axi_response_enum  trans_resp_type  ;  
  axi_response_enum       trans_resp;

  `uvm_object_utils(axi_master_single_read_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction

  virtual task body();
    axi_trans req , rsp ;
    `uvm_info(get_type_name(),"starting AXI single read sequence", UVM_HIGH)
    `uvm_do_with(req, { trans_kind == READ  ; 
                        addr == local::addr ;  
                        trans_burst_type == local::trans_burst_type ;
                        trans_byte_size == local::trans_byte_size ;
                        trans_burst_len == local::trans_burst_len ;
                        data.size == get_burst_len(local::trans_burst_len)+1 ;
                      })
    get_response(rsp);
    trans_resp = rsp.trans_resp_type;
    `uvm_info(get_type_name(),$psprintf("Done sequence: %s",req.convert2string()), UVM_HIGH)
  endtask

endclass: axi_master_single_read_sequence


`endif