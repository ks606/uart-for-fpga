`timescale 1 ns/ 1 ns

module UART #(
    parameter CLK_FREQ  = 50_000_000, 
    parameter BAUD_RATE = 9_600,
    parameter PARITY    = 0, 
    parameter DI_WIDTH  = 8, 
    parameter DO_WIDTH  = 8, 
    parameter M_TAPS    = 3
    
)(
    input clk, 
    input rst,
    input [DI_WIDTH-1:0] din,   // input data
    input din_vld,              // valid signal of input data
    output rfd,                 // request for data
    output uart_tx,             // transmitted data
    input uart_rx,              // received data
    output [DO_WIDTH-1:0] dout, // output data
    output dout_vld,            // valid signal of output data
    output rx_err               // error signal
    
);

//-------------------- 
// Parameters & signals
//--------------------   
    localparam BIT_NUM    = 10 + PARITY;
    localparam CLKIN_DIV  = CLK_FREQ/BAUD_RATE; // number of frequency pulses in 1 transmitted bit
    localparam BDCLK_COEF = (CLKIN_DIV/2 - 1);  // maximal coefficient of baud clock counter
        
    // TX
    logic TX_CLK;
    logic TX_RST;
    logic [DI_WIDTH-1:0] TX_DIN;
    logic TX_DIN_VLD;
    logic TX_RFD;
    logic TX_DOUT;
    
    // RX
    logic RX_CLK;
    logic RX_RST;
    logic RX_DIN;
    logic [DO_WIDTH-1:0] RX_DOUT;
    logic RX_DOUT_VLD;
    
//-------------------- 
// Main 
//-------------------- 
// TX instance
    assign TX_CLK     = clk;
    assign TX_RST     = rst;
    assign TX_DIN     = din;
    assign TX_DIN_VLD = din_vld;
    
    UART_TX #(
        .CLK_DIV    (CLKIN_DIV),
        .PARITY     (PARITY),
        .DI_WIDTH   (DI_WIDTH),
        .BIT_NUM    (BIT_NUM)
        
    ) _TX (
        .clk        (TX_CLK),
        .rst        (TX_RST),
        // input
        .din        (TX_DIN),
        .din_vld    (TX_DIN_VLD),
        
        // output
        .rfd        (TX_RFD),
        .uart_tx    (TX_DOUT)

    );

// RX instance 
    assign RX_CLK = clk;
    assign RX_RST = rst;
    
    // majority element
    genvar i;
    generate
        for (i = 0; i < M_TAPS; i = i + 1) begin: MJRT
            logic MJE_IN;
            if (i == 0)
                always_ff @ (posedge clk)
                    MJE_IN <= uart_rx;
            else
                always_ff @ (posedge clk)
                    MJRT[i].MJE_IN <= MJRT[i-1].MJE_IN;
        end
    endgenerate
  
    assign MJE_OUT = (MJRT[2].MJE_IN && MJRT[1].MJE_IN)||
                     (MJRT[2].MJE_IN && MJRT[0].MJE_IN)||
                     (MJRT[1].MJE_IN && MJRT[0].MJE_IN); 
    
    assign RX_DIN = MJE_OUT;
    
    UART_RX #(
        .CLK_DIV    (CLKIN_DIV),
        .PARITY     (PARITY),
        .DO_WIDTH   (DO_WIDTH),
        .BIT_NUM    (BIT_NUM)
        
    ) _RX (
        .clk        (RX_CLK),
        .rst        (RX_RST),
        
        // input
        .uart_rx    (RX_DIN),
        
        // output
        .dout       (RX_DOUT),
        .dout_vld   (RX_DOUT_VLD),
        .err_out    ()
    
    );
    
//-------------------- 
// Output
//--------------------    
    assign rfd      = TX_RFD;
    assign uart_tx  = TX_DOUT;
    assign dout     = RX_DOUT;
    assign dout_vld = RX_DOUT_VLD;
    
endmodule
