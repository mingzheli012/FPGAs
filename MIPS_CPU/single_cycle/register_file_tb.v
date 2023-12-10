`include "registers.v"
`timescale 1ns/1ps

module register_tb_top();

    reg clk, we;
    always #5 clk <= ~clk;
    always #20 wr_addr0_i <= wr_addr0_i + 1'b1;
    always #1 wr_data_i <= wr_data_i + 1'b1;

    reg[4:0] rd_addr0_i, rd_addr1_i, wr_addr0_i;
    wire[31:0] rd_data0_o,rd_data1_o;
    reg[31:0] wr_data_i;

    initial begin
        $dumpfile("register_file_tb.vcd");
        $dumpvars(0,register_tb_top);
        clk <= 1'b0;
        we <= 1'b1;
        wr_addr0_i <= 5'd0;
        wr_data_i <= 32'h0000_0000;

        wr_addr0_i <= 1'b1;
        #1000;
        $finish();
    end


    MIPS_registers register_file(clk,we,rd_addr0_i,rd_addr1_i,wr_addr0_i,wr_data_i,rd_data0_o,rd_data1_o);

endmodule