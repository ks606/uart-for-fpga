`timescale 1 ns/1 ns
module UART_RX #(
    parameter CLK_FREQ = 16_000_000, 
    parameter BAUD_RATE = 9_600, 
    parameter PARITY = 1, 
    parameter DO_WIDTH = 8, 
    parameter BIT_NUM = 10,
    parameter M_TAPS = 3
    
)(
    input clk,
    input rst,
    input baudclk,
    input rx,
    
    output [DO_WIDTH-1:0] dout,
    output dout_vld,
    output err_out

);

//--------------------
// Parameters & signals
//--------------------  
    wire PARITY_ON;
    wire RXPARITY;
    wire MJE_OUT;   // output of majority element

    reg [DO_WIDTH-1:0]  RX_REG;     // register of input data
    reg [3:0]           RXBIT_CNT;  // transmitted bit counter
    reg [DO_WIDTH-1:0]  DOUT_REG;

    reg RECEIVE_ON;
    reg DOUT_VLD_REG;
    reg ERR_OUT_REG;

//--------------------  
// Main
//--------------------  
// majority element
    genvar i;
    generate
        for (i = 0; i < M_TAPS; i = i + 1) 
        begin: MJRT
            reg MJE_IN;
            if (i == 0) begin
                always @ (posedge clk)
                    MJE_IN <= rx;
            end else begin
                always @ (posedge clk)
                    MJRT[i].MJE_IN <= MJRT[i-1].MJE_IN;
            end
        end
    endgenerate
  
    assign MJE_OUT = (MJRT[2].MJE_IN && MJRT[1].MJE_IN)||
                     (MJRT[2].MJE_IN && MJRT[0].MJE_IN)||
                     (MJRT[1].MJE_IN && MJRT[0].MJE_IN); 

// receiving bit counter
    always @ (posedge clk or negedge rst)
        if (!rst)
            RECEIVE_ON <= 0; 
        else if (RXBIT_CNT == BIT_NUM && MJE_OUT == 0)
            RECEIVE_ON <= 1; 
        else if (RXBIT_CNT == 0)
            RECEIVE_ON <= 0; 
  
    always @ (posedge baudclk or negedge rst)
        if (!rst)
            RXBIT_CNT <= BIT_NUM; 
        else if (RECEIVE_ON)
            RXBIT_CNT <= RXBIT_CNT - 1'b1; 
        else if (RXBIT_CNT == 0)
            RXBIT_CNT <= BIT_NUM; 
    
// parity calculation
    assign PARITY_ON = PARITY;
    assign RXPARITY = ^ RX_REG; //RX_REG [7] ^ ... ^ RX_REG [0];

// error signal                    
    always @ (posedge clk or negedge rst)
        if (!rst)
            ERR_OUT_REG <= 0; 
        else if (RXBIT_CNT == 0)
            ERR_OUT_REG <= ((!RX_REG[7] ^ RXPARITY) & PARITY_ON); 
  
// data receiving
    always @ (posedge baudclk or negedge rst)
        if (!rst)
            RX_REG <= 0; 
        else
            RX_REG <= {MJE_OUT, RX_REG[7:1]};

// data output  
    always @ (posedge clk or negedge rst)
        if (!rst) begin 
            DOUT_REG <= 0; 
        end else if (RXBIT_CNT == 1 + PARITY) begin
            DOUT_REG <= RX_REG;
            DOUT_VLD_REG <= 1'b1; 
        end else begin 
            DOUT_REG <= 0; 
            DOUT_VLD_REG <= 1'b0; 
        end

//-------------------- 
// Output
//-------------------- 
    assign dout = DOUT_REG;
    assign dout_vld = DOUT_VLD_REG;
    assign err_out = ERR_OUT_REG;

endmodule