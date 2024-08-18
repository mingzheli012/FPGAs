module sign_extender (
    input[15:0] instr,
    output[31:0] SignImm
);
    assign SignImm = {{16{instr[15]}},instr[15:0]};
endmodule