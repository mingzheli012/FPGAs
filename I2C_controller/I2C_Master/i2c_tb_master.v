`timescale 1ns/1ns

//`include "../I2C_Salve/i2c_slave.v"
//`include "i2c_master.v"

module master_tb_top();

    wire SCL,SDA;
    reg clk,start_tx,rst;

    always #10 clk <= ~clk;  // 50MHz Clock --> 20ns
    initial begin
        $dumpfile("tb_wave.vcd");
        $dumpvars(0, master_tb_top);
        clk = 1'b0; rst = 1'b1; start_tx = 1'b0; #10; 
        rst = 1'b0; #13;
        
        start_tx = 1'b1; # 100; start_tx = 1'b0;
        #500000;
        $finish;
    end

    wire[7:0] data_o;
    i2c_master master(  clk,SCL,SDA,7'h11,8'h00, 8'hAA, start_tx, 1'b0, data_o, rst);
    i2c_slave slave0(   clk,SCL,SDA,7'h11,rst);

endmodule