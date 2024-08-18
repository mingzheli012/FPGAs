vsim -gui work.master_tb_top
project compileall
restart

delete wave *

radix define i2c_state {
    8'd0 "INIT",
    8'd1 "ADDR6",
    8'd2 "ADDR5",
    8'd3 "ADDR4",
    8'd4 "ADDR3",
    8'd5 "ADDR2",
    8'd6 "ADDR1",
    8'd7 "ADDR0",
    8'd8 "RW",
    8'd9 "ACK1",
    8'd10 "WAIT",
    8'd11 "REG_ADDR7",
    8'd12 "REG_ADDR6",
    8'd13 "REG_ADDR5",
    8'd14 "REG_ADDR4",
    8'd15 "REG_ADDR3",
    8'd16 "REG_ADDR2",
    8'd17 "REG_ADDR1",
    8'd18 "REG_ADDR0",
    8'd19 "ACK2",
    8'd20 "DATA7",
    8'd21 "DATA6",
    8'd22 "DATA5",
    8'd23 "DATA4",
    8'd24 "DATA3",
    8'd25 "DATA2",
    8'd26 "DATA1",
    8'd27 "DATA0",
    8'd28 "ACK3",
    8'd29 "ACK4",
    8'd30 "DATA_OUT7",
    8'd31 "DATA_OUT6",
    8'd32 "DATA_OUT5",
    8'd33 "DATA_OUT4",
    8'd34 "DATA_OUT3",
    8'd35 "DATA_OUT2",
    8'd36 "DATA_OUT1",
    8'd37 "DATA_OUT0",
    8'd38 "NACK"
}


add wave -divider "Bus Signals"
add wave -radix hex /master_tb_top/rst
add wave -radix hex /master_tb_top/clk
add wave -radix hex /master_tb_top/SCL
add wave -radix hex /master_tb_top/SDA

add wave -divider "Slave0 Signals"
add wave -radix bin /master_tb_top/slave0/start_received
add wave -radix bin /master_tb_top/slave0/stop_received
add wave -radix i2c_state /master_tb_top/slave0/i2c_state
add wave -radix i2c_state /master_tb_top/slave0/i2c_next_state
add wave -radix hex /master_tb_top/slave0/data_memory
add wave -radix hex /master_tb_top/slave0/data_reg
add wave -radix hex /master_tb_top/slave0/addr_reg

add wave -divider "Master Signals"
add wave -radix hex /master_tb_top/master/i2c_master_state
add wave -radix hex /master_tb_top/master/i2c_master_next_state

run 2000000