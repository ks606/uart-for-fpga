`timescale 1 ns/1 ns
module UART_TX #(
    parameter CLK_DIV,
    parameter PARITY = 1, 
    parameter DI_WIDTH = 8, 
    parameter BIT_NUM = 10 + PARITY
    
)(
    input clk, 
    input rst,
    input [DI_WIDTH-1:0] din,   // input data
    input din_vld,              // input data valid signal
    
    output rfd,     // request for data
    output uart_tx  // transmitted data
    
  );

//-------------------- 
// Parameters & signals
//--------------------  
    localparam START = 0;
    localparam STOP  = 0;
    localparam IDLE  = 1;
     
    logic [15:0]    CLK_DIV_CNT = 0;
    logic           TX_SYNC     = 0;
    logic [3:0]     TX_BIT_CNT  = 0;
    logic [10:0]    TX_SHREG    = 0;
    logic           UART_TX_REG = 1;
    logic [7:0]     TX_DOUT_REG = 0;
    
//-------------------- 
// Main
//-------------------- 
    // TX clock divider 
    logic CLK_DIV_CNT_RST;  // clock divider reset
    logic CLK_DIV_CNT_EN;   // counting enable
    
    assign CLK_DIV_CNT_RST = (CLK_DIV_CNT == CLK_DIV - 1) | ~TX_SYNC; 
    assign CLK_DIV_CNT_EN  = TX_SYNC;

    always_ff @ (posedge clk)
        if (CLK_DIV_CNT_RST)
            CLK_DIV_CNT <= 0;
        else if ( CLK_DIV_CNT_EN )
            CLK_DIV_CNT <= CLK_DIV_CNT + 1'b1;
    
    // TX sync register RX_IN_SYNC
    logic TX_SYNC_RST;
    logic TX_SYNC_SET;
    
    assign TX_SYNC_RST =  TX_SYNC & ( TX_BIT_CNT == 10 );
    assign TX_SYNC_SET = ~TX_SYNC & din_vld;
    
    always_ff @ (posedge clk)
        if (TX_SYNC_RST)
            TX_SYNC <= 0;
        else if (TX_SYNC_SET)
            TX_SYNC <= 1;
    
    // TX bit counter TX_BIT_CNT
    logic TX_BIT_CNT_RST;
    logic TX_BIT_CNT_EN;
    
    assign TX_BIT_CNT_RST = ~TX_SYNC;    // rx bit counter reset
    assign TX_BIT_CNT_EN  = ( CLK_DIV_CNT == CLK_DIV - 1 );
    
    always_ff @ (posedge clk)
        if (TX_BIT_CNT_RST)
            TX_BIT_CNT <= 0;
        else if (TX_BIT_CNT_EN)
            TX_BIT_CNT <= TX_BIT_CNT + 1'b1;
    
    // TX shift reg TX_SHREG
    logic  TX_SHREG_EN;
    logic  TX_SHREG_LOAD;
    assign TX_SHREG_EN   = (CLK_DIV_CNT == CLK_DIV - 1);
    assign TX_SHREG_LOAD = ~TX_SYNC & din_vld;
    
    always_ff @ (posedge clk)
        if (TX_SHREG_LOAD)
            TX_SHREG <= {2'b11, din, 1'b0};
        else if (TX_SHREG_EN)
            TX_SHREG <= {1'b1, TX_SHREG[9:1]};
    
    // TX_DOUT_REG
    always_ff @ (posedge clk)
        if (TX_SHREG_LOAD)
            TX_DOUT_REG <= din;
    
    // UART TX_REG
    always_ff @ (posedge clk)
        if (TX_SYNC)
            UART_TX_REG <= TX_SHREG[0];
        else
            UART_TX_REG <= 1'b1;
    
//-------------------- 
// Output
//-------------------- 
    assign uart_tx = UART_TX_REG;
    assign rfd     = ~TX_SYNC;
    
endmodule