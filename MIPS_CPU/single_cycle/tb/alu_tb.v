`include "alu.v"
`timescale 1ns/1ps

module alu_tb_top();

    reg[31:0] srcA;
    reg[31:0] srcB;
    reg[2:0] opcode;
    wire[31:0] result;
    wire zero_flag;
    
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0,alu_tb_top);
        srcA = 32'd0; srcB = 32'd0; opcode = 3'd0;
        
        // Random Test
        # 10; opcode = 3'd0; srcA = $urandom; srcB = $urandom; 
        # 10; opcode = 3'd1; srcA = $urandom; srcB = $urandom;
        # 10; opcode = 3'd2; srcA = $urandom; srcB = $urandom;
        # 10; opcode = 3'd4; srcA = $urandom; srcB = $urandom;
        # 10; opcode = 3'd3; srcA = $urandom; srcB = $urandom;
        # 10; opcode = 3'd6; srcA = $urandom; srcB = $urandom;
        # 10; opcode = 3'd7; srcA = $urandom; srcB = $urandom;

        $finish();
    end

    alu alu(srcA,srcB,opcode,result,zero_flag);

endmodule