`ifndef AXI_TYPES_SV
`define AXI_TYPES_SV


typedef bit[`AXI_ADDR_WIDTH-1:0] axi_addr_type ;
typedef bit[`AXI_DATA_WIDTH-1:0] axi_data_type ;

//AXI枚举类型
typedef enum bit 
{
  WRITE = 0 , 
  READ  = 1
} axi_cmd ;

typedef enum bit[`AXI_BURST_WIDTH-1:0] 
{
  FIXED = 0 , 
  INCR  = 1 , 
  WRAP  = 2 , 
  RESERVED_BURST = 3
} axi_burst_type_enum ;

typedef enum bit[`AXI_SIZE_WIDTH-1:0] 
{  
  BYTE_1   = 0 ,
  BYTE_2   = 1 ,
  BYTE_4   = 2 ,
  BYTE_8   = 3 ,
  BYTE_16  = 4 ,
  BYTE_32  = 5 ,
  BYTE_64  = 6 ,
  BYTE_128 = 7 
} axi_byte_size_enum ;

//只支持[3:0]的len
typedef enum bit[`AXI_LEN_WIDTH-1:0] 
{  
  LEN_1  = 0  ,
  LEN_2  = 1  ,
  LEN_3  = 2  ,
  LEN_4  = 3  ,
  LEN_5  = 4  ,
  LEN_6  = 5  ,
  LEN_7  = 6  ,
  LEN_8  = 7  ,
  LEN_9  = 8  ,
  LEN_10 = 9  ,
  LEN_11 = 10 ,
  LEN_12 = 11 ,
  LEN_13 = 12 ,
  LEN_14 = 13 ,
  LEN_15 = 14 ,
  LEN_16 = 15 
} axi_burst_length_enum ;

typedef enum bit[`AXI_RESP_WIDTH-1:0]
{
  OKAY   = 0 ,
  EXOKAY = 1 ,
  SLVERR = 2 ,
  DECERR = 3
} axi_response_enum ;

function bit[`AXI_BURST_WIDTH-1:0] get_burst_type(axi_burst_type_enum burst_type) ;
  case(burst_type)
    FIXED : get_burst_type = 0 ;
    INCR  : get_burst_type = 1 ;
    WRAP  : get_burst_type = 2 ;
    RESERVED_BURST : get_burst_type = 3 ;
  endcase
endfunction

function axi_burst_type_enum get_burst_type_enum(bit[`AXI_BURST_WIDTH-1:0] burst_type) ;
  case(burst_type)
    0 : get_burst_type_enum = FIXED ;
    1 : get_burst_type_enum = INCR ;
    2 : get_burst_type_enum = WRAP ;
    3 : get_burst_type_enum = RESERVED_BURST ;
  endcase
endfunction

function bit[`AXI_SIZE_WIDTH-1:0] get_byte_size(axi_byte_size_enum byte_size) ;
  case(byte_size)
    BYTE_1   : get_byte_size = 0 ;
    BYTE_2   : get_byte_size = 1 ;
    BYTE_4   : get_byte_size = 2 ;
    BYTE_8   : get_byte_size = 3 ;
    BYTE_16  : get_byte_size = 4 ;
    BYTE_32  : get_byte_size = 5 ;
    BYTE_64  : get_byte_size = 6 ;
    BYTE_128 : get_byte_size = 7 ;
  endcase
endfunction

function axi_byte_size_enum get_byte_size_enum(bit[`AXI_SIZE_WIDTH-1:0] byte_size) ;
  case(byte_size)
    0 : get_byte_size_enum = BYTE_1 ;
    1 : get_byte_size_enum = BYTE_2 ;
    2 : get_byte_size_enum = BYTE_4 ;
    3 : get_byte_size_enum = BYTE_8 ;
    4 : get_byte_size_enum = BYTE_16 ;
    5 : get_byte_size_enum = BYTE_32 ;
    6 : get_byte_size_enum = BYTE_64 ;
    7 : get_byte_size_enum = BYTE_128 ;
  endcase
endfunction

function bit[`AXI_LEN_WIDTH-1:0] get_burst_len(axi_burst_length_enum burst_len) ;
  case(burst_len)
    LEN_1   : get_burst_len = 0  ;
    LEN_2   : get_burst_len = 1  ;
    LEN_3   : get_burst_len = 2  ;
    LEN_4   : get_burst_len = 3  ;
    LEN_5   : get_burst_len = 4  ;
    LEN_6   : get_burst_len = 5  ;
    LEN_7   : get_burst_len = 6  ;
    LEN_8   : get_burst_len = 7  ;
    LEN_9   : get_burst_len = 8  ;
    LEN_10  : get_burst_len = 9  ;
    LEN_11  : get_burst_len = 10 ;
    LEN_12  : get_burst_len = 11 ;
    LEN_13  : get_burst_len = 12 ;
    LEN_14  : get_burst_len = 13 ;
    LEN_15  : get_burst_len = 14 ;
    LEN_16  : get_burst_len = 15 ;
    default : get_burst_len = 0  ;
  endcase
endfunction

function axi_burst_length_enum get_burst_len_enum(bit[`AXI_LEN_WIDTH-1:0] burst_len) ;
  case(burst_len)
    0  : get_burst_len_enum = LEN_1 ;
    1  : get_burst_len_enum = LEN_2 ;
    2  : get_burst_len_enum = LEN_3 ;
    3  : get_burst_len_enum = LEN_4 ;
    4  : get_burst_len_enum = LEN_5 ;
    5  : get_burst_len_enum = LEN_6 ;
    6  : get_burst_len_enum = LEN_7 ;
    7  : get_burst_len_enum = LEN_8 ;
    8  : get_burst_len_enum = LEN_9 ;
    9  : get_burst_len_enum = LEN_10 ;
    10 : get_burst_len_enum = LEN_11 ;
    11 : get_burst_len_enum = LEN_12 ;
    12 : get_burst_len_enum = LEN_13 ;
    13 : get_burst_len_enum = LEN_14 ;
    14 : get_burst_len_enum = LEN_15 ;
    15 : get_burst_len_enum = LEN_16 ;
    default : get_burst_len_enum = LEN_1 ;
  endcase
endfunction

function axi_response_enum get_resp_type_enum(bit[`AXI_RESP_WIDTH-1:0] resp_type);
  case(resp_type)
    0 : get_resp_type_enum = OKAY ;
    1 : get_resp_type_enum = EXOKAY ;
    2 : get_resp_type_enum = SLVERR ;
    3 : get_resp_type_enum = DECERR ;
  endcase
endfunction

//AXI输出结构体
typedef struct packed 
{
  logic [`AXI_ADDR_WIDTH-1:0]   aw_addr    ;
  logic [`AXI_PROT_WIDTH-1:0]   aw_prot    ;
  logic [`AXI_REGION_WIDTH-1:0] aw_region  ;
  logic [`AXI_LEN_WIDTH-1:0]    aw_len     ;
  logic [`AXI_SIZE_WIDTH-1:0]   aw_size    ;
  logic [`AXI_BURST_WIDTH-1:0]  aw_burst   ;
  logic                         aw_lock    ;
  logic [`AXI_CACHE_WIDTH-1:0]  aw_cache   ;
  logic [`AXI_QOS_WIDTH-1:0]    aw_qos     ;
  logic [`AXI_ID_WIDTH-1:0]     aw_id      ;
  logic [`AXI_USER_WIDTH-1:0]   aw_user    ;
  logic                         aw_valid   ;
} axi_aw_vec ;

typedef struct packed
{
  logic                        w_valid    ;
  logic [`AXI_STRB_WIDTH-1:0]  w_strb     ;
  logic [`AXI_USER_WIDTH-1:0]  w_user     ;
  logic                        w_last     ;
} axi_w_vec ;

typedef struct packed 
{
  logic [`AXI_ADDR_WIDTH-1:0]   ar_addr    ;
  logic [`AXI_PROT_WIDTH-1:0]   ar_prot    ;
  logic [`AXI_REGION_WIDTH-1:0] ar_region  ;
  logic [`AXI_LEN_WIDTH-1:0]    ar_len     ;
  logic [`AXI_SIZE_WIDTH-1:0]   ar_size    ;
  logic [`AXI_BURST_WIDTH-1:0]  ar_burst   ;
  logic                         ar_lock    ;
  logic [`AXI_CACHE_WIDTH-1:0]  ar_cache   ;
  logic [`AXI_QOS_WIDTH-1:0]    ar_qos     ;
  logic [`AXI_ID_WIDTH-1:0]     ar_id      ;
  logic [`AXI_USER_WIDTH-1:0]   ar_user    ;
  logic                         ar_valid   ;
} axi_ar_vec ;



`endif