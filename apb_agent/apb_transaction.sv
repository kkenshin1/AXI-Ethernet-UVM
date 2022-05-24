`ifndef APB_TRANS_SV
`define APB_TRANS_SV

typedef enum {IDLE, WRITE, READ} apb_trans_kind ;
typedef enum {OK, ERROR} apb_trans_status ;

class apb_trans extends uvm_sequence_item ;

  rand bit [31:0]       addr;
  rand bit [31:0]       data;
  rand apb_trans_kind   trans_kind; 
  rand apb_trans_status trans_status;
  rand int idle_cycles;

  constraint cstr{
    soft idle_cycles == 1;
  };

  `uvm_object_utils_begin(apb_trans)
    `uvm_field_enum     (apb_trans_kind, trans_kind, UVM_ALL_ON)
    `uvm_field_int      (addr, UVM_ALL_ON)
    `uvm_field_int      (data, UVM_ALL_ON)
    `uvm_field_int      (idle_cycles, UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name = "apb_transaction_inst");
    super.new(name);
  endfunction


endclass: apb_trans

`endif

