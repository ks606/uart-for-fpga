`timescale 1 ns/1 ns
module UART_TX #(
    parameter CLK_FREQ = 16_000_000, 
    parameter BAUD_RATE = 9_600, 
    parameter PARITY = 1, 
    parameter DI_WIDTH = 8, 
    parameter BIT_NUM = 10 + PARITY
    
)(
    input clk, 
    input rst,
    input din_vld,      // input data valid signal
    input  baudclk, 

    input [DI_WIDTH-1:0] din,      // input data

    output rfd,         // request for data
    output tx           // transmitted data
    
);

//-------------------- 
// Parameters & signals
//--------------------  
    localparam START = 0;
    localparam STOP = 0;
    localparam IDLE = 1;
     
    wire PARITY_ON;         // parity flag, 1 - on, 0 - off
    wire TXPARITY;          // parity value
    reg [3:0] TXBIT_CNT;    // transmitted bit counter
    reg [7:0] DIN_REG;      // shift register

    reg TRANSMIT_ON;        // transmitting flag
    reg RFD_REG;
    reg TX_OUT;

//-------------------- 
// Main section
//-------------------- 
// transmitting flag  
    always @ (posedge clk or negedge rst)
        if (!rst)
            TRANSMIT_ON <= 0; 
        else if (din_vld)
            TRANSMIT_ON <= 1; 
        else if (TXBIT_CNT == 0)
            TRANSMIT_ON <= 0; 

 // request for data 
    always @ (posedge clk or negedge rst)
        if (!rst)
            RFD_REG <= 1'b1; 
        else if (TXBIT_CNT == 0)
            RFD_REG <= 1'b1; 
        else if (TRANSMIT_ON)
            RFD_REG <= 1'b0; 

// transmittig bit counter
    always @ (posedge baudclk or negedge rst)
        if (!rst)
            TXBIT_CNT <= BIT_NUM; 
        else if (TXBIT_CNT == 0)
            TXBIT_CNT <= BIT_NUM; 
        else if (TRANSMIT_ON)
            TXBIT_CNT <= TXBIT_CNT - 1'b1; 
    
// shift register  
    always @ (posedge clk or negedge rst)
        if (!rst)
            DIN_REG <= 0; 
        //else if (din_vld && RFD_REG) begin 
        else if (din_vld)
            DIN_REG <= din; 
    
// parity calculation
    assign PARITY_ON = PARITY;
    assign TXPARITY = ^ DIN_REG;	//DIN_REG [7] ^ ... ^ DIN_REG [0];
  
// TX output   
    always @ (*)
        if (PARITY_ON) begin
            case (TXBIT_CNT)
                4'd10:  TX_OUT = START; 
                4'd9:   TX_OUT = DIN_REG [0];
                4'd8:   TX_OUT = DIN_REG [1];
                4'd7:   TX_OUT = DIN_REG [2];
                4'd6:   TX_OUT = DIN_REG [3];
                4'd5:   TX_OUT = DIN_REG [4];
                4'd4:   TX_OUT = DIN_REG [5];
                4'd3:   TX_OUT = DIN_REG [6];
                4'd2:   TX_OUT = DIN_REG [7];
                4'd1:   TX_OUT = TXPARITY;
                4'd0:   TX_OUT = STOP;
                default:TX_OUT = IDLE;
            endcase
        end else begin
            case (TXBIT_CNT)
                4'd9:   TX_OUT = START;
                4'd8:   TX_OUT = DIN_REG [0];
                4'd7:   TX_OUT = DIN_REG [1];
                4'd6:   TX_OUT = DIN_REG [2];
                4'd5:   TX_OUT = DIN_REG [3];
                4'd4:   TX_OUT = DIN_REG [4];
                4'd3:   TX_OUT = DIN_REG [5];
                4'd2:   TX_OUT = DIN_REG [6];
                4'd1:   TX_OUT = DIN_REG [7];
                4'd0:   TX_OUT = STOP; 
                default:TX_OUT = IDLE; 
            endcase
        end
    
//-------------------- 
// Output
//--------------------   
    assign rfd = RFD_REG;
    assign tx = TX_OUT;
    
endmodule