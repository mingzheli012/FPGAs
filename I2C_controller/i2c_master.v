    /*
I2C Master

Input:
    SCL:            Serial Clock
    SDA:            Serial DATA
    slave_addr:     Slave Address
    slave_reg_addr: Slave Register Address
    start_tx:       Start Transmission Signal
    rst:            Async Reset
*/

module i2c_master(
    input clk,
    output SCL,
    inout SDA,
    input[6:0] slave_addr,
    input [7:0] slave_reg_addr,
    input [7:0] data_i,
    input start_tx,
    input rw,
    output [7:0] data_o,
    input rst                       // Async Reset
);

// SCL Generation   --> 100KHz Speed
// Default FPGA Clock = 50MHz --> 50M/100K = 500
reg SCL_clk;
assign SCL = SCL_clk;
reg[8:0] clk_counter;
always@(posedge clk or posedge rst) begin
    if(rst) begin 
        clk_counter <= 9'b0; 
        SCL_clk <= 1'b1;
    end
    else begin
        clk_counter <= (clk_counter == 9'd500) ? 9'd0 : clk_counter+1'b1;
        SCL_clk <= (clk_counter == 9'd500) ? ~SCL_clk : SCL_clk;
    end
end

// I2C Master FSM
reg[7:0] i2c_master_state, i2c_master_next_state;
parameter INIT=0,START=1,ADDR6=2,ADDR5=3,ADDR4=4,ADDR3=5,ADDR2=6,ADDR1=7,ADDR0=8;
parameter RW=9,ACK1=10,STOP=11,REG7=12,ACK2=20,DATA7=21,ACK3=29;

// SDA IO Control
reg SDA_i,SDA_o;
wire SDA_control;
assign SDA = SDA_control ? SDA_o : 1'b1;
always@(posedge SCL) SDA_i <= SDA_control ? 1'b1 : SDA;
assign SDA_control = ((i2c_master_state == ACK1) | (i2c_master_state == ACK2) | (i2c_master_state == ACK3)) ? 1'b0 : 1'b1;

reg [3:0] SDA_delay;
reg SDA_value;
always@(posedge clk or posedge rst) SDA_delay <= ((i2c_master_state == START)&(SCL)) ? ((SDA_delay > 4'h0) ? SDA_delay - 1'b1 : SDA_delay) : 4'hF;
always@(posedge clk or posedge rst) SDA_o <= SDA_value;

always@(*) begin
    case(i2c_master_state)
        START:      SDA_value = (SCL & (SDA_delay == 4'h0)) ? 1'b0 : 1'b1;
        ADDR6:      SDA_value = slave_addr[6];
        ADDR5:      SDA_value = slave_addr[5];
        ADDR4:      SDA_value = slave_addr[4];
        ADDR3:      SDA_value = slave_addr[3];
        ADDR2:      SDA_value = slave_addr[2];
        ADDR1:      SDA_value = slave_addr[1];
        ADDR0:      SDA_value = slave_addr[0];
        RW:         SDA_value = rw;
        default:    SDA_value = 1'b1;
    endcase
end


always@(negedge SCL or posedge rst) begin
    if(rst) i2c_master_state <= INIT;
    else i2c_master_state <= i2c_master_next_state;
end

always@(*) begin
    case(i2c_master_state)
        INIT:       i2c_master_next_state = start_tx ? START : INIT;
        START:      i2c_master_next_state = ADDR6;
        STOP:       i2c_master_next_state = INIT;
        ACK1:       i2c_master_next_state = SDA_i ? STOP : REG7;
        ACK2:       i2c_master_next_state = SDA_i ? STOP : DATA7;
        ACK3:       i2c_master_next_state = STOP;
        default :   i2c_master_next_state = i2c_master_state + 1'd1;
    endcase
end
endmodule