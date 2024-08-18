`include "mips_cpu.v"
`timescale 1ns/1ps

module MIPS_TB();

    reg clk,reset;
    initial clk <= 1'b0;
    always #5 clk <= ~clk;

    initial begin
        $dumpfile("mips_cpu_tb.vcd");
        $dumpvars(0,MIPS_TB);
        #10000;
        $finish;
    end

    mips_single_cycle_cpu CPU(clk);

endmodule