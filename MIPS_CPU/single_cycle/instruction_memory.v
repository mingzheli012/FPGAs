module instruction_memory (
    input[31:0] addr,
    output[31:0] instr
);

    wire[31:0] inst_mem[31:0];

    assign inst_mem[0] = 32'h014B4820;

    assign instr = inst_mem[addr];

endmodule