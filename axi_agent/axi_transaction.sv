`ifndef AXI_TRANS_SV
`define AXI_TRANS_SV

class axi_trans extends uvm_sequence_item ;

  rand axi_addr_type addr ;
	rand axi_data_type data[] ;
	rand axi_cmd                trans_kind ;        //传输类型
	rand axi_burst_type_enum    trans_burst_type ;  //burst类型
  rand axi_byte_size_enum     trans_byte_size  ;  //一次传输字节数，在没有narrow transfer的情况下匹配axi data width
  rand axi_burst_length_enum  trans_burst_len  ;  //burst数量
  rand axi_response_enum      trans_resp_type  ;  
  rand int  addr_data_delay ;   //write:awvalid->wvalid delay read:arvalid->ready delay
  rand int  data_resp_delay ;   //bvalid->bready delay
  rand int  trans_end_delay ;

  constraint data_cstr{
    soft data.size == 1 ;
    //foreach(data[i]) soft data[i]==256'h0011_2233_4455_6677_8899_aabb_ccdd_eeff_ffee_ddcc_bbaa_9988_7766_5544_3322_1100 + i ;
  };

  constraint delay_cstr{
    soft addr_data_delay == 1 ;
    soft data_resp_delay == 1 ;
    soft trans_end_delay == 1 ;
  };


  `uvm_object_utils_begin(axi_trans)
    `uvm_field_int        (addr, UVM_ALL_ON)
    `uvm_field_array_int  (data, UVM_ALL_ON)
    `uvm_field_enum       (axi_cmd, trans_kind, UVM_ALL_ON)
    `uvm_field_enum       (axi_burst_type_enum, trans_burst_type, UVM_ALL_ON)
    `uvm_field_enum       (axi_byte_size_enum, trans_byte_size, UVM_ALL_ON)
    `uvm_field_enum       (axi_burst_length_enum, trans_burst_len, UVM_ALL_ON)
    `uvm_field_int        (addr_data_delay, UVM_ALL_ON)
    `uvm_field_int        (data_resp_delay, UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name = "axi_transaction_inst") ;
    super.new(name) ;
  endfunction

  function void set_data_size() ;
    int t = get_burst_len(this.trans_burst_len) ;
    if(this.data.size()!= t+1) this.data = new[t+1] ;
  endfunction

endclass: axi_trans


function void get_axi_write_vec(input axi_trans t, output axi_aw_vec aw_vec, output axi_w_vec w_vec) ;
  axi_aw_vec s ;
  axi_w_vec v ;
  //AW Vector
  s.aw_addr   =  t.addr ;
  s.aw_prot   =  'b0 ;
  s.aw_region =  'b0 ;
  s.aw_len    =  get_burst_len(t.trans_burst_len) ;
  s.aw_size   =  get_byte_size(t.trans_byte_size) ;
  s.aw_burst  =  get_burst_type(t.trans_burst_type) ;
  s.aw_lock   =  'b0 ;
  s.aw_cache  =  'b0 ;
  s.aw_qos    =  'b0 ;
  s.aw_id     =  'b0 ;
  s.aw_user   =  'b0 ;
  s.aw_valid  =  'b1 ;

  //W Vector
  v.w_valid   =  'b1 ;
  v.w_strb    =  'b0 ;
  v.w_user    =  'b0 ;
  v.w_last    =  'b1 ;

  aw_vec = s ;
  w_vec  = v ;
endfunction

function void get_axi_read_vec(input axi_trans t, output axi_ar_vec ar_vec) ;
  //AR Vector
  axi_ar_vec s ;
  s.ar_addr   =  t.addr ;
  s.ar_prot   =  'b0 ;
  s.ar_region =  'b0 ;
  s.ar_len    =  get_burst_len(t.trans_burst_len) ;
  s.ar_size   =  get_byte_size(t.trans_byte_size) ;
  s.ar_burst  =  get_burst_type(t.trans_burst_type) ;
  s.ar_lock   =  'b0 ;
  s.ar_cache  =  'b0 ;
  s.ar_qos    =  'b0 ;
  s.ar_id     =  'b0 ;
  s.ar_user   =  'b0 ;
  s.ar_valid  =  'b1 ;

  ar_vec = s ;
endfunction

function void get_clear_axi_write_vec(output axi_aw_vec aw_vec, output axi_w_vec w_vec) ;
  axi_aw_vec s ;
  axi_w_vec v ;

  //AW Vector
  s.aw_addr   =  'b0 ;
  s.aw_prot   =  'b0 ;
  s.aw_region =  'b0 ;
  s.aw_len    =  'b0 ;
  s.aw_size   =  'b0 ;
  s.aw_burst  =  'b0 ;
  s.aw_lock   =  'b0 ;
  s.aw_cache  =  'b0 ;
  s.aw_qos    =  'b0 ;
  s.aw_id     =  'b0 ;
  s.aw_user   =  'b0 ;
  s.aw_valid  =  'b0 ;

  //W Vector
  v.w_valid   =  'b0 ;
  v.w_strb    =  'b0 ;
  v.w_user    =  'b0 ;
  v.w_last    =  'b0 ;

  aw_vec = s ;
  w_vec  = v ;
endfunction

function void get_clear_axi_read_vec(output axi_ar_vec ar_vec) ;
  //AR Vector
  axi_ar_vec s ;
  s.ar_addr   =  'b0 ;
  s.ar_prot   =  'b0 ;
  s.ar_region =  'b0 ;
  s.ar_len    =  'b0 ;
  s.ar_size   =  'b0 ;
  s.ar_burst  =  'b0 ;
  s.ar_lock   =  'b0 ;
  s.ar_cache  =  'b0 ;
  s.ar_qos    =  'b0 ;
  s.ar_id     =  'b0 ;
  s.ar_user   =  'b0 ;
  s.ar_valid  =  'b0 ;

  ar_vec = s ;
endfunction

`endif