`include "data_memory.v"
`timescale 1ns/1ps

module data_memory_tb_top();

    reg clk, we;
    reg[31:0] addr, wd;
    wire[31:0 ]rd;
    always #5 clk <= ~clk;
    
    initial begin
        $dumpfile("data_memory_tb_top.vcd");
        $dumpvars(0,data_memory_tb_top);
        clk <= 1'b0;
        addr  <= 32'd0;
        wd <= 32'd0;
        we <= 1'b0; 

        #4; we <= 1'b1; addr <= 32'd8; wd <= 32'd10;
        #14; we <= 1'd0;
        #1000;
        $finish();
    end


    data_memory dm(clk, addr, wd, we, rd);

endmodule