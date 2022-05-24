`ifndef APB_REG_ADAPTER_SV
`define APB_REG_ADAPTER_SV

class apb_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(apb_reg_adapter)

  function new(string name = "apb_reg_adapter");
    super.new(name);
    provides_responses = 1;
  endfunction

  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_trans t = apb_trans::type_id::create("t");
    t.trans_kind = (rw.kind == UVM_WRITE) ? WRITE : READ;
    t.addr = rw.addr;
    t.data = rw.data;
    t.idle_cycles = 1;
    return t;
  endfunction

  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    apb_trans t;
    if (!$cast(t, bus_item)) begin
      `uvm_fatal("CASTFAIL","Provided bus_item is not of the correct type")
      return;
    end
    rw.kind = (t.trans_kind == WRITE) ? UVM_WRITE : UVM_READ;
    rw.addr = t.addr;
    rw.data = t.data;
    rw.status = t.trans_status == OK ? UVM_IS_OK : UVM_NOT_OK;
  endfunction

endclass

`endif
