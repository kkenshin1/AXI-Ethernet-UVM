`ifndef APB_MASTER_SEQ_LIB_SV
`define APB_MASTER_SEQ_LIB_SV

//typedef class apb_trans;
//typedef class apb_master_sequencer;

class apb_master_base_sequence extends uvm_sequence #(apb_trans);

  `uvm_object_utils(apb_master_base_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction

endclass: apb_master_base_sequence 


//APB写测试
class apb_master_single_write_sequence extends apb_master_base_sequence;
  rand bit [31:0]      addr;
  rand bit [31:0]      data;
  apb_trans_status     trans_status;

  `uvm_object_utils(apb_master_single_write_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction

  virtual task body();
    apb_trans req , rsp ;
    `uvm_info(get_type_name(),"Starting sequence", UVM_HIGH)
	  `uvm_do_with(req, {trans_kind == WRITE; addr == local::addr; data == local::data;})
    get_response(rsp);
    trans_status = rsp.trans_status;
    `uvm_info(get_type_name(),$psprintf("Done sequence: %s",req.convert2string()), UVM_HIGH)
  endtask

endclass: apb_master_single_write_sequence

class apb_master_single_read_sequence extends apb_master_base_sequence;
  rand bit [31:0]      addr;
  rand bit [31:0]      data;
  apb_trans_status     trans_status;

  `uvm_object_utils(apb_master_single_read_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(),"Starting sequence", UVM_HIGH)
	  `uvm_do_with(req, {trans_kind == READ; addr == local::addr;})
    get_response(rsp);
    trans_status = rsp.trans_status;
    data = rsp.data;
    `uvm_info(get_type_name(),$psprintf("Done sequence: %s",req.convert2string()), UVM_HIGH)
  endtask

endclass: apb_master_single_read_sequence

class apb_master_write_read_sequence extends apb_master_base_sequence;
  rand bit [31:0]    addr;
  rand bit [31:0]    data;
  rand int           idle_cycles; 
  apb_trans_status   trans_status;
  constraint cstr{
    idle_cycles == 0;
  }

  `uvm_object_utils(apb_master_write_read_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(),"Starting sequence", UVM_HIGH)
	  `uvm_do_with(req,  {trans_kind == WRITE; 
                        addr == local::addr; 
                        data == local::data;
                        idle_cycles == local::idle_cycles;
                       })
    get_response(rsp);
    `uvm_do_with(req, {trans_kind == READ; addr == local::addr;})
    get_response(rsp);
    data = rsp.data;
    trans_status = rsp.trans_status;
    `uvm_info(get_type_name(),$psprintf("Done sequence: %s",req.convert2string()), UVM_HIGH)
  endtask

endclass: apb_master_write_read_sequence
  
class apb_master_burst_write_sequence extends apb_master_base_sequence;
  rand bit [31:0]      addr;
  rand bit [31:0]      data[];
  apb_trans_status     trans_status;
  constraint cstr{
    soft data.size() inside {4, 8, 16, 32};
    foreach(data[i]) soft data[i] == addr + (i << 2);
  }

  `uvm_object_utils(apb_master_burst_write_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(),"Starting sequence", UVM_HIGH)
    trans_status = OK;
    foreach(data[i]) begin
	    `uvm_do_with(req, {trans_kind == WRITE; 
                         addr == local::addr + (i<<2); 
                         data == local::data[i];
                         idle_cycles == 0;
                        })
      get_response(rsp);
    end
    `uvm_do_with(req, {trans_kind == IDLE;})
    get_response(rsp);
    trans_status = rsp.trans_status == ERROR ? ERROR : trans_status;
    `uvm_info(get_type_name(),$psprintf("Done sequence: %s",req.convert2string()), UVM_HIGH)
  endtask
endclass: apb_master_burst_write_sequence

class apb_master_burst_read_sequence extends apb_master_base_sequence;
  rand bit [31:0]      addr;
  rand bit [31:0]      data[];
  apb_trans_status     trans_status;
  constraint cstr{
    soft data.size() inside {4, 8, 16, 32};
  }
  `uvm_object_utils(apb_master_burst_read_sequence)
  function new(string name=""); 
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(),"Starting sequence", UVM_HIGH)
    trans_status = OK;
    foreach(data[i]) begin
	    `uvm_do_with(req, {trans_kind == READ; 
                         addr == local::addr + (i<<2); 
                         idle_cycles == 0;
                        })
      get_response(rsp);
      data[i] = rsp.data;
    end
    `uvm_do_with(req, {trans_kind == IDLE;})
    get_response(rsp);
    trans_status = rsp.trans_status == ERROR ? ERROR : trans_status;
    `uvm_info(get_type_name(),$psprintf("Done sequence: %s",req.convert2string()), UVM_HIGH)
  endtask
endclass: apb_master_burst_read_sequence


`endif

