    /*
I2C Slave

Input:
    SCL:            Serial Clock
    SDA:            Serial DATA
    slave_addr:     Slave Address
    slave_reg_addr: Slave Register Address
    rst:            Async Reset
*/

module I2C_Slave(
    input clk,
    input SCL,
    inout SDA,
    input[6:0] slave_addr,
    input rst                       // Async Reset
);  

    // Generation of START/STOP/Data Valid Signal
    reg[2:0] data_state,data_next_state;
    parameter IDLE=3'd0, ValidData1=3'd1, ValidData0=3'd2, START=3'd3, STOP=3'd4;
    always@(posedge clk or posedge rst) begin
        if(rst) data_state <= IDLE;
        else data_state <= (SCL) ? data_next_state : IDLE;
    end
    always@(*) begin
        case(data_state)
            IDLE:       data_next_state = (SDA_control) ? IDLE : SDA_input ? ValidData1 : ValidData0;
            ValidData1: data_next_state = (SDA_control) ? IDLE : SDA_input ? ValidData1 : START;
            ValidData0: data_next_state = (SDA_control) ? IDLE : SDA_input ? STOP : ValidData0;
            default:    data_next_state = (SDA_control) ? IDLE : data_next_state;
        endcase
    end

    wire start_sign, stop_sign;
    assign start_sign = (data_state == START) ? 1'b1:1'b0;
    assign stop_sign = (data_state == STOP) ? 1'b1:1'b0;

    reg start_received, stop_received;
    always@(*) start_received <= (SCL) ? start_sign : start_received;
    always@(*) stop_received <= (SCL) ? stop_sign : stop_received;

    // I2C Data Register
    reg[7:0] data_reg;
    always@(posedge SCL or posedge rst) data_reg <= (rst) ? 8'd0 : {data_reg[6:0],SDA_input};

    // I2C FSM
    reg[7:0] i2c_state, i2c_next_state;
    parameter INIT=0,ADDR6=1,ADDR5=2,ADDR4=3,ADDR3=4,ADDR2=5,ADDR1=6,ADDR0=7;
    parameter RW_t=8,ACK1=9,WAIT=10,REG_ADDR7=11,REG_ADDR0=18;
    parameter ACK2=19,DATA7=20,DATA6=21,DATA0=27,ACK3=28,ACK4=29;
    parameter DATA_OUT7=30,DATA_OUT6=31,DATA_OUT5=32,DATA_OUT4=33,DATA_OUT3=34,DATA_OUT2=35,DATA_OUT1=36,DATA_OUT0=37,NACK=38;

    always@(negedge SCL or posedge rst) begin
        if(rst) i2c_state <= INIT;
        else i2c_state <= i2c_next_state;
    end
    always@(*) begin
        case(i2c_state)
            INIT:       i2c_next_state = start_received ? ADDR6 : INIT;
            RW_t:       i2c_next_state = (data_reg[7:1] == slave_addr) ? ((data_reg[0]==1'b0) ? ACK1 : ACK4) : WAIT;
            WAIT:       i2c_next_state = stop_received ? INIT : WAIT;
            ACK1:       i2c_next_state = REG_ADDR7;
            ACK2:       i2c_next_state = DATA7;
            DATA7:      i2c_next_state = (start_received) ? ADDR6 : ((stop_received) ? INIT : DATA6);
            ACK3:       i2c_next_state = DATA7;
            ACK4:       i2c_next_state = DATA_OUT7;
            DATA_OUT0:  i2c_next_state = NACK;
            NACK:       i2c_next_state = (data_reg[0]) ? WAIT:DATA_OUT7;
            default :   i2c_next_state = i2c_state + 1'd1;
        endcase
    end

    // SDA Output / ACK Handling
    reg SDA_output,SDA_input;
    reg[7:0] output_reg;
    wire SDA_control;
    assign SDA_control = ((i2c_state == ACK1)|(i2c_state == ACK2)|(i2c_state == ACK3)|(i2c_state == ACK4)|((i2c_state >= DATA_OUT7) & (i2c_state <= DATA_OUT0))) ? 1'b1:1'b0;
    assign SDA = (SDA_control) ? SDA_output : 1'bz;
    always@(*) SDA_input = (SDA_control) ? 1'b1 : SDA;
    always@(*) output_reg = data_memory[addr_reg];
    always@(*) begin
        case(i2c_state)
            ACK1:       SDA_output = 1'b0;
            ACK2:       SDA_output = 1'b0;
            ACK3:       SDA_output = 1'b0;
            ACK4:       SDA_output = 1'b0;
            DATA_OUT7:  SDA_output = output_reg[7];
            DATA_OUT6:  SDA_output = output_reg[6];
            DATA_OUT5:  SDA_output = output_reg[5];
            DATA_OUT4:  SDA_output = output_reg[4];
            DATA_OUT3:  SDA_output = output_reg[3];
            DATA_OUT2:  SDA_output = output_reg[2];
            DATA_OUT1:  SDA_output = output_reg[1];
            DATA_OUT0:  SDA_output = output_reg[0];
            default:    SDA_output = 1'b1;
        endcase
    end

    // DATA IO
    reg[7:0][7:0] data_memory;
    reg[7:0] addr_reg;
    wire acquire_data_address;

    always@(posedge rst) data_memory <= 64'h0;
    assign acquire_data_address = (i2c_state == ACK2)|(i2c_state == DATA7)|(i2c_state == NACK) ? 1'b1 : 1'b0;
    always@(posedge acquire_data_address or posedge rst) begin
        if(rst) addr_reg <= 8'd0;
        else addr_reg <= (i2c_state == ACK2) ? data_reg : (i2c_state == DATA7)|(i2c_state == NACK) ? addr_reg+7'h1 : addr_reg;
    end

    always@(*) data_memory[addr_reg] = (i2c_state == DATA0) ? data_reg :data_memory[addr_reg];

endmodule