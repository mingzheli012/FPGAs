module program_counter(
    input clk,
    input reset,
    input[31:0] next,
    output[31:0] curr
);
    reg[31:0] curr_reg;
    assign curr = curr_reg;

    always @(posedge clk or posedge reset) curr_reg <= (reset) ? 32'b0 : next;
endmodule