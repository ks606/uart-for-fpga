transcript on
vlib work

vlog -v +incdir+./ src./UART_TB.sv

vsim -t 1ns -voptargs="+acc" UART_TB

# UART1
add wave 						/UART_TB/UART1_CLK
add wave 						/UART_TB/UART1_RST

add wave 	-radix unsigned		/UART_TB/UART1_DIN
add wave 						/UART_TB/UART1_DIN_VLD
# add wave 						/UART_TB/UART1_RFD
add wave 						/UART_TB/UART1_TX

# UART2
add wave 						/UART_TB/UART2_CLK
add wave 						/UART_TB/UART2_RST
add wave 						/UART_TB/UART2_RFD

add wave 						/UART_TB/UART2_RX
add wave 	-radix unsigned		/UART_TB/UART2_DOUT
add wave 						/UART_TB/UART2_DOUT_VLD
add wave 						/UART_TB/UART2_ERR


configure wave -timelineunits ns
run
wave zoom full