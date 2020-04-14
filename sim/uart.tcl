transcript on
vlib work

vlog -v +incdir+./ src./UART_TB.sv

vsim -t 1ns -voptargs="+acc" UART_TB

add wave 	-radix unsigned		/UART_TB/CLK1_FREQ
add wave 	-radix unsigned		/UART_TB/CLK2_FREQ
add wave 	-radix unsigned		/UART_TB/BAUD_RATE
add wave 						/UART_TB/PARITY

# UART1
add wave 						/UART_TB/UART1_CLK
add wave 						/UART_TB/UART1_RST

add wave 						/UART_TB/UART1_RFD
add wave 	-radix unsigned		/UART_TB/UART1_DIN
add wave 						/UART_TB/UART1_DIN_VLD
add wave 						/UART_TB/UART1_TX

add wave 						/UART_TB/UART1_RX
add wave 						/UART_TB/UART1_ERR
add wave 	-radix unsigned		/UART_TB/UART1_DOUT
add wave 						/UART_TB/UART1_DOUT_VLD

# UART2
add wave 						/UART_TB/UART2_CLK
add wave 						/UART_TB/UART2_RST

add wave 						/UART_TB/UART2_RFD
add wave 	-radix unsigned		/UART_TB/UART2_DIN
add wave 						/UART_TB/UART2_DIN_VLD
add wave 						/UART_TB/UART2_TX

add wave 						/UART_TB/UART2_RX
add wave 						/UART_TB/UART2_ERR
add wave 	-radix unsigned		/UART_TB/UART2_DOUT
add wave 						/UART_TB/UART2_DOUT_VLD


configure wave -timelineunits ns
run
wave zoom full