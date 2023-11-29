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

module I2C_Master(
    input clk,
    output SCL,
    inout SDA,
    input[6:0] slave_addr,
    input [7:0] slave_reg_addr,
    input start_tx,
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


// SDA IO Control
reg SDA_i,SDA_o;
reg [3:0] SDA_delay;
wire SDA_control;
assign SDA = SDA_control ? SDA_o : 1'bz;
always@(posedge SCL) SDA_i <= SDA_control ? 1'b1 : SDA;
assign SDA_control = ((i2c_master_state == INIT) |(i2c_master_state == ACK1) | (i2c_master_state == ACK2) | (i2c_master_state == ACK3)) ? 1'b0 : 1'b1;
always@(posedge clk or posedge rst) begin
    if(rst) begin
        SDA_o <= 1'b1; SDA_delay <= 4'hF;
    end
    else begin
        SDA_delay <= ((i2c_master_state == START)&(SCL)) ? ((SDA_delay > 4'h0) ? SDA_delay - 1'b1 : SDA_delay) : 4'hF;
        if((i2c_master_state == START)&(SCL)) SDA_o <= (SDA_delay == 4'h0) ? 1'b0 : 1'b1;
    end
end


// I2C Master FSM
reg[7:0] i2c_master_state, i2c_master_next_state;
parameter INIT=0,START=1,ADDR6=2,ADDR0=8,RW=9,ACK1=10,STOP=11,REG7=12,ACK2=20,DATA7=21,ACK3=29;

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