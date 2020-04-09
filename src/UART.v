/********************************************************************************/
// Engineer:        
// Design Name: UART  
// Module Name: UART   
// Target Device:    
// Description: uart top level
//      
// Dependencies:
//    None
// Revision:
//    None
// Additional Comments: 
//
/********************************************************************************/
`timescale 1 ns/ 1 ns
module UART #(
	parameter 				CLK_FREQ = 100_000_000, 
	parameter 				BAUD_RATE = 9_600, 
	parameter 				PARITY = 1, 
	parameter 				DI_WIDTH = 8, 
	parameter 				DO_WIDTH = 8, 
	parameter 				M_TAPS = 3
	
)(
	input 					clk, 
	input 					rst,
	 
	input [DI_WIDTH-1:0] 	din,     	// input data
	input 					din_vld,		// valid signal of input data
	
	output 					tx,        	// transmitted data
	output 					rfd,    	// request for data
	
	input 					rx,       	// received data
  
	output [DO_WIDTH-1:0] 	dout,   	// output data
	output 					dout_vld,	// valid signal of output data
	output 					rx_err  	// error signal
	
);

/********************************************************************************/
// Parameters section
/********************************************************************************/   
	localparam 				BIT_NUM = PARITY + 10;
	localparam 				FREQ_DIV = CLK_FREQ/BAUD_RATE; 	// number of frequency pulses in 1 transmitted bit
	localparam 				BDCLK_COEF = (FREQ_DIV/2 - 1); 	// maximal coefficient of baud clock counter
	
/********************************************************************************/
// Signals declaration section
/********************************************************************************/     
	reg [$clog2(BDCLK_COEF)-1:0] BAUDCLK_CNT; 				// baud clock counter
	reg 					BAUDCLK;                        // baud pulse
	
	wire 					TX_CLK;
	wire					TX_RST;
	wire [DI_WIDTH-1:0]		TX_DIN;
	wire					TX_DIN_VLD;
	wire					TX_BAUDCLK;
	wire					TX_RFD;
	wire					TX_TX;
	
	wire					RX_CLK;
	wire					RX_RST;
	wire					RX_BAUDCLK;
	wire					RX_RX;
	wire [DO_WIDTH-1:0]		RX_DOUT;
	wire					RX_DOUT_VLD;
	
/********************************************************************************/
// Main section
/********************************************************************************/  
// baud clock description
	always @ (posedge clk or negedge rst) begin
		if (!rst) begin 
			BAUDCLK_CNT <= BDCLK_COEF; 
		end
		else if (BAUDCLK_CNT == 0) begin 
			BAUDCLK_CNT <= BDCLK_COEF; 
		end
		else begin 
			BAUDCLK_CNT <= BAUDCLK_CNT - 1; 
		end
    end
 
	always @ (posedge clk or negedge rst) begin 
		if (!rst) begin 
			BAUDCLK <= 0; 
		end
		else if (BAUDCLK_CNT == 0) begin 
			BAUDCLK <= !BAUDCLK; 
		end
    end
	
// TX instance
	
	assign TX_CLK = clk;
	assign TX_RST = rst;
	assign TX_DIN = din;
	assign TX_DIN_VLD = din_vld;
	assign TX_BAUDCLK = BAUDCLK;
	
	UART_TX #(
		.CLK_FREQ			(CLK_FREQ),
		.BAUD_RATE			(BAUD_RATE),
		.PARITY				(PARITY),
		.DI_WIDTH			(DI_WIDTH),
		.BIT_NUM			(BIT_NUM)
		
	) _TX (
		.clk				(TX_CLK),
		.rst				(TX_RST),
		// input interface
		.din				(TX_DIN),
		.din_vld			(TX_DIN_VLD),
		
		// output interface
		.baudclk			(TX_BAUDCLK),
		.rfd				(TX_RFD),
		.tx					(TX_TX)
		
	);

// RX instance 
	assign RX_CLK = clk;
	assign RX_RST = rst;
	assign RX_BAUDCLK = BAUDCLK;
	assign RX_RX = rx;

	UART_RX #(
		.CLK_FREQ			(CLK_FREQ),
		.BAUD_RATE			(BAUD_RATE),
		.PARITY				(PARITY),
		.DO_WIDTH			(DI_WIDTH),
		.BIT_NUM			(BIT_NUM),
		.M_TAPS				(M_TAPS)
		
	) _RX (
		.clk				(RX_CLK),
		.rst				(RX_RST),
		
		// input interface
		.baudclk			(RX_BAUDCLK),
		.rx					(RX_RX),
		
		// output interface
		.dout				(RX_DOUT),
		.dout_vld			(RX_DOUT_VLD),
		.err_out			(rx_err)
	
	);
	
/********************************************************************************/
// Output
/********************************************************************************/    
	assign rfd = TX_RFD;
	assign tx = TX_TX;
	assign dout = RX_DOUT;
	assign dout_vld = RX_DOUT_VLD;
	
endmodule
