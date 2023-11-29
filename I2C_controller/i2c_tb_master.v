`timescale 1ns/1ns

`include "i2c_slave.v"
`include "i2c_master.v"

module tb_top();

    wire SCL,SDA;
    reg clk,start_tx,rst;

    always #10 clk <= ~clk;  // 50MHz Clock --> 20ns
    initial begin
        $dumpfile("tb_wave.vcd");
        $dumpvars(0, tb_top);
        clk = 1'b0; rst = 1'b1; start_tx = 1'b0; #10; 
        rst = 1'b0; #13;
        
        start_tx = 1'b1;
        #500000;
        $finish;
    end


    I2C_Master master(  clk,SCL,SDA,7'h11,8'h00,start_tx,rst);
    I2C_Slave slave0(   clk,SCL,SDA,7'h11,rst);

endmodule