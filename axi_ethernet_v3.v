module axi_ethernet_v3 #(
  //AXI-4
  parameter AXI_DATA_WIDTH      = 256,
  parameter AXI_ADDR_WIDTH      = 32,
  parameter AXI_ID_WIDTH        = 6,
  parameter AXI_STRB_WIDTH      = AXI_DATA_WIDTH/8,
  parameter AXI_USER_WIDTH      = 1,
  //AXI-Stream
  parameter STR_DATA_WIDTH      = 8,
  parameter STR_KEEP_WIDTH      = STR_DATA_WIDTH/8,
  parameter STR_STRB_WIDTH      = STR_DATA_WIDTH/8,
  parameter STR_DEST_WIDTH      = 0,
  parameter STR_ID_WIDTH        = 1,
  //Buffer Size
  parameter WRITE_BUFFER_SIZE   = 4,  //KB
  parameter READ_BUFFER_SIZE    = 4   //KB
)
(
  //AXI-4 Slave Signals
  input wire                        aclk,
  input wire                        aresetn,

  input wire [AXI_ADDR_WIDTH-1:0]   aw_addr,
  input wire [2:0]                  aw_prot,
  input wire [3:0]                  aw_region,
  input wire [7:0]                  aw_len,
  input wire [2:0]                  aw_size,
  input wire [1:0]                  aw_burst,
  input wire                        aw_lock,
  input wire [3:0]                  aw_cache,
  input wire [3:0]                  aw_qos,
  input wire [AXI_ID_WIDTH-1:0]     aw_id,
  input wire [AXI_USER_WIDTH-1:0]   aw_user,
  output wire                       aw_ready,
  input wire                        aw_valid,

  input wire [AXI_ADDR_WIDTH-1:0]   ar_addr,
  input wire [2:0]                  ar_prot,
  input wire [3:0]                  ar_region,
  input wire [7:0]                  ar_len,
  input wire [2:0]                  ar_size,
  input wire [1:0]                  ar_burst,
  input wire                        ar_lock,
  input wire [3:0]                  ar_cache,
  input wire [3:0]                  ar_qos,
  input wire [AXI_ID_WIDTH-1:0]     ar_id,
  input wire [AXI_USER_WIDTH-1:0]   ar_user,
  output wire                       ar_ready,
  input wire                        ar_valid,

  input wire                        w_valid,
  input wire [AXI_DATA_WIDTH-1:0]   w_data,
  input wire [AXI_STRB_WIDTH-1:0]   w_strb,
  input wire [AXI_USER_WIDTH-1:0]   w_user,
  input wire                        w_last,
  output wire                       w_ready,

  output wire [AXI_DATA_WIDTH-1:0]  r_data,
  output wire [1:0]                 r_resp,
  output wire                       r_last,
  output wire [AXI_ID_WIDTH-1:0]    r_id,
  output wire [AXI_USER_WIDTH-1:0]  r_user,
  input wire                        r_ready,
  output wire                       r_valid,

  output wire [1:0]                 b_resp,
  output wire [AXI_ID_WIDTH-1:0]    b_id,
  output wire [AXI_USER_WIDTH-1:0]  b_user,
  input wire                        b_ready,
  output wire                       b_valid,

  input wire                        free_clk ,
  output wire                       phy_rst_n,
  input wire                        rx_clki,
  input wire                        phy_rx_dv,
  //input wire [3:0]                  phy_rxd,
  input wire                        phy_rxd0 ,
  input wire                        phy_rxd1 ,  
  input wire                        phy_rxd2 ,  
  input wire                        phy_rxd3 ,  
  output wire                       tx_clko,
  output wire                       phy_tx_en,
  //output wire [3:0]                 phy_txd,
  output wire                       phy_txd0 ,
  output wire                       phy_txd1 ,
  output wire                       phy_txd2 ,
  output wire                       phy_txd3 ,
  output wire                       led ,

  //APB Interface
  input wire                        pclk,
  input wire                        presetn,
  input wire  [31:0]                paddr,
  input wire                        pwrite,
  input wire                        psel,
  input wire                        penable,
  input wire  [31:0]                pwdata,
  output reg  [31:0]                prdata,
  output wire                       pready,
  output wire                       pslverr ,

  output wire                       irq                         
);

  //AXI4 signals
  reg [AXI_ADDR_WIDTH-1:0] sig_aw_addr;
  reg                      sig_aw_ready;
  reg [1:0]                sig_aw_burst;
  reg [7:0]                sig_aw_len;
  reg                      sig_w_ready;
  reg [1:0]                sig_b_resp;
  reg [AXI_USER_WIDTH-1:0] sig_b_user;
  reg                      sig_b_valid;
  reg [AXI_ADDR_WIDTH-1:0] sig_ar_addr;
  reg                      sig_ar_ready;
  reg [1:0]                sig_ar_burst;
  reg [7:0]                sig_ar_len;
  reg [AXI_DATA_WIDTH-1:0] sig_r_data;
  reg [1:0]                sig_r_resp;
  reg                      sig_r_last;
  reg [AXI_USER_WIDTH-1:0] sig_r_user;
  reg                      sig_r_valid;    
  //added
  reg [AXI_ID_WIDTH-1:0]   sig_b_id;
  reg [AXI_ID_WIDTH-1:0]   sig_r_id;   
  
  wire aw_wrap_en, ar_wrap_en;  //determines wrap boundary and enables wrapping
  wire [31:0] aw_wrap_size, ar_wrap_size; //the size of write/read transfer
  reg axi_awv_awr_flag, axi_arv_arr_flag; //marks the presence of write/read address valid
  reg [7:0] aw_len_cntr, ar_len_cntr; //to keep track of beats in a burst transaction

  //register addressing
  parameter LOCAL_MAC0    = 4'h0,
            LOCAL_MAC1    = 4'h1,
            LOCAL_IP      = 4'h2,
            GATEWAY_IP    = 4'h3,
            SUBNET_MASK   = 4'h4,
            TX_DST_IP     = 4'h5,
            TX_SRC_PORT   = 4'h6,
            TX_DST_PORT   = 4'h7,
            TX_UDP_LENGTH = 4'h8,
            RX_UDP_LENGTH = 4'h9,
            TX_CTR        = 4'ha;   //TX_CTR[3]:AXI transfer start; TX_CTR[0]:header data handshake

  // I/O Connections assignments
  assign aw_ready = sig_aw_ready;
  assign w_ready  = sig_w_ready;
  assign b_resp   = sig_b_resp;
  assign b_user   = sig_b_user;
  assign b_valid  = sig_b_valid;
  assign ar_ready = sig_ar_ready;
  //assign r_data   = sig_r_data;
  assign r_resp   = sig_r_resp;
  assign r_last   = sig_r_last;
  assign r_user   = sig_r_user;
  assign r_valid  = sig_r_valid;
  //assign b_id     = aw_id;
  //assign r_id     = ar_id;
  assign b_id     = sig_b_id;
  assign r_id     = sig_r_id;
  //could be optimized
  assign aw_wrap_size = (AXI_DATA_WIDTH/8 * (aw_len));
  assign ar_wrap_size = (AXI_DATA_WIDTH/8 * (ar_len));
  assign aw_wrap_en   = ((sig_aw_addr & aw_wrap_size) == aw_wrap_size) ? 1'b1 : 1'b0;
  assign ar_wrap_en   = ((sig_ar_addr & ar_wrap_size) == ar_wrap_size) ? 1'b1 : 1'b0;

  //function for calculating log2
  function integer clogb2 (input integer depth);
    begin
      for (clogb2=0; depth>0; clogb2=clogb2+1) 
          depth = depth >>1;                          
    end
  endfunction

  localparam integer ADDR_LSB = clogb2(AXI_DATA_WIDTH/8-1);
  //localparam integer AXI_WR_ADDR_BITS = clogb2(WRITE_BUFFER_SIZE-1) + 8;
  //localparam integer AXI_RD_ADDR_BITS = clogb2(READ_BUFFER_SIZE-1) + 8;
  localparam integer AXI_WR_ADDR_BITS = 16;
  localparam integer AXI_RD_ADDR_BITS = 16;

  //Implement aw_ready generation
  //aw_ready is asserted for one aclk clock cycle when both
  //aw_valid and w_valid are asserted.
  //aw_ready is de-asserted when reset is low.

  always @ (posedge aclk) begin
    if (aresetn == 1'b0) begin
      //added
      sig_b_id <= 0;
      sig_aw_ready <= 1'b0;
      axi_awv_awr_flag <= 1'b0;
    end else begin
      if (~sig_aw_ready && aw_valid && ~axi_awv_awr_flag && ~axi_arv_arr_flag) begin
        sig_aw_ready <= 1'b1;
        //added
        sig_b_id <= aw_id;
        axi_awv_awr_flag <= 1'b1;
      end else if (w_last && sig_w_ready) begin
        axi_awv_awr_flag <= 1'b0;
      end else begin
        sig_aw_ready <= 1'b0;
      end
    end
  end

  //Implement aw_addr latching
  //This process is used to latch the address when both
  //aw_valid and  w_valid are valid.

  always @ (posedge aclk) begin
    if (aresetn == 1'b0) begin
      sig_aw_addr <= 0;
      aw_len_cntr <= 0;
      sig_aw_burst <= 0;
      sig_aw_len <= 0;
    end else begin
      if (~sig_aw_ready && aw_valid && ~axi_awv_awr_flag) begin
        sig_aw_addr <= aw_addr[AXI_ADDR_WIDTH-1:0];
        sig_aw_burst <= aw_burst;
        sig_aw_len <= aw_len;
        aw_len_cntr <= 0;
      end else if ((aw_len_cntr <= sig_aw_len) && sig_w_ready && w_valid) begin
        aw_len_cntr <= aw_len_cntr + 1;
        case (sig_aw_burst)
          2'b00:  //fixed burst
            begin
              sig_aw_addr <= sig_aw_addr;
            end
          2'b01:  //incremental burst
            begin
              sig_aw_addr[AXI_ADDR_WIDTH-1:ADDR_LSB] <= sig_aw_addr[AXI_ADDR_WIDTH-1:ADDR_LSB] + 1;
              sig_aw_addr[ADDR_LSB-1:0] <= {ADDR_LSB{1'b0}};
            end
          2'b10:  //wrapping burst
            begin
              if (aw_wrap_en) begin
                sig_aw_addr <= (sig_aw_addr - aw_wrap_size);
              end else begin
                sig_aw_addr[AXI_ADDR_WIDTH-1:ADDR_LSB] <= sig_aw_addr[AXI_ADDR_WIDTH-1:ADDR_LSB] + 1;
                sig_aw_addr[ADDR_LSB-1:0] <= {ADDR_LSB{1'b0}};
              end
            end
          default:  //reserved
           begin
             sig_aw_addr <= sig_aw_addr[AXI_ADDR_WIDTH-1:ADDR_LSB] + 1;
           end
        endcase
      end
    end
  end

  //Implement w_ready generation
  //w_ready is asserted for one aclk clock cycle when both
  //aw_valid and w_valid are asserted.
  //w_ready is de-asserted when reset is low.

  always @ (posedge aclk) begin
    if (aresetn == 1'b0) begin
      sig_w_ready <= 1'b0;
    end else begin
      if (~sig_w_ready && w_valid && axi_awv_awr_flag) begin
        sig_w_ready <= 1'b1;
      end else if (w_last && sig_w_ready) begin
        sig_w_ready <= 1'b0;
      end
    end
  end 

  //Implement write response logic generation
  //The write response and response valid signals are
  //asserted by the slave.

  always @ (posedge aclk) begin
    if (aresetn == 1'b0) begin
      sig_b_valid <= 0;
      sig_b_resp <= 2'b0;
      sig_b_user <= 0;
    end else begin
      if (axi_awv_awr_flag && sig_w_ready && w_valid && ~sig_b_valid && w_last) begin
        sig_b_valid <= 1'b1;
        sig_b_resp <= 2'b0;
      end else begin
        if(b_ready && sig_b_valid) begin
          sig_b_valid <= 1'b0;
        end
      end
    end
  end

  //Implement ar_ready generation
  //ar_ready is asserted for one aclk clock cycle when
  //ar_valid is asserted.
  //The read address is also latched when ar_valid is 
  //asserted. ar_addr is reset to zero on reset assertion.

  always @ (posedge aclk) begin
    if (aresetn == 1'b0) begin
      sig_ar_ready <= 1'b0;
      axi_arv_arr_flag <= 1'b0;
      //added
      sig_r_id <= 0;
    end else begin
      if (~sig_ar_ready && ar_valid && ~axi_awv_awr_flag && ~axi_arv_arr_flag) begin
        //added
        sig_r_id <= ar_id;
        sig_ar_ready <= 1'b1;
        axi_arv_arr_flag <= 1'b1;
      end else if (sig_r_valid && r_ready && ar_len_cntr == sig_ar_len) begin
        axi_arv_arr_flag <= 1'b0;
      end else begin
        sig_ar_ready <= 1'b0;
      end
    end
  end

  //Implement ar_addr latching
  //This process is used to latch the address when both
  //ar_vaild and r_valid are valid.

  always @ (posedge aclk) begin
    if (aresetn == 1'b0) begin
      sig_ar_addr <= 0;
      ar_len_cntr <= 0;
      sig_ar_burst <= 0;
      sig_ar_len <= 0;
      sig_r_last <= 1'b0;
      sig_r_user <= 0;
    end else begin
      if (~sig_ar_ready && ar_valid && ~axi_arv_arr_flag) begin
        sig_ar_addr <= ar_addr[AXI_ADDR_WIDTH-1:0];
        sig_ar_burst <= ar_burst;
        sig_ar_len <= ar_len;
        ar_len_cntr <= 0;
        sig_r_last <= 1'b0;
        sig_r_user <= 0;
      end else begin
        if (sig_ar_ready && ar_valid && ~axi_arv_arr_flag) begin
          sig_ar_addr <= ar_addr[AXI_ADDR_WIDTH-1:0];
          sig_ar_burst <= ar_burst;
          sig_ar_len <= ar_len;
          ar_len_cntr <= 0;
          sig_r_last <= 1'b0;
        end else if ((ar_len_cntr <= sig_ar_len) && sig_r_valid && r_ready) begin
          ar_len_cntr <= ar_len_cntr + 1;
          sig_r_last <= 1'b0;
          case (sig_ar_burst)
            2'b00:  //fixed burst
             begin
               sig_ar_addr <= sig_ar_addr;
             end
            2'b01:  //incremental burst
              begin
                sig_ar_addr[AXI_ADDR_WIDTH-1:ADDR_LSB] <= sig_ar_addr[AXI_ADDR_WIDTH-1:ADDR_LSB] + 1;
                sig_ar_addr[ADDR_LSB-1:0] <= {ADDR_LSB{1'b0}};
              end
            2'b01:  //Wrapping burst
              begin
                if (ar_wrap_en) begin
                  sig_ar_addr <= (sig_ar_addr - ar_wrap_size);
                end else begin
                  sig_ar_addr[AXI_ADDR_WIDTH-1:ADDR_LSB] <= sig_ar_addr[AXI_ADDR_WIDTH-1:ADDR_LSB] + 1;
                  sig_ar_addr[ADDR_LSB-1:0] <= {ADDR_LSB{1'b0}};
                end
              end
            default:  //reserved
              begin
                sig_ar_addr <= sig_ar_addr[AXI_ADDR_WIDTH-1:ADDR_LSB] + 1;
              end
          endcase
        end else if ((ar_len_cntr == sig_ar_len) && ~sig_r_last && axi_arv_arr_flag) begin
          sig_r_last <= 1'b1;
        end else if (r_ready) begin
          sig_r_last <= 1'b0;
        end
      end
    end
  end

  //Implement r_valid generation
  //r_valid is asserted for one aclk clock cycle when both
  //ar_valid and ar_ready are asserted.

  always @ (posedge aclk) begin
    if (aresetn == 1'b0) begin
      sig_r_valid <= 0;
      sig_r_resp <= 0;
    end else begin
      if (axi_arv_arr_flag && ~sig_r_valid) begin
        sig_r_valid <= 1'b1;
        sig_r_resp <= 2'b0;
      end else if (sig_r_valid && r_ready) begin
        sig_r_valid <= 1'b0;
      end
    end
  end

  /************************************************************/
  /*********************SOME GLOBAL SIGNALS********************/
  /************************************************************/
  wire phy_clk, phy_rst;

  /************************************************************/
  /**************CONFIG SIDE REGISTERS AND LOGIC***************/
  /************************************************************/
  reg  [31:0]               cfg_regs[10:0];

  wire                      r_reg_mem_sel;
  wire                      w_reg_mem_sel; //signals to divide regs and mem region
  wire [3:0]                eth_reg_addr;
  reg  [AXI_DATA_WIDTH-1:0] reg_r_data;
  wire [AXI_DATA_WIDTH-1:0] mem_r_data;

	wire                      tx_cfg_hdr_valid;
	wire                      tx_cfg_hdr_ready;
	reg                       rx_cfg_hdr_valid;
	wire                      rx_cfg_hdr_ready;

  wire [15:0]               rx_cfg_length, rx_udp_length;

  //irq gen
  wire irq_n;

  assign rx_cfg_hdr_ready = 1'b1;

  assign w_reg_mem_sel  = sig_aw_addr[13];
  assign r_reg_mem_sel  = sig_ar_addr[13];
  assign eth_reg_addr   = paddr[5:2];

  //register writing logic
  always @ (posedge pclk) begin
    if (~presetn) begin
      cfg_regs[TX_CTR] <= 0;
    end else begin
      if (penable && pwrite && psel)
        cfg_regs[eth_reg_addr] <= pwdata;
      if (tx_cfg_hdr_ready & tx_cfg_hdr_valid)
        cfg_regs[TX_CTR][0] <= 1'b0;
      if (rx_cfg_hdr_ready & rx_cfg_hdr_valid)
        cfg_regs[RX_UDP_LENGTH] <= {16'h0, rx_cfg_length-16'd8};
    end
  end

  //register reading logic
  always @ (*) begin
    if (penable && ~pwrite && psel)
      prdata <= cfg_regs[eth_reg_addr];
  end

  assign pslverr = 0 ;  //no error

  //irq_gen_logic
  assign irq = ~irq_n;

  assign pready = penable & psel;

  assign tx_cfg_hdr_valid = cfg_regs[TX_CTR][0];
  assign tx_cfg_hdr_ready = 1;

  /************************************************************/
  /*************ETHERNET SIDE REGISTERS AND LOGIC**************/
  /************************************************************/
  wire [31:0] local_mac0, local_mac1, local_ip, gateway_ip, subnet_mask, tx_dst_ip, tx_src_port, tx_dst_port, tx_udp_length;

  reg                       tx_udp_hdr_valid;
	wire                      tx_udp_hdr_ready;
  wire                      rx_udp_hdr_valid;
	wire                      rx_udp_hdr_ready;

  wire [7:0]                tx_udp_payload_axis_tdata;
	reg                       tx_udp_payload_axis_tvalid;
	wire                      tx_udp_payload_axis_tready;
	wire                      tx_udp_payload_axis_tlast;
	wire                      tx_udp_payload_axis_tuser;
  wire [7:0]                rx_udp_payload_axis_tdata;
	wire                      rx_udp_payload_axis_tvalid;
	wire                      rx_udp_payload_axis_tready;
	wire                      rx_udp_payload_axis_tlast;
	wire                      rx_udp_payload_axis_tuser;

  reg  [15:0]               tx_count, rx_count; 
  wire [15:0]               tx_addr,  rx_addr;

  assign rx_udp_hdr_ready           = 1'b1;
  assign rx_udp_payload_axis_tready = 1'b1;

  //---------AXIS----------
  //TX counting
  always @ (posedge phy_clk) begin
    if (phy_rst)
      tx_count <= 1;
    else if (tx_udp_payload_axis_tlast)
      tx_count <= 1;
    else if (tx_udp_payload_axis_tvalid & tx_udp_payload_axis_tready)
      tx_count <= tx_count + 1;
  end

  //TX addr gen
  assign tx_addr = (tx_udp_payload_axis_tvalid & tx_udp_payload_axis_tready) ? tx_count : 0;

  //TX tvalid generation
  always @ (posedge phy_clk) begin
    if (phy_rst)
      tx_udp_payload_axis_tvalid <= 0;
    else if (tx_udp_payload_axis_tlast)
      tx_udp_payload_axis_tvalid <= 0;
    else if (tx_udp_hdr_valid & tx_udp_hdr_ready)
      tx_udp_payload_axis_tvalid <= 1;
  end

  //TX tlast generation
  assign tx_udp_payload_axis_tlast = (tx_count == cfg_regs[8][15:0]/*tx_udp_length*/ & tx_udp_payload_axis_tvalid);
  /*
  always @ (posedge phy_clk) begin
    if (phy_rst)
      tx_udp_payload_axis_tlast <= 0;
    else if (tx_count == tx_udp_length & tx_udp_payload_axis_tvalid)
      tx_udp_payload_axis_tlast <= 1;
    else
      tx_udp_payload_axis_tlast <= 0;
  end
  */

  //RX counting
  always @ (posedge phy_clk) begin
    if (phy_rst)
      rx_count <= 0;
    else if (rx_udp_payload_axis_tvalid & rx_udp_payload_axis_tready & rx_udp_payload_axis_tlast)
      rx_count <= 0;
    else if (rx_udp_payload_axis_tvalid & rx_udp_payload_axis_tready)
      rx_count <= rx_count + 1;
  end

  /************************************************************/
  /***************FIFOS BETWEEN TWO CLOCK REGION***************/
  /************************************************************/
  wire [287:0] cfg_tx_sig, udp_tx_sig;
  assign cfg_tx_sig = {cfg_regs[8], cfg_regs[7], cfg_regs[6], cfg_regs[5], cfg_regs[4], cfg_regs[3], cfg_regs[2], cfg_regs[1], cfg_regs[0]};
  assign {tx_udp_length, tx_dst_port, tx_src_port, tx_dst_ip, subnet_mask, gateway_ip, local_ip, local_mac1, local_mac0} = udp_tx_sig;

  wire        cfg2udp_rd_empty, udp2cfg_rd_empty;
  
  //HDR
  always @ (posedge phy_clk) begin
    if (phy_rst) begin
      tx_udp_hdr_valid <= 0;
    end else begin
      tx_udp_hdr_valid <= ~cfg2udp_rd_empty;
    end
  end

  always @ (posedge aclk) begin
    if (~aresetn) begin
      rx_cfg_hdr_valid <= 0;
    end else begin
      rx_cfg_hdr_valid <= ~udp2cfg_rd_empty;
    end
  end

  async_hsk_fifo_pango_288 cfg2udp_fifo(
    .wr_clk       (pclk),
    .wr_rst       (~presetn),
    .wr_en        (tx_cfg_hdr_valid),
    .wr_data      (cfg_tx_sig),
    .wr_full      (),
    .almost_full  (),
    .rd_clk       (phy_clk),
    .rd_rst       (phy_rst),
    .rd_en        (tx_udp_hdr_ready & ~cfg2udp_rd_empty),
    .rd_data      (udp_tx_sig),
    .rd_empty     (cfg2udp_rd_empty),
    .almost_empty ()
  );

  async_hsk_fifo_pango_16 udp2cfg_fifo(
    .wr_clk       (phy_clk),
    .wr_rst       (phy_rst),
    .wr_en        (rx_udp_hdr_valid),
    .wr_data      (rx_udp_length),
    .wr_full      (),
    .almost_full  (),
    .rd_clk       (pclk),
    .rd_rst       (~presetn),
    .rd_en        (rx_cfg_hdr_ready & ~udp2cfg_rd_empty),
    .rd_data      (rx_cfg_length),
    .rd_empty     (udp2cfg_rd_empty),
    .almost_empty ()
  );

  async_hsk_fifo_pango_8 irq_fifo(
    .wr_clk       (phy_clk),
    .wr_rst       (phy_rst),
    .wr_en        (rx_udp_payload_axis_tlast),
    .wr_data      (8'hff),
    .wr_full      (),
    .almost_full  (),
    .rd_clk       (pclk),
    .rd_rst       (~presetn),
    .rd_en        (~irq_n),
    .rd_data      (),
    .rd_empty     (irq_n),
    .almost_empty ()
  );

  /************************************************************/
  /************************UDP TOP INST************************/
  /************************************************************/

	alex_top_udp udp_instance(
		.phy_rst_n					(phy_rst_n),
		.rx_clki						(rx_clki),
		.phy_rx_dv					(phy_rx_dv),
		.phy_rxd0						(phy_rxd0),
		.phy_rxd1						(phy_rxd1),
		.phy_rxd2						(phy_rxd2),
		.phy_rxd3						(phy_rxd3),

		.l0_sgmii_clk_shft	(tx_clko),
		.phy_tx_en					(phy_tx_en),
		.phy_txd0						(phy_txd0),
		.phy_txd1						(phy_txd1),
		.phy_txd2						(phy_txd2),
		.phy_txd3						(phy_txd3),

		//.free_clk					  (aclk),
    .free_clk					  (free_clk),
		.external_rstn			(aresetn),
		
		.tx_udp_payload_axis_tvalid		(tx_udp_payload_axis_tvalid),
		.tx_udp_payload_axis_tready		(tx_udp_payload_axis_tready),
		.tx_udp_payload_axis_tdata		(tx_udp_payload_axis_tdata),
		.tx_udp_payload_axis_tlast		(tx_udp_payload_axis_tlast),

		.rx_udp_payload_axis_tvalid		(rx_udp_payload_axis_tvalid),
		.rx_udp_payload_axis_tready		(rx_udp_payload_axis_tready),
		.rx_udp_payload_axis_tdata		(rx_udp_payload_axis_tdata),
		.rx_udp_payload_axis_tlast		(rx_udp_payload_axis_tlast),

		//.local_mac										({local_mac1[15:0], local_mac0}),
    .local_mac										({cfg_regs[1][15:0], cfg_regs[0]}),
		//.local_ip											(local_ip),
    .local_ip											(cfg_regs[2]),
		//.gateway_ip										(gateway_ip),
    .gateway_ip										(cfg_regs[3]),
		//.subnet_mask									(subnet_mask),
    .subnet_mask									(cfg_regs[4]),
		
		.tx_udp_ip_dscp								(0),
		.tx_udp_ip_ecn								(0),
		.tx_udp_ip_ttl								(8'd64),
		
		//.tx_udp_ip_source_ip					(local_ip),
    .tx_udp_ip_source_ip					(cfg_regs[2]),
		//.tx_udp_ip_dest_ip						(tx_dst_ip),
    .tx_udp_ip_dest_ip						(cfg_regs[5]),
		//.tx_udp_source_port						(tx_src_port[15:0]),
    .tx_udp_source_port						(cfg_regs[6][15:0]),
		//.tx_udp_dest_port							(tx_dst_port[15:0]),
    .tx_udp_dest_port							(cfg_regs[7][15:0]),
		//.tx_udp_length								(tx_udp_length[15:0]),
    .tx_udp_length								(cfg_regs[8][15:0]),
		.tx_udp_checksum							(0),
    .rx_udp_length                (rx_udp_length),

		.tx_udp_hdr_valid							(tx_udp_hdr_valid),
		.tx_udp_hdr_ready							(tx_udp_hdr_ready),
		.rx_udp_hdr_valid							(rx_udp_hdr_valid),
		.rx_udp_hdr_ready							(rx_udp_hdr_ready),

		.phy_rst											(phy_rst),
		.phy_clk											(phy_clk)
	);

  assign led = (rx_udp_payload_axis_tlast) ? ^rx_udp_payload_axis_tdata : rx_udp_payload_axis_tvalid;
  //assign led = (r_last) ? ^r_data : sig_r_valid;

  //rdata muxing
  assign r_data = r_reg_mem_sel ? reg_r_data : mem_r_data;

  //W/R Buffer Interface Signals
  wire [AXI_WR_ADDR_BITS-1:0] axi_mem_wraddr;
  wire [AXI_RD_ADDR_BITS-1:0] axi_mem_rdaddr;
  wire                        axi_mem_rden;
  wire                        axi_mem_wren;   

  //Buffer Interface Singals Generation
  assign axi_mem_wraddr = sig_aw_addr[AXI_WR_ADDR_BITS+ADDR_LSB-1:ADDR_LSB];
  assign axi_mem_rdaddr = sig_ar_addr[AXI_RD_ADDR_BITS+ADDR_LSB-1:ADDR_LSB];
  assign axi_mem_wren   = sig_w_ready && w_valid;
  assign axi_mem_rden   = axi_arv_arr_flag;

  Dual_Port_Ram_256_8 write_buffer(
    .wr_data(w_data),
    .wr_addr(axi_mem_wraddr),
    //.wr_en(0),
    .wr_en(axi_mem_wren & ~w_reg_mem_sel),
    .wr_clk(aclk),
    .wr_rst(~aresetn),
    .rd_addr({4'h0,tx_addr}),
    .rd_data(tx_udp_payload_axis_tdata),
    .rd_clk(phy_clk),
    .rd_rst(phy_rst)
  );

  Dual_Port_Ram_8_256 read_buffer(
    .wr_data(rx_udp_payload_axis_tdata),
    .wr_addr({3'b0,rx_count}),
    //.wr_en(0),
    .wr_en(rx_udp_payload_axis_tvalid & rx_udp_payload_axis_tready),
    .wr_clk(phy_clk),
    .wr_rst(phy_rst),
    .rd_addr(axi_mem_rdaddr),
    .rd_data(mem_r_data),
    .rd_clk(aclk),
    .rd_rst(~aresetn)
  );

endmodule