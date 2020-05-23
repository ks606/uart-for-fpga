`define _U1U2       // test Uart1 <-> Uart2
`define _U1         // test Uart1 -> Uart2 -> Uart1

`timescale 1 ns/1 ps
module UART_TB2 #(
    parameter               CLK1_FREQ = 77_000_000,     // input frequency, Hz
    parameter               CLK2_FREQ = 55_000_000,        // input frequency, Hz
    parameter               BAUD_RATE = 9_600,            // baud rate
    parameter               PARITY = 0,                 // 1 - on (even), 0 - off
    parameter               DI_WIDTH = 8,               // width of input data
    parameter               DO_WIDTH = 8,               // width of output data
    parameter               M_TAPS = 3                    // taps of majority element
    
)(
);
    logic                   UART1_CLK = 0;               
    logic                   UART1_RST = 0;
    logic                   UART1_TX;                      // transmitted data
    logic                   UART1_RX;                    // received data
    
    logic                   UART1_RFD;                  // request for data
    logic                   UART1_TXDIN_VLD = 0;            // valid signal of input data 
    logic [DI_WIDTH-1:0]    UART1_TXDIN = 0;                // input data  
    logic [DO_WIDTH-1:0]    UART1_RXDOUT;                  // output data
    logic                   UART1_RXDOUT_VLD;               // valid signal of output data
    logic                   UART1_ERR;                  // error signal

    UART #(
        .CLK_FREQ           (CLK1_FREQ),
        .BAUD_RATE          (BAUD_RATE),
        .PARITY                (PARITY),
        .DI_WIDTH            (DI_WIDTH),
        .DO_WIDTH            (DO_WIDTH),
        .M_TAPS                (M_TAPS)
        
    ) _UART1 (
        .clk                (UART1_CLK),
        .rst                (UART1_RST),
        
        // TX interface
        .rfd                (UART1_RFD),
        .din                (UART1_TXDIN),
        .din_vld            (UART1_TXDIN_VLD),
        .uart_tx            (UART1_TX),
        
        // RX interface
        .uart_rx            (UART1_RX),
        .dout                (UART1_RXDOUT),
        .dout_vld            (UART1_RXDOUT_VLD),
        .rx_err                (UART1_ERR)
        
    ); 
    
    logic                     UART2_CLK = 0;               
    logic                     UART2_RST = 0;
    logic                     UART2_TX;                  // transmitted data
    logic                     UART2_RX;                // received data
    
    assign UART1_RX = UART2_TX;
    assign UART2_RX = UART1_TX;
    
    logic                     UART2_RFD;              // request for data
    
    logic [DO_WIDTH-1:0]     UART2_RXDOUT;              // output data
    logic                     UART2_RXDOUT_VLD;           // valid signal of output data
    logic                     UART2_ERR;              // error signal
    
`ifdef _U1U2
    logic                     UART2_TXDIN_VLD = 0;        // valid signal of input data 
    logic [DI_WIDTH-1:0]     UART2_TXDIN = 0;            // input data  
    
    initial forever @ (UART2_RFD) begin
        fork
            #1000_000 UART2_TXDIN_VLD = 1; 
            #1000_000 UART2_TXDIN = $urandom();
        join
        #100_000 UART2_TXDIN_VLD = 0; 
    end
    
`elsif _U1
    logic                     UART2_TXDIN_VLD;        
    logic [DI_WIDTH-1:0]     UART2_TXDIN;
    
    assign UART2_TXDIN_VLD = UART2_RXDOUT_VLD;
    assign UART2_TXDIN = UART2_RXDOUT;
`endif
    
    UART #(
        .CLK_FREQ            (CLK2_FREQ),
        .BAUD_RATE            (BAUD_RATE),
        .PARITY                (PARITY),
        .DI_WIDTH            (DI_WIDTH),
        .DO_WIDTH            (DO_WIDTH),
        .M_TAPS                (M_TAPS)
        
    ) _UART2 (
        .clk                (UART2_CLK),
        .rst                (UART2_RST),
        
        // TX interface
        .rfd                (UART2_RFD),
        .din                (UART2_TXDIN),
        .din_vld            (UART2_TXDIN_VLD),
        .uart_tx            (UART2_TX),
        
        // RX interface
        .uart_rx            (UART2_RX),
        .dout                (UART2_RXDOUT),
        .dout_vld            (UART2_RXDOUT_VLD),
        .rx_err                (UART2_ERR)
    
    );
    
    always #6.493 UART1_CLK = !UART1_CLK;
    always #9.09  UART2_CLK = !UART2_CLK;
    
    always #3 UART1_RST = 1;
    always #3 UART2_RST = 1;

    initial forever @ (UART1_RFD) begin
        fork
            #1000_000 UART1_TXDIN_VLD = 1; 
            #1000_000 UART1_TXDIN = $urandom();
        join
        #100_000 UART1_TXDIN_VLD = 0; 
    end
    
endmodule