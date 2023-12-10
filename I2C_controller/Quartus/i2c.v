module i2c(input clk,
    input SCL,
    inout SDA,
    input rstn,
	 output reg slow_clk,
	 output scl_light);
	 
	 wire rst;
	 reg[8:0] clk_counter;
	 // reg slow_clk;
	 always@(posedge clk or posedge ~rstn) clk_counter <= (~rstn) ? 9'd0 : (clk_counter >= 9'd50) ? 9'd0 : clk_counter+1'b1;
	 always@(posedge clk or posedge ~rstn) slow_clk <= (~rstn) ? 1'b0 : (clk_counter == 9'd50) ? (~slow_clk) : slow_clk;
	 i2c_slave slave0(slow_clk,SCL,SDA,7'h12,~rstn);  
	 assign scl_light = SCL;
endmodule