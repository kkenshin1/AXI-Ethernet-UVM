`ifndef AXI_DEFINES_SVH
`define AXI_DEFINES_SVH

//AXI基本位宽信息
`define AXI_ADDR_WIDTH       32                 //地址位宽
`define AXI_DATA_WIDTH       256                //数据位宽
`define AXI_STRB_WIDTH       `AXI_DATA_WIDTH/8  //STRB位宽
`define AXI_LEN_WIDTH        8                  //读写数据长度位宽
`define AXI_SIZE_WIDTH       3                  //burst size位宽 
`define AXI_BURST_WIDTH      2                  //burst type位宽
`define AXI_RESP_WIDTH       2                  //response位宽
`define AXI_ID_WIDTH         6                  //ID位宽
`define AXI_QOS_WIDTH        4                  //QOS位宽
`define AXI_CACHE_WIDTH      4                  //cache位宽
`define AXI_USER_WIDTH       1                  //user位宽
`define AXI_REGION_WIDTH     4                  //region位宽
`define AXI_PROT_WIDTH       3                  //prot位宽

//AXI写延迟
`define AXI_MAX_WRITE_DELAY  20 

//AXI读延迟
`define AXI_MAX_READ_DELAY   50 

//AXI SLAVE起始地址
`define AXI_SLAVE0_ADDR      32'b0100_0000_0000_0000_0000_0000_0000_0000    //32'h4000_0000

`endif
