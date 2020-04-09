/********************************************************************************/
// Engineer:        
// Design Name: UART  
// Module Name: UART_TX     
// Target Device:    
// Description: uart transceiver
//      
// Dependencies:
//    None
// Revision:
//    None
// Additional Comments: 
//
/********************************************************************************/
`timescale 1 ns/1 ns
module UART_TX #(
	parameter 				CLK_FREQ = 16_000_000, 
    parameter          		BAUD_RATE = 9_600, 
    parameter          		PARITY = 1, 
    parameter          		DI_WIDTH = 8, 
    parameter          		BIT_NUM = 10
	
)(
	input 					clk, 
	input 					rst,
	input [DI_WIDTH-1:0] 	din,      // input data
	input 					din_vld,  // input data valid signal
	
	input 					baudclk, 
	output 					rfd,      // request for data
	output 					tx        // transmitted data
	
  );

/********************************************************************************/
// Parameters section
/********************************************************************************/  
	localparam 				START = 0;
	localparam 				STOP = 0;
	localparam 				IDLE = 1;
	
/********************************************************************************/
// Signals declaration section
/********************************************************************************/   
	wire 					PARITY_ON;		// parity flag, 1 - on, 0 - off
	wire 					TXPARITY;  		// parity value
	reg [3:0] 				TXBIT_CNT;    	// transmitted bit counter
	reg 					TRANSMIT_ON;  	// transmitting flag
	reg [7:0] 				SHIFT_REG;   	// shift register
	reg 					RFD_REG;
	reg 					TX_OUT;

/********************************************************************************/
// Main section
/********************************************************************************/
// transmitting flag  
	always @ (posedge clk or negedge rst) begin
		if (!rst) begin 
			TRANSMIT_ON <= 0; 
		end
		else if (din_vld) begin 
			TRANSMIT_ON <= 1; 
		end
		else if (TXBIT_CNT == 0) begin 
			TRANSMIT_ON <= 0; 
		end
    end
    
 // request for data 
	always @ (posedge clk or negedge rst) begin
		if (!rst) begin 
			RFD_REG <= 1'b1; 
		end
		else if (TXBIT_CNT == 0) begin 
			RFD_REG <= 1'b1; 
		end
		else if (TRANSMIT_ON) begin 
			RFD_REG <= 1'b0; 
		end
    end
    
// transmittig bit counter
	always @ (posedge baudclk or negedge rst) begin
		if (!rst) begin 
			TXBIT_CNT <= BIT_NUM; 
		end
		else if (TXBIT_CNT == 0) begin 
			TXBIT_CNT <= BIT_NUM; 
		end
		else if (TRANSMIT_ON) begin 
			TXBIT_CNT <= TXBIT_CNT - 1'b1; 
		end
    end
    
// shift register  
	always @ (posedge clk or negedge rst) begin
		if (!rst) begin 
			SHIFT_REG <= 0; 
		end
		//else if (din_vld && RFD_REG) begin 
		else if (din_vld) begin 
			SHIFT_REG <= din; 
		end
    end
    
// parity calculation
	assign PARITY_ON = PARITY;
	assign TXPARITY = ^ SHIFT_REG;	//SHIFT_REG [7] ^ ... ^ SHIFT_REG [0];
  
// TX output   
	always @ (*) begin
		if (PARITY_ON) begin
			case (TXBIT_CNT)
				4'd10:		TX_OUT = START; 
				4'd9:  		TX_OUT = SHIFT_REG [7];
				4'd8:  		TX_OUT = SHIFT_REG [6];
				4'd7:  		TX_OUT = SHIFT_REG [5];
				4'd6:		TX_OUT = SHIFT_REG [4];
				4'd5:		TX_OUT = SHIFT_REG [3];
				4'd4:		TX_OUT = SHIFT_REG [2];
				4'd3:		TX_OUT = SHIFT_REG [1];
				4'd2:		TX_OUT = SHIFT_REG [0];
				4'd1:		TX_OUT = TXPARITY;
				4'd0:		TX_OUT = STOP;
				default:	TX_OUT = IDLE;
			endcase
		end
		else begin
			case (TXBIT_CNT)
				4'd9:		TX_OUT = START;
				4'd8:		TX_OUT = SHIFT_REG [7];
				4'd7: 		TX_OUT = SHIFT_REG [6];
				4'd6: 		TX_OUT = SHIFT_REG [5];
				4'd5: 		TX_OUT = SHIFT_REG [4];
				4'd4: 		TX_OUT = SHIFT_REG [3];
				4'd3: 		TX_OUT = SHIFT_REG [2];
				4'd2: 		TX_OUT = SHIFT_REG [1];
				4'd1: 		TX_OUT = SHIFT_REG [0];
				4'd0: 		TX_OUT = STOP; 
				default: 	TX_OUT = IDLE; 
			endcase
		end
    end
	
/********************************************************************************/
// Output
/********************************************************************************/   
	assign rfd = RFD_REG;
	assign tx = TX_OUT;
	
endmodule