`timescale 1 ns/1 ps
module UART_TB #(
	parameter				CLK1_FREQ = 100_000_000,	// input frequency, Hz
	parameter				CLK2_FREQ = 100_000_000,	// input frequency, Hz
    parameter				BAUD_RATE = 9_600,    		// baud rate
    parameter				PARITY = 0,             	// 1 - on (even), 0 - off
    parameter				DI_WIDTH = 8,           	// width of input data
    parameter				DO_WIDTH = 8,           	// width of output data
    parameter				M_TAPS = 3					// taps of majority element
	
)(
);
	logic 					UART1_CLK = 0;               
	logic 					UART1_RST = 0;
	logic 					UART1_TX;          			// transmitted data
	logic 					UART1_RX;            		// received data
	
	logic 					UART1_RFD;          		// request for data
	logic 					UART1_DIN_VLD = 0;    		// valid signal of input data 
	logic [DI_WIDTH-1:0] 	UART1_DIN = 0;        		// input data  
	logic [DO_WIDTH-1:0] 	UART1_DOUT;          		// output data
	logic 					UART1_DOUT_VLD;       		// valid signal of output data
	logic 					UART1_ERR;          		// error signal

	UART #(
		.CLK_FREQ			(CLK1_FREQ),
		.BAUD_RATE			(BAUD_RATE),
		.PARITY				(PARITY),
		.DI_WIDTH			(DI_WIDTH),
		.DO_WIDTH			(DO_WIDTH),
		.M_TAPS				(M_TAPS)
		
	) _UART1 (
		.clk				(UART1_CLK),
		.rst				(UART1_RST),
		// TX interface
		.rfd				(UART1_RFD),
		.din				(UART1_DIN),
		.din_vld			(UART1_DIN_VLD),
		.tx					(UART1_TX),
		// RX interface
		.rx					(UART1_RX),
		.dout				(UART1_DOUT),
		.dout_vld			(UART1_DOUT_VLD),
		.rx_err				(UART1_ERR)
		
	); 
	
	logic 					UART2_CLK = 0;               
	logic 					UART2_RST = 0;
	logic 					UART2_TX;          		// transmitted data
	logic 					UART2_RX;            	// received data
	
	assign UART1_RX = UART2_TX;
	assign UART2_RX = UART1_TX;
	
	logic 					UART2_RFD;          	// request for data
	logic 					UART2_DIN_VLD = 0;    	// valid signal of input data 
	logic [DI_WIDTH-1:0] 	UART2_DIN = 0;        	// input data  
	logic [DO_WIDTH-1:0] 	UART2_DOUT;          	// output data
	logic 					UART2_DOUT_VLD;       	// valid signal of output data
	logic 					UART2_ERR;          	// error signal
	
	UART #(
		.CLK_FREQ			(CLK2_FREQ),
		.BAUD_RATE			(BAUD_RATE),
		.PARITY				(PARITY),
		.DI_WIDTH			(DI_WIDTH),
		.DO_WIDTH			(DO_WIDTH),
		.M_TAPS				(M_TAPS)
		
	) _UART2 (
		.clk				(UART2_CLK),
		.rst				(UART2_RST),
		// TX interface
		.rfd				(UART2_RFD),
		.din				(UART2_DIN),
		.din_vld			(UART2_DIN_VLD),
		.tx					(UART2_TX),
		// RX interface
		.rx					(UART2_RX),
		.dout				(UART2_DOUT),
		.dout_vld			(UART2_DOUT_VLD),
		.rx_err				(UART2_ERR)
	
	);
	
	always #5 UART1_CLK = !UART1_CLK;
	always #5 UART2_CLK = !UART2_CLK;
	
	always #3 UART1_RST = 1;
	always #3 UART2_RST = 1;
	
	initial begin
		@ (UART1_RFD) UART1_DIN_VLD = 1; UART1_DIN = 8'd100;
		//@ (!UART1_RFD) UART1_DIN_VLD = 0; UART1_DIN = 8'd0;
    end
  
	initial begin
		@ (UART2_RFD) UART2_DIN_VLD = 1; UART2_DIN = 8'd200;
		//@ (!UART1_RFD) UART1_DIN_VLD = 0; UART1_DIN = 8'd0;
    end
  
endmodule
