`include "alu.v"
`include "control_module.v"
`include "data_memory.v"
`include "instruction_memory.v"
`include "program_counter.v"
`include "register_file.v"
`include "sign_extender.v"


module mips_single_cycle_cpu(
    input clk,
    input reset
);

//For PC
wire[31:0] curr_PC, next_PC;

// For Instruction Memory
wire[31:0] im_addr, im_instr;

// For Register File
wire rf_we;
wire[4:0] rf_ra1, rf_ra2, rf_wa; 
wire[31:0] rf_rd1, rf_rd2, rf_wd;

// For Sign Extender
wire [15:0] se_instr;
wire [31:0] se_signimm;

// For ALU
wire[31:0] alu_srcA,alu_srcB,alu_out;
wire[2:0] alu_opcode;
wire alu_zero;

//For Data Memory
wire[31:0] dm_addr,dm_data_i, dm_data_o;
wire dm_we;

// Control Unit Output
wire MemtoReg,MemWrite,Branch,ALUSrc,RegDst,RegWrite;
wire[2:0] ALUCtl;

// Instruction Decoder
wire[5:0] opcode, funct; 
wire[4:0] rs,rt,rd,shamt;
wire[15:0] imm;
wire[24:0] addr;

assign opcode   = im_instr[31:26];              // MIPS OPCODE is always top 6bits
assign rs       = im_instr[25:21];              // R Type Instr Src A
assign rt       = im_instr[20:16];              // R Type Instr Src B
assign rd       = im_instr[15:11];              // R Type Instr Destination 
assign shamt    = im_instr[10:6];               // R Type Shift Amount
assign funct    = im_instr[5:0];                // R Type Instr Funct Field

assign im_addr = curr_PC;
assign rf_wa = (RegDst) ? rd : rt;
assign alu_srcB = (ALUSrc) ?  se_signimm : rf_rd2;
assign rf_wd = (MemtoReg) ? dm_data_o : alu_out; 
assign next_PC = (Branch & alu_zero) ? ({se_signimm[30:0],1'b0} + (curr_PC + 3'd4)):(curr_PC + 3'd4);
assign alu_opcode = ALUCtl;
assign rf_we = RegWrite;

program_counter     PC(clk,reset,next_PC,curr_PC);
instruction_memory  IM(im_addr,im_instr);
sign_extender       SE(se_instr,se_signimm);
register_file       RF(clk, rf_we, rf_ra1, rf_ra2, rf_wa, rf_wd,rf_rd1,rf_rd2);
alu                 ALU(alu_srcA,alu_srcB,alu_opcode,alu_out,alu_zero);
data_memory         DM(clk,dm_addr,dm_data_i,MemWrite,dm_data_o);
control_module      CM(opcode,funct,Mem2Reg,MemWrite,Branch,ALUCtl,ALUSrc,RegDest,RegWrite);
endmodule