/********************************************************************************/
// Engineer:        
// Design Name: UART  
// Module Name: UART_RX     
// Target Device:    
// Description: uart receiver
//      
// Dependencies:
//    None
// Revision:
//    None
// Additional Comments: 
//
/********************************************************************************/
`timescale 1 ns/1 ns
module UART_RX #(
    parameter               CLK_DIV,
    parameter               PARITY = 1, 
    parameter               DO_WIDTH = 8, 
    parameter               BIT_NUM = 10
    
)(
    input                   clk,
    input                   rst,
    input                   uart_rx,
    
    output [DO_WIDTH-1:0]   dout,
    output                  dout_vld,
    output                  err_out

);

/********************************************************************************/
// Parameters section
/********************************************************************************/ 
/********************************************************************************/
// Signals declaration section
/********************************************************************************/   
    logic [15:0]            CLK_DIV_CNT  = 0;
    logic                   RX_SYNC      = 0;
    logic [3:0]             RX_BIT_CNT   = 0;
    logic [9:0]             RX_SHREG     = 0;
    logic [7:0]             RXDOUT_REG     = 0;
    logic                   RXDOUT_VLD_REG = 0;
/********************************************************************************/
// Main section
/********************************************************************************/    
    // RX clock divider CLK_DIV_CNT
    logic  CLK_DIV_CNT_RST;     // clock divider reset
    logic  CLK_DIV_CNT_EN;      // counting enable
    
    assign CLK_DIV_CNT_RST  = ( CLK_DIV_CNT == CLK_DIV - 1 );
    assign CLK_DIV_CNT_EN   = RX_SYNC;

    always_ff @ ( posedge clk ) begin
        if ( CLK_DIV_CNT_RST ) begin
            CLK_DIV_CNT <= 0;
        end
        else if ( CLK_DIV_CNT_EN ) begin 
            CLK_DIV_CNT <= CLK_DIV_CNT + 1'b1;
        end
    end
    
    // RX sync register RX_SYNC
    logic  RX_SYNC_RST;
    logic  RX_SYNC_SET;
    
    assign RX_SYNC_RST =  RX_SYNC & ( RX_BIT_CNT == 9 );
    assign RX_SYNC_SET = ~RX_SYNC & ~uart_rx;
    
    always_ff @ ( posedge clk ) begin
        if ( RX_SYNC_RST ) begin
            RX_SYNC <= 0;
        end
        else if ( RX_SYNC_SET ) begin
            RX_SYNC <= 1;
        end
    end
    
    // RX bit counter RX_BIT_CNT
    logic  RX_BIT_CNT_RST;
    logic  RX_BIT_CNT_EN;
    
    assign RX_BIT_CNT_RST = ~RX_SYNC;    // rx bit counter reset
    assign RX_BIT_CNT_EN  = ( CLK_DIV_CNT == CLK_DIV - 1 );
    
    always_ff @ ( posedge clk ) begin
        if ( RX_BIT_CNT_RST ) begin
            RX_BIT_CNT <= 0;
        end
        else if ( RX_BIT_CNT_EN ) begin
            RX_BIT_CNT <= RX_BIT_CNT + 1'b1;
        end
    end
    
    // RX data shift reg RX_SHREG
    logic  RX_SHREG_EN;
    assign RX_SHREG_EN = ( CLK_DIV_CNT == CLK_DIV/3 );
    
    always_ff @ ( posedge clk ) begin
        if ( RX_SHREG_EN ) begin
            RX_SHREG <= {uart_rx, RX_SHREG[9:1]};
        end
    end
    
    // RX DOUT
    always_ff @ ( clk ) begin
        if (RX_BIT_CNT == 9) begin
            RXDOUT_REG     <= RX_SHREG [9:2];
            RXDOUT_VLD_REG <= 1;
        end
    end
    
/********************************************************************************/
// Output
/********************************************************************************/
    assign dout     = RXDOUT_REG;
    assign dout_vld = RXDOUT_VLD_REG;

endmodule