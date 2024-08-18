module register_file (
    input clk,
    input we,
    input [4:0] rd_addr0_i,
    input [4:0] rd_addr1_i,
    input [4:0] wr_addr0_i,
    input [31:0] wr_data_i,
    output [31:0] rd_data0_o,
    output [31:0] rd_data1_o
);
    reg[31:0][31:0] register_files;
    
    always@(posedge clk) begin
        register_files[0] <= 32'h0;                                                 // $0 register always set to 0
        register_files[wr_addr0_i] <= we ? wr_data_i : register_files[wr_addr0_i];
    end

    assign rd_data0_o = register_files[rd_addr0_i];
    assign rd_data1_o = register_files[rd_addr1_i];

endmodule