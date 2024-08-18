module i2c(input clk,
    input SCL,
    inout SDA,
    input rstn,
	 output[5:0] debug
	 );
	 
	 i2c_slave slave0(clk,SCL,SDA,7'h22,~rstn);
	 //i2c_test test(clk, ~rstn, SDA,SCL,state);
endmodule