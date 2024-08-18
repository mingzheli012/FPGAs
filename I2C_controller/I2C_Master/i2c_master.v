    /*
I2C Master

Input:
    SCL:            Serial Clock
    SDA:            Serial DATA
    slave_addr:     Slave Address
    slave_reg_addr: Slave Register Address
    start_tx:       Start Transmission Signal
    operation:      read = 0, write = 1
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
    input operation,
    output [7:0] data_o,
    input rst                       // Async Reset
);

// SCL Generation   --> 100KHz Speed
// Default FPGA Clock = 50MHz --> 50M/100K = 500
reg SCL_clk;
assign SCL = SCL_clk;
reg[8:0] clk_counter;

// I2C Master FSM
reg[7:0] i2c_master_state, i2c_master_next_state;
parameter INIT=8'd0,START=8'd1,ADDR6=8'd2,ADDR5=8'd3,ADDR4=8'd4,ADDR3=8'd5,ADDR2=8'd6,ADDR1=8'd7,ADDR0=8'd8;
parameter RW=8'd9,ACK1=8'd10,STOP=8'd11,REG7=8'd12,ACK2=8'd20,DATA7=8'd21,ACK3=8'd29;

reg BusBusy;
always@(posedge (i2c_master_state == INIT)) BusBusy = start_tx ? 1'b0 : 1'b1;

always@(posedge clk or posedge rst) begin
    if(rst) begin 
        clk_counter <= 9'b0; 
        SCL_clk <= 1'b1;
    end
    else begin
        if(BusBusy) begin
            clk_counter <= (clk_counter == 9'd500) ? 9'd0 : clk_counter+1'b1;
            SCL_clk <= (clk_counter == 9'd500) ? ~SCL_clk : SCL_clk;
        end else begin
            clk_counter <= 9'b0; 
            SCL_clk <= 1'b1;
        end
    end
end

// SDA IO Control
reg SDA_i, SDA_value;
always@(posedge SCL) SDA_i <= SDA;
wire SDA_control, ACK_control, Data_control, Start_control, Stop_control;
assign SDA_control = ACK_control | Data_control | Start_control | Stop_control;
assign ACK_control = ~((i2c_master_state == ACK1) | (i2c_master_state == ACK2) | (i2c_master_state == ACK3));   // When in ACK Stage, Let Slave take Control
assign Data_control = ~SDA_value;
assign SDA = SDA_control ? 1'b0 : 1'bz;

reg [3:0] SDA_delay;
always@(posedge clk or posedge rst) SDA_delay <= ((i2c_master_state == START)|(i2c_master_state == STOP)&(SCL)) ? ((SDA_delay > 4'h0) ? SDA_delay - 1'b1 : SDA_delay) : 4'hF;
assign Start_control = (i2c_master_state == START) & (SDA_delay == 4'd0);
assign Stop_control = (i2c_master_state == STOP) & (SDA_delay != 4'd0);

wire rw;
assign rw = operation;

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


always@(negedge SCL or posedge rst or posedge start_tx) begin
    if(rst) i2c_master_state <= INIT;
    else if(start_tx) i2c_master_state <= START;
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