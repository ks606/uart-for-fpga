transcript on
vlib work

vlog -sv +incdir+./ src./UART_TB2.sv

vsim -t 1ns -voptargs="+acc" UART_TB2

add wave 	-radix unsigned		/UART_TB2/CLK1_FREQ
add wave 	-radix unsigned		/UART_TB2/CLK2_FREQ
add wave 	-radix unsigned		/UART_TB2/BAUD_RATE
add wave 						/UART_TB2/PARITY

# UART1
add wave 						/UART_TB2/UART1_CLK
add wave 						/UART_TB2/UART1_RST

add wave 						/UART_TB2/UART1_RFD
add wave 	-radix unsigned		/UART_TB2/UART1_TXDIN
add wave 						/UART_TB2/UART1_TXDIN_VLD
add wave 	-radix binary		/UART_TB2/_UART1/_TX/TX_DOUT_REG
add wave 	            		/UART_TB2/_UART1/_TX/TX_SYNC
add wave 	-radix unsigned		/UART_TB2/_UART1/_TX/TX_BIT_CNT
add wave 						/UART_TB2/UART1_TX

add wave 						/UART_TB2/UART1_RX
add wave 	            		/UART_TB2/_UART1/_RX/RX_SYNC
add wave 	-radix unsigned		/UART_TB2/_UART1/_RX/RX_BIT_CNT
add wave 	-radix binary		/UART_TB2/_UART1/_RX/RX_SHREG
add wave 	-radix binary		/UART_TB2/_UART1/_RX/RXDOUT_REG
#add wave 						/UART_TB2/UART1_ERR
add wave 	-radix unsigned		/UART_TB2/UART1_RXDOUT
add wave 						/UART_TB2/UART1_RXDOUT_VLD

# UART2
add wave 						/UART_TB2/UART2_CLK
add wave 						/UART_TB2/UART2_RST

add wave 						/UART_TB2/UART2_RFD
add wave 	-radix unsigned		/UART_TB2/UART2_TXDIN
add wave 						/UART_TB2/UART2_TXDIN_VLD
add wave 	-radix binary		/UART_TB2/_UART2/_TX/TX_DOUT_REG
add wave 	            		/UART_TB2/_UART2/_TX/TX_SYNC
add wave 	-radix unsigned		/UART_TB2/_UART2/_TX/TX_BIT_CNT
add wave 						/UART_TB2/UART2_TX

add wave 						/UART_TB2/UART2_RX
add wave 	            		/UART_TB2/_UART2/_RX/RX_SYNC
add wave 	-radix unsigned		/UART_TB2/_UART2/_RX/RX_BIT_CNT
add wave 	-radix binary		/UART_TB2/_UART2/_RX/RX_SHREG
add wave 	-radix binary		/UART_TB2/_UART2/_RX/RXDOUT_REG
#add wave 						/UART_TB2/UART2_ERR
add wave 	-radix unsigned		/UART_TB2/UART2_RXDOUT
add wave 						/UART_TB2/UART2_RXDOUT_VLD


configure wave -timelineunits ns
run
wave zoom full