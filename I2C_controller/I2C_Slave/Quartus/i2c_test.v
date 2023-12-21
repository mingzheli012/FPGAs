
module i2c_test(input clk, input rst, inout SDA, input SCL, output[7:0] state);

	parameter slave_addr = 7'h12;

	reg[7:0] i2c_state, i2c_next_state		/* synthesis preserve */;
	parameter INIT=8'd0,ADDR6=8'd1,ADDR5=8'd2,ADDR4=8'd3,ADDR3=8'd4,ADDR2=8'd5,ADDR1=8'd6,ADDR0=8'd7;
	parameter RW_t=8'd8,ACK1=8'd9,WAIT=8'd10,REG_ADDR7=8'd11,REG_ADDR0=8'd18;
	parameter ACK2=8'd19,DATA7=8'd20,DATA6=8'd21,DATA0=8'd27,ACK3=8'd28,ACK4=8'd29;
	parameter DATA_OUT7=8'd30,DATA_OUT6=8'd31,DATA_OUT5=8'd32,DATA_OUT4=8'd33,DATA_OUT3=8'd34,DATA_OUT2=8'd35,DATA_OUT1=8'd36,DATA_OUT0=8'd37,NACK=8'd38;


	reg[1:0] prev_val;
	reg[1:0] compare_ready;
	always@(posedge clk or posedge rst) prev_val <= rst ? 2'd0 : {prev_val[0],SDA};
	always@(posedge clk or posedge rst) compare_ready <= rst? 2'b00 : (SCL) ? ((compare_ready == 2'b10) ? 2'b10 : compare_ready + 1'b1) : 2'b00;
	wire start_sign, stop_sign;
	assign start_sign = (compare_ready[1]) ? prev_val[1] & ~prev_val[0] : 1'b0;
	assign stop_sign = (compare_ready[1]) ? prev_val[0] & ~prev_val[1] : 1'b0;

	reg start_received, stop_received;
	always@(posedge start_sign or posedge SCL or posedge rst) start_received <= rst ? 1'b0 : (SCL) ? start_sign : 1'b0;
	always@(posedge stop_sign or posedge SCL or posedge rst) stop_received <= rst ? 1'b0 : (SCL) ? stop_sign : 1'b0;

	// I2C Data Register
	reg[7:0] data_reg		/* synthesis preserve */;
	always@(posedge SCL or posedge rst) data_reg <= (rst) ? 8'd0 : {data_reg[6:0],SDA};

	reg SDA_input;
	always@(posedge SCL) SDA_input <= SDA;
	
	// I2C FSM
	always@(negedge SCL or posedge rst) begin
	  if(rst) i2c_state <= INIT;
	  else i2c_state <= i2c_next_state;
	end
	
	always@(*) begin
	  case(i2c_state)
			INIT:       i2c_next_state = start_received ? ADDR6 : INIT;
			RW_t:       i2c_next_state = (data_reg[7:1] == slave_addr) ? ((SDA_input==1'b0) ? ACK1 : ACK4) : WAIT;
			WAIT:       i2c_next_state = stop_received ? INIT : WAIT;
			ACK1:       i2c_next_state = stop_received ? INIT : REG_ADDR7;
			ACK2:       i2c_next_state = stop_received ? INIT : DATA7;
			DATA7:      i2c_next_state = (start_received) ? ADDR6 : ((stop_received) ? INIT : DATA6);
			ACK3:       i2c_next_state = stop_received ? INIT : DATA7;
			ACK4:       i2c_next_state = stop_received ? INIT : DATA_OUT7;
			DATA_OUT0:  i2c_next_state = stop_received ? INIT : NACK;
			NACK:       i2c_next_state = stop_received ? INIT : (data_reg[0]) ? WAIT:DATA_OUT7;
			default :   i2c_next_state = stop_received ? INIT : i2c_state + 1'd1;
	  endcase
	end

	assign state = i2c_state;

endmodule
