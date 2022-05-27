`ifndef ETH_SYS_REGMODEL_SV
`define ETH_SYS_REGMODEL_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
class local_mac0_reg extends uvm_reg;
  `uvm_object_utils(local_mac0_reg)
  rand uvm_reg_field src_mac0;
  covergroup value_cg;
    option.per_instance = 1;
    src_mac0: coverpoint src_mac0.value[31:0];
  endgroup
  function new(string name = "local_mac0_reg");
    super.new(name, 32, UVM_CVR_ALL);
    void'(set_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg = new();
    end
  endfunction
  virtual function void build();
    src_mac0 = uvm_reg_field::type_id::create("src_mac0");
    src_mac0.configure(this, 32, 0, "RW", 0, 'h0, 1, 0, 0);
  endfunction
  function void sample(
    uvm_reg_data_t data,
    uvm_reg_data_t byte_en,
    bit            is_read,
    uvm_reg_map    map
  );
    super.sample(data, byte_en, is_read, map);
    sample_values(); 
  endfunction
  function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg.sample();
    end
  endfunction
endclass

class local_mac1_reg extends uvm_reg;
  `uvm_object_utils(local_mac1_reg)
  rand uvm_reg_field src_mac1;
  rand uvm_reg_field reserved;
  covergroup value_cg;
    option.per_instance = 1;
    src_mac1: coverpoint src_mac1.value[15:0];
    reserved: coverpoint reserved.value[31:16];
  endgroup
  function new(string name = "local_mac1_reg");
    super.new(name, 32, UVM_CVR_ALL);
    void'(set_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg = new();
    end
  endfunction
  virtual function void build();
    src_mac1 = uvm_reg_field::type_id::create("src_mac1");
    reserved = uvm_reg_field::type_id::create("reserved");
    src_mac1.configure(this, 16, 0, "RW", 0, 'h0, 1, 0, 0);
    reserved.configure(this, 16, 16, "RO", 0, 'h0, 1, 0, 0);
  endfunction
  function void sample(
    uvm_reg_data_t data,
    uvm_reg_data_t byte_en,
    bit            is_read,
    uvm_reg_map    map
  );
    super.sample(data, byte_en, is_read, map);
    sample_values(); 
  endfunction
  function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg.sample();
    end
  endfunction
endclass

class local_ip_reg extends uvm_reg;
  `uvm_object_utils(local_ip_reg)
  rand uvm_reg_field src_ip;
  covergroup value_cg;
    option.per_instance = 1;
    src_ip: coverpoint src_ip.value[31:0];
  endgroup
  function new(string name = "local_ip_reg");
    super.new(name, 32, UVM_CVR_ALL);
    void'(set_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg = new();
    end
  endfunction
  virtual function void build();
    src_ip = uvm_reg_field::type_id::create("src_ip");
    src_ip.configure(this, 32, 0, "RW", 0, 'h0, 1, 0, 0);
  endfunction
  function void sample(
    uvm_reg_data_t data,
    uvm_reg_data_t byte_en,
    bit            is_read,
    uvm_reg_map    map
  );
    super.sample(data, byte_en, is_read, map);
    sample_values(); 
  endfunction
  function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg.sample();
    end
  endfunction
endclass

class gateway_ip_reg extends uvm_reg;
  `uvm_object_utils(gateway_ip_reg)
  rand uvm_reg_field dst_gateway;
  covergroup value_cg;
    option.per_instance = 1;
    dst_gateway: coverpoint dst_gateway.value[31:0];
  endgroup
  function new(string name = "gateway_ip_reg");
    super.new(name, 32, UVM_CVR_ALL);
    void'(set_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg = new();
    end
  endfunction
  virtual function void build();
    dst_gateway = uvm_reg_field::type_id::create("dst_gateway");
    dst_gateway.configure(this, 32, 0, "RW", 0, 'h0, 1, 0, 0);
  endfunction
  function void sample(
    uvm_reg_data_t data,
    uvm_reg_data_t byte_en,
    bit            is_read,
    uvm_reg_map    map
  );
    super.sample(data, byte_en, is_read, map);
    sample_values(); 
  endfunction
  function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg.sample();
    end
  endfunction
endclass

class subnet_mask_reg extends uvm_reg;
  `uvm_object_utils(subnet_mask_reg)
  rand uvm_reg_field dst_subnet;
  covergroup value_cg;
    option.per_instance = 1;
    dst_subnet: coverpoint dst_subnet.value[31:0];
  endgroup
  function new(string name = "subnet_mask_reg");
    super.new(name, 32, UVM_CVR_ALL);
    void'(set_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg = new();
    end
  endfunction
  virtual function void build();
    dst_subnet = uvm_reg_field::type_id::create("dst_subnet");
    dst_subnet.configure(this, 32, 0, "RW", 0, 'h0, 1, 0, 0);
  endfunction
  function void sample(
    uvm_reg_data_t data,
    uvm_reg_data_t byte_en,
    bit            is_read,
    uvm_reg_map    map
  );
    super.sample(data, byte_en, is_read, map);
    sample_values(); 
  endfunction
  function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg.sample();
    end
  endfunction
endclass

class tx_dst_ip_reg extends uvm_reg;
  `uvm_object_utils(tx_dst_ip_reg)
  rand uvm_reg_field dst_ip;
  covergroup value_cg;
    option.per_instance = 1;
    dst_ip: coverpoint dst_ip.value[31:0];
  endgroup
  function new(string name = "tx_dst_ip_reg");
    super.new(name, 32, UVM_CVR_ALL);
    void'(set_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg = new();
    end
  endfunction
  virtual function void build();
    dst_ip = uvm_reg_field::type_id::create("dst_ip");
    dst_ip.configure(this, 32, 0, "RW", 0, 'h0, 1, 0, 0);
  endfunction
  function void sample(
    uvm_reg_data_t data,
    uvm_reg_data_t byte_en,
    bit            is_read,
    uvm_reg_map    map
  );
    super.sample(data, byte_en, is_read, map);
    sample_values(); 
  endfunction
  function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg.sample();
    end
  endfunction
endclass

class tx_src_port_reg extends uvm_reg;
  `uvm_object_utils(tx_src_port_reg)
  rand uvm_reg_field src_port;
  rand uvm_reg_field reserved;
  covergroup value_cg;
    option.per_instance = 1;
    src_port: coverpoint src_port.value[15:0];
    reserved: coverpoint reserved.value[31:16];
  endgroup
  function new(string name = "tx_src_port_reg");
    super.new(name, 32, UVM_CVR_ALL);
    void'(set_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg = new();
    end
  endfunction
  virtual function void build();
    src_port = uvm_reg_field::type_id::create("src_port");
    reserved = uvm_reg_field::type_id::create("reserved");
    src_port.configure(this, 16, 0, "RW", 0, 'h0, 1, 0, 0);
    reserved.configure(this, 16, 16, "RO", 0, 'h0, 1, 0, 0);
  endfunction
  function void sample(
    uvm_reg_data_t data,
    uvm_reg_data_t byte_en,
    bit            is_read,
    uvm_reg_map    map
  );
    super.sample(data, byte_en, is_read, map);
    sample_values(); 
  endfunction
  function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg.sample();
    end
  endfunction
endclass

class tx_dst_port_reg extends uvm_reg;
  `uvm_object_utils(tx_dst_port_reg)
  rand uvm_reg_field dst_port;
  rand uvm_reg_field reserved;
  covergroup value_cg;
    option.per_instance = 1;
    dst_port: coverpoint dst_port.value[15:0];
    reserved: coverpoint reserved.value[31:16];
  endgroup
  function new(string name = "tx_dst_port_reg");
    super.new(name, 32, UVM_CVR_ALL);
    void'(set_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg = new();
    end
  endfunction
  virtual function void build();
    dst_port = uvm_reg_field::type_id::create("dst_port");
    reserved = uvm_reg_field::type_id::create("reserved");
    dst_port.configure(this, 16, 0, "RW", 0, 'h0, 1, 0, 0);
    reserved.configure(this, 16, 16, "RO", 0, 'h0, 1, 0, 0);
  endfunction
  function void sample(
    uvm_reg_data_t data,
    uvm_reg_data_t byte_en,
    bit            is_read,
    uvm_reg_map    map
  );
    super.sample(data, byte_en, is_read, map);
    sample_values(); 
  endfunction
  function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg.sample();
    end
  endfunction
endclass

class tx_udp_len_reg extends uvm_reg;
  `uvm_object_utils(tx_udp_len_reg)
  rand uvm_reg_field udp_len;
  rand uvm_reg_field reserved;
  covergroup value_cg;
    option.per_instance = 1;
    udp_len: coverpoint udp_len.value[15:0];
    reserved: coverpoint reserved.value[31:16];
  endgroup
  function new(string name = "tx_udp_len_reg");
    super.new(name, 32, UVM_CVR_ALL);
    void'(set_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg = new();
    end
  endfunction
  virtual function void build();
    udp_len = uvm_reg_field::type_id::create("udp_len");
    reserved = uvm_reg_field::type_id::create("reserved");
    udp_len.configure(this, 16, 0, "RW", 0, 'h0, 1, 0, 0);
    reserved.configure(this, 16, 16, "RO", 0, 'h0, 1, 0, 0);
  endfunction
  function void sample(
    uvm_reg_data_t data,
    uvm_reg_data_t byte_en,
    bit            is_read,
    uvm_reg_map    map
  );
    super.sample(data, byte_en, is_read, map);
    sample_values(); 
  endfunction
  function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg.sample();
    end
  endfunction
endclass

class rx_udp_len_reg extends uvm_reg;
  `uvm_object_utils(rx_udp_len_reg)
  rand uvm_reg_field udp_len;
  rand uvm_reg_field reserved;
  covergroup value_cg;
    option.per_instance = 1;
    udp_len: coverpoint udp_len.value[15:0];
    reserved: coverpoint reserved.value[31:16];
  endgroup
  function new(string name = "rx_udp_len_reg");
    super.new(name, 32, UVM_CVR_ALL);
    void'(set_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg = new();
    end
  endfunction
  virtual function void build();
    udp_len = uvm_reg_field::type_id::create("udp_len");
    reserved = uvm_reg_field::type_id::create("reserved");
    udp_len.configure(this, 16, 0, "RO", 0, 'h0, 1, 0, 0);
    reserved.configure(this, 16, 16, "RO", 0, 'h0, 1, 0, 0);
  endfunction
  function void sample(
    uvm_reg_data_t data,
    uvm_reg_data_t byte_en,
    bit            is_read,
    uvm_reg_map    map
  );
    super.sample(data, byte_en, is_read, map);
    sample_values(); 
  endfunction
  function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg.sample();
    end
  endfunction
endclass

class tx_ctr_reg extends uvm_reg;
  `uvm_object_utils(tx_ctr_reg)
  rand uvm_reg_field tx_en;
  rand uvm_reg_field reserved;
  covergroup value_cg;
    option.per_instance = 1;
    tx_en: coverpoint tx_en.value[0:0];
    reserved: coverpoint reserved.value[31:1];
  endgroup
  function new(string name = "tx_ctr_reg");
    super.new(name, 32, UVM_CVR_ALL);
    void'(set_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg = new();
    end
  endfunction
  virtual function void build();
    tx_en = uvm_reg_field::type_id::create("tx_en");
    reserved = uvm_reg_field::type_id::create("reserved");
    tx_en.configure(this, 1, 0, "RW", 0, 'h0, 1, 0, 0);
    reserved.configure(this, 31, 1, "RO", 0, 'h0, 1, 0, 0);
  endfunction
  function void sample(
    uvm_reg_data_t data,
    uvm_reg_data_t byte_en,
    bit            is_read,
    uvm_reg_map    map
  );
    super.sample(data, byte_en, is_read, map);
    sample_values(); 
  endfunction
  function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      value_cg.sample();
    end
  endfunction
endclass

class eth_sys_rgm extends uvm_reg_block;
  `uvm_object_utils(eth_sys_rgm)
  rand local_mac0_reg local_mac0;
  rand local_mac1_reg local_mac1;
  rand local_ip_reg local_ip;
  rand gateway_ip_reg gateway_ip;
  rand subnet_mask_reg subnet_mask;
  rand tx_dst_ip_reg tx_dst_ip;
  rand tx_src_port_reg tx_src_port;
  rand tx_dst_port_reg tx_dst_port;
  rand tx_udp_len_reg tx_udp_len;
  rand rx_udp_len_reg rx_udp_len;
  rand tx_ctr_reg tx_ctr;
  uvm_reg_map map;
  function new(string name = "eth_sys_rgm");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
  virtual function void build();
    local_mac0 = local_mac0_reg::type_id::create("local_mac0");
    local_mac0.configure(this);
    local_mac0.build();
    local_mac1 = local_mac1_reg::type_id::create("local_mac1");
    local_mac1.configure(this);
    local_mac1.build();
    local_ip = local_ip_reg::type_id::create("local_ip");
    local_ip.configure(this);
    local_ip.build();
    gateway_ip = gateway_ip_reg::type_id::create("gateway_ip");
    gateway_ip.configure(this);
    gateway_ip.build();
    subnet_mask = subnet_mask_reg::type_id::create("subnet_mask");
    subnet_mask.configure(this);
    subnet_mask.build();
    tx_dst_ip = tx_dst_ip_reg::type_id::create("tx_dst_ip");
    tx_dst_ip.configure(this);
    tx_dst_ip.build();
    tx_src_port = tx_src_port_reg::type_id::create("tx_src_port");
    tx_src_port.configure(this);
    tx_src_port.build();
    tx_dst_port = tx_dst_port_reg::type_id::create("tx_dst_port");
    tx_dst_port.configure(this);
    tx_dst_port.build();
    tx_udp_len = tx_udp_len_reg::type_id::create("tx_udp_len");
    tx_udp_len.configure(this);
    tx_udp_len.build();
    rx_udp_len = rx_udp_len_reg::type_id::create("rx_udp_len");
    rx_udp_len.configure(this);
    rx_udp_len.build();
    tx_ctr = tx_ctr_reg::type_id::create("tx_ctr");
    tx_ctr.configure(this);
    tx_ctr.build();
    map = create_map("map", 'h0, 4, UVM_LITTLE_ENDIAN);
    map.add_reg(local_mac0, 32'h00, "RW");
    map.add_reg(local_mac1, 32'h04, "RW");
    map.add_reg(local_ip, 32'h08, "RW");
    map.add_reg(gateway_ip, 32'h0c, "RW");
    map.add_reg(subnet_mask, 32'h10, "RW");
    map.add_reg(tx_dst_ip, 32'h14, "RW");
    map.add_reg(tx_src_port, 32'h18, "RW");
    map.add_reg(tx_dst_port, 32'h1c, "RW");
    map.add_reg(tx_udp_len, 32'h20, "RW");
    map.add_reg(rx_udp_len, 32'h24, "RO");
    map.add_reg(tx_ctr, 32'h28, "RW");
    local_mac0.add_hdl_path_slice("cfg_regs[0]", 0, 32);
    local_mac1.add_hdl_path_slice("cfg_regs[1]", 0, 32);
    local_ip.add_hdl_path_slice("cfg_regs[2]", 0, 32);
    gateway_ip.add_hdl_path_slice("cfg_regs[3]", 0, 32);
    subnet_mask.add_hdl_path_slice("cfg_regs[4]", 0, 32);
    tx_dst_ip.add_hdl_path_slice("cfg_regs[5]", 0, 32);
    tx_src_port.add_hdl_path_slice("cfg_regs[6]", 0, 32);
    tx_dst_port.add_hdl_path_slice("cfg_regs[7]", 0, 32);
    tx_udp_len.add_hdl_path_slice("cfg_regs[8]", 0, 32);
    rx_udp_len.add_hdl_path_slice("cfg_regs[9]", 0, 32);
    tx_ctr.add_hdl_path_slice("cfg_regs[10]", 0, 32);
    add_hdl_path("eth_tb_top.dut");
    lock_model();
  endfunction
endclass

`endif
