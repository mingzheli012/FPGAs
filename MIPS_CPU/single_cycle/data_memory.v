module data_memory (input clk,
                    input[31:0] addr,
                    input[31:0] wd,
                    input we,
                    output[31:0] rd);

    reg[31:0] data_mem[127:0], rd_r;
    always@(posedge clk) data_mem[addr] <= we ? wd : data_mem[addr];
    assign rd = rd_r;

endmodule