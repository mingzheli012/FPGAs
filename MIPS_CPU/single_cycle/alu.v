module alu(
    input[31:0] srcA,
    input[31:0] srcB,
    input[2:0] opcode,
    output[31:0] result,
    output zero_flag
);

/*
Op Code:
000 A && B
001 A || B
010 A + B
011 Not Used
100 A && B~
101 A || B~
110 A - B
111 SLT
*/

reg[31:0] result_reg;

always@(*) begin
    case(opcode)
    3'b000: result_reg = srcA & srcB;
    3'b001: result_reg = srcA | srcB;
    3'b010: result_reg = srcA + srcB;
    3'b100: result_reg = srcA & ~srcB;
    3'b101: result_reg = srcA | ~srcB;
    3'b110: result_reg = srcA - srcB;
    3'b111: result_reg = (srcA > srcB) ? 32'd1 : 32'd0;
    default: result_reg = 32'd0;
    endcase
end
assign result = result_reg;
assign zero_flag = (result == 32'd0);

endmodule