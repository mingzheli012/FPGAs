    /*
I2C Slave

Input:
    clk:            FPGA Base Clock (50MHz)
    SCL:            Serial Clock
    SDA:            Serial DATA
    slave_addr:     Slave Address
    rst:            Async Reset

Output:
    debug:          Debug Port for internal Signals
*/



module i2c_slave(
    input clk,
    input SCL,
    inout SDA,
    input[6:0] slave_addr,
    input rst,                       // Async Active High Reset
	 output[5:0] debug
);  

    // I2C State Def
    reg[38:0] i2c_state; wire[38:0] i2c_next_state		/* synthesis preserve */;
    parameter INIT=8'd0,ADDR6=8'd1,ADDR5=8'd2,ADDR4=8'd3,ADDR3=8'd4,ADDR2=8'd5,ADDR1=8'd6,ADDR0=8'd7,RW_t=8'd8,ACK1=8'd9,WAIT=8'd10,REG_ADDR7=8'd11,REG_ADDR6=8'd12,REG_ADDR5=8'd13,REG_ADDR4=8'd14,REG_ADDR3=8'd15,REG_ADDR2=8'd16,REG_ADDR1=8'd17,REG_ADDR0=8'd18,ACK2=8'd19,DATA7=8'd20,DATA6=8'd21,DATA5=8'd22,DATA4=8'd23,DATA3=8'd24,DATA2=8'd25,DATA1=8'd26,DATA0=8'd27,ACK3=8'd28,ACK4=8'd29,DATA_OUT7=8'd30,DATA_OUT6=8'd31,DATA_OUT5=8'd32,DATA_OUT4=8'd33,DATA_OUT3=8'd34,DATA_OUT2=8'd35,DATA_OUT1=8'd36,DATA_OUT0=8'd37,NACK=8'd38;
	 
    // DATA IO Def
    reg[7:0] data_memory [7:0]	    /* synthesis preserve */;
    reg[7:0] addr_reg				/* synthesis preserve */;
    wire acquire_data_address		/* synthesis preserve */;

    // I2C Data Register
    reg[7:0] data_reg;
    always@(posedge SCL or posedge rst) data_reg <= (rst) ? 8'd0 : {data_reg[6:0],SDA};

    // Output Register Loading
    reg[7:0] output_reg;
    always@(posedge i2c_state[ACK4]) output_reg <= data_memory[addr_reg];                               // When in ACK4 stage, load output register accordingly

    assign acquire_data_address = (i2c_state[ACK2])|(i2c_state[DATA7])|(i2c_state[NACK]) ? 1'b1 : 1'b0;
    always@(posedge acquire_data_address or posedge rst) begin
        if(rst) addr_reg <= 8'd0;
        else addr_reg <= (i2c_state[ACK2]) ? data_reg : (i2c_state[DATA7])|(i2c_state[NACK]) ? addr_reg+7'h1 : addr_reg;        // For multibyte address increment
    end
    always@(posedge i2c_state[ACK3]) data_memory[addr_reg] <= data_reg;

    // SDA Output / ACK Handling
    reg SDA_input; 
    always@(posedge SCL) SDA_input <= SDA;
    wire SDA_control, ACK_control, Data_control;
	assign SDA_control = ACK_control | Data_control;                                                    // Pull SDA to LOW when in ACK or DATA output
    assign ACK_control = (i2c_state[ACK1])|(i2c_state[ACK2])|(i2c_state[ACK3])|(i2c_state[ACK4]);
    assign Data_control = (i2c_state[DATA_OUT7]&~output_reg[7])|(i2c_state[DATA_OUT6]&~output_reg[6])|(i2c_state[DATA_OUT5]&~output_reg[5])|(i2c_state[DATA_OUT4]&~output_reg[4])|(i2c_state[DATA_OUT3]&~output_reg[3])|(i2c_state[DATA_OUT2]&~output_reg[2])|(i2c_state[DATA_OUT1]&~output_reg[1])|(i2c_state[DATA_OUT0]&~output_reg[0]);
    assign SDA = SDA_control ? 1'b0 : 1'bz;

    // Generation of START/STOP/Data Valid Signal
    reg prev_val, curr_val;                             // 2 Bits Shift Register to constantly scaning for SDA changes
    always@(posedge clk) curr_val <= SDA;
	always@(posedge clk) prev_val <= curr_val;
    
    wire start_sign, stop_sign;                         // Note: SDA has to be stablized 2 clock cycle before SCL rising edges to avoid incorrect trigger of START/STOP signal
    assign start_sign = prev_val & ~curr_val & SCL;     // When SCL is high, previous value = 1 but current value is 0, indicating a START signal
    assign stop_sign = ~prev_val & curr_val & SCL;      // When SCL is high, previous value = 0 but current value is 1, indicating a STOP signal


    /*
    When STOP Signal issued for bus idle, SCL will not have falling edge. Hence reset need to be able to detect new START signal 

        STOP Signal Issued       START Signal Issued
               ________________________
    SCL ______/                        \______
                       ____________
    SDA ______________/            \______________________
    */
    reg start_received, stop_received;
    always@(posedge SCL or posedge start_sign) start_received <= start_sign ? 1'b1: 1'b0;                                               // Use Trigger Latch to hold Start Signal until next rising edge of SCL
    always@(posedge SCL or posedge stop_sign or posedge start_sign) stop_received <= start_sign ? 1'b0 : stop_sign ? 1'b1: 1'b0;        // Use Trigger Latch to hold Stop Signal until next rising edge of SCL or new Start signal.
    	
    // I2C FSM
    always@(negedge (SCL) or posedge rst or posedge stop_received) begin
        if(rst) i2c_state <= 39'd1;
		else if(stop_received) i2c_state <= 39'd1;
        else i2c_state <= i2c_next_state;
    end

    assign i2c_next_state[INIT]         = i2c_state[INIT] & ~start_received;
    assign i2c_next_state[ADDR6]        = (i2c_state[INIT] & start_received) | (i2c_state[DATA7] & start_received);
    assign i2c_next_state[ADDR5]        = i2c_state[ADDR6];
    assign i2c_next_state[ADDR4]        = i2c_state[ADDR5];
    assign i2c_next_state[ADDR3]        = i2c_state[ADDR4];
    assign i2c_next_state[ADDR2]        = i2c_state[ADDR3];
    assign i2c_next_state[ADDR1]        = i2c_state[ADDR2];
    assign i2c_next_state[ADDR0]        = i2c_state[ADDR1];
    assign i2c_next_state[RW_t]         = i2c_state[ADDR0];
    assign i2c_next_state[ACK1]         = i2c_state[RW_t] & (data_reg[7:1] == slave_addr) & (SDA_input==1'b0);
    assign i2c_next_state[WAIT]         = (i2c_state[RW_t] & (data_reg[7:1] != slave_addr)) | (i2c_state[NACK] & (SDA_input==1'b0));
    assign i2c_next_state[ACK4]         = i2c_state[RW_t] & (data_reg[7:1] == slave_addr) & (SDA_input==1'b1);
    assign i2c_next_state[REG_ADDR7]    = i2c_state[ACK1];
    assign i2c_next_state[REG_ADDR6]    = i2c_state[REG_ADDR7];
    assign i2c_next_state[REG_ADDR5]    = i2c_state[REG_ADDR6];
    assign i2c_next_state[REG_ADDR4]    = i2c_state[REG_ADDR5];
    assign i2c_next_state[REG_ADDR3]    = i2c_state[REG_ADDR4];
    assign i2c_next_state[REG_ADDR2]    = i2c_state[REG_ADDR3];
    assign i2c_next_state[REG_ADDR1]    = i2c_state[REG_ADDR2];
    assign i2c_next_state[REG_ADDR0]    = i2c_state[REG_ADDR1];
    assign i2c_next_state[ACK2]         = i2c_state[REG_ADDR0];
    assign i2c_next_state[DATA7]        = i2c_state[ACK2];
    assign i2c_next_state[DATA6]        = i2c_state[DATA7] & (~start_received & ~stop_received);
    assign i2c_next_state[DATA5]        = i2c_state[DATA6];
    assign i2c_next_state[DATA4]        = i2c_state[DATA5];
    assign i2c_next_state[DATA3]        = i2c_state[DATA4];
    assign i2c_next_state[DATA2]        = i2c_state[DATA3];
    assign i2c_next_state[DATA1]        = i2c_state[DATA2];
    assign i2c_next_state[DATA0]        = i2c_state[DATA1];
    assign i2c_next_state[ACK3]         = i2c_state[DATA0];
    assign i2c_next_state[DATA_OUT7]    = i2c_state[ACK4] | (i2c_state[NACK] & (SDA_input == 1'b1));
    assign i2c_next_state[DATA_OUT6]    = i2c_state[DATA_OUT7];
    assign i2c_next_state[DATA_OUT5]    = i2c_state[DATA_OUT6];
    assign i2c_next_state[DATA_OUT4]    = i2c_state[DATA_OUT5];
    assign i2c_next_state[DATA_OUT3]    = i2c_state[DATA_OUT4];
    assign i2c_next_state[DATA_OUT2]    = i2c_state[DATA_OUT3];
    assign i2c_next_state[DATA_OUT1]    = i2c_state[DATA_OUT2];
    assign i2c_next_state[DATA_OUT0]    = i2c_state[DATA_OUT1];
    assign i2c_next_state[NACK]         = i2c_state[DATA_OUT0];

endmodule