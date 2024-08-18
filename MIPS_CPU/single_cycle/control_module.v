module control_module(
    input[5:0] opcode,
    input[5:0] funct,
    output Mem2Reg,         // 1 if Memory RD to Register WD
    output MemWrite,        // 1 if ALU Result to Memory
    output Branch,          // 1 if Branch Opcode
    output[2:0] alu_op,     // ALU Operation Code
    output ALUSrc,          // 1 if ALU Src is SignImm
    output RegDest,         // 1 if Rd, 0 if Rt
    output RegWrite        // 1 if Write to Register
    //output Jump,            // 1 if Jump
    //output inv,             // 1 if invert ALU result
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

R-Type Operation
    Name    OPCODE  FUNCT   Operation           Mem2Reg     MemWrite    Branch      alu_op      ALUSrc      RegDest     RegWrite    Jump
    add     0       0x20    rd = rs + rt        0           0           0           010         0           1               1       0   
    addu    0       0x21    rd = rs + rt        0           0           0           010         0           1               1       0
    and     0       0x24    rd = rs & rt        0           0           0           000         0           1               1       0
    jr      0       0x08    PC = rs             0           0           0           XXX         0           0               0       1
    nor     0       0x27    rd = ~(rs | rt)     0           0           0           001         0           1               1       0
    or      0       0x25    rd = rd | rt        0           0           0           001         0           1               1       0
    slt     0       0x2A    rd = (rs<rt)?1:0    0           0           0           111         0           1               1       0
    sltu    0       0x2B    rd = (rs<rt)?1:0    0           0           0           111         0           1               1       0
    sll     0       0x00    rd = rt << shamt    0           0           0                       0           1               1       0
    srl     0       0x02    rd = rt >> shamt    0           0           0                       0           1               1       0
    sub     0       0x22    rd = rs - rt        0           0           0           110         0           1               1       0
    subu    0       0x23    rd = rs - rt        0           0           0           110         0           1               1       0

I-Type Operation
    Name    OPCODE  FUNCT   Operation           Mem2Reg     MemWrite    Branch      alu_op      ALUSrc      RegDest     RegWrite    Jump
    addi    0x08    0x00    rt = rs + Imm       0           0           0           010         1           1           1           0
    addiu   0x09    0x00    rt = rs + Imm       0           0           0           010         1           1           1           0

J-Type Operation
    Name    OPCODE  FUNCT   Operation           Mem2Reg     MemWrite    Branch      alu_op      ALUSrc      RegDest     RegWrite    Jump


*/



assign Mem2Reg =    (opcode == 6'b100011) ? 1'b1:1'b0; 
assign MemWrite =   (opcode == 6'b101011) ? 1'b1:1'b0;
assign Branch =     (opcode == 6'b000100) ? 1'b1:1'b0;
assign ALUSrc =     (opcode == 6'b10x011) ? 1'b1:1'b0;
assign RegDest =    (opcode == 6'b000000) ? 1'b1:1'b0;
assign RegWrite =   ((opcode == 6'b000000)| (opcode == 6'b100011)) ? 1'b1:1'b0;
endmodule