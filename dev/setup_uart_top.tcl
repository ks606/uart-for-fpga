# Create project
project_new UART_TOP -overwrite

# Family, device, top-level file
set_global_assignment -name FAMILY "Cyclone IV E"
set_global_assignment -name DEVICE EP4CE6E22C8

set_global_assignment -name SYSTEMVERILOG_FILE ../src_sv/UART_TOP.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src_sv/UART.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src_sv/UART_TX.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src_sv/UART_RX.sv
set_global_assignment -name TOP_LEVEL_ENTITY UART_TOP

# Assign pins
set_location_assignment -to clk          PIN_23
set_location_assignment -to rst          PIN_25

set_location_assignment -to uart_tx      PIN_84
set_location_assignment -to uart_rx      PIN_85 
set_location_assignment -to rfd          PIN_86

#project_close