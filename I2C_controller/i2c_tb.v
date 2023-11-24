`timescale 1ns/1ns

`include "i2c_slave.v"

module tb_top();
    
    reg SCL,SDA_r,rst,enable,clk;
    always #5 SCL <= ~SCL;
    always #1 clk <= ~clk;
    assign SDA = (enable) ? SDA_r : 1'bz;
    
    task SEND_START(input[6:0] addr,input RW);
        begin
            #4; SDA_r = 0; #6;      // START
            SDA_r = addr[6]; #10;     // ADDR6
            SDA_r = addr[5]; #10;     // ADDR5
            SDA_r = addr[4]; #10;     // ADDR4
            SDA_r = addr[3]; #10;     // ADDR3
            SDA_r = addr[2]; #10;     // ADDR2
            SDA_r = addr[1]; #10;     // ADDR1
            SDA_r = addr[0]; #10;     // ADDR0
            SDA_r = RW; #10;     // RW
            enable = 1'b0; SDA_r = 1'b1; #10;enable = 1'b1;
        end
    endtask

    task SEND_REG_ADDR(input[7:0] addr);
        begin
            SDA_r = addr[7]; #10;     // ADDR7
            SDA_r = addr[6]; #10;     // ADDR6
            SDA_r = addr[5]; #10;     // ADDR5
            SDA_r = addr[4]; #10;     // ADDR4
            SDA_r = addr[3]; #10;     // ADDR3
            SDA_r = addr[2]; #10;     // ADDR2
            SDA_r = addr[1]; #10;     // ADDR1
            SDA_r = addr[0]; #10;     // ADDR0
            enable = 1'b0; SDA_r = 1'b1; #10;enable = 1'b1;
        end
    endtask

    task SEND_BYTE_DATA(input[7:0] addr);
        begin
            SDA_r = addr[7]; #10;     // DATA
            SDA_r = addr[6]; #10;     // DATA
            SDA_r = addr[5]; #10;     // DATA
            SDA_r = addr[4]; #10;     // DATA
            SDA_r = addr[3]; #10;     // DATA
            SDA_r = addr[2]; #10;     // DATA
            SDA_r = addr[1]; #10;     // DATA
            SDA_r = addr[0]; #10;     // DATA
            enable = 1'b0; SDA_r = 1'b1; #10;enable = 1'b1;
        end
    endtask

    task SEND_STOP();
        begin
            SDA_r = 0; #3;
            SDA_r = 1; #7;
        end
    endtask

    initial begin
        $dumpfile("tb_wave.vcd");
        $dumpvars(0, tb_top);
        rst = 1; SCL = 1'b1; clk=1'b1; SDA_r = 1; enable = 0; #7;
        rst = 0; enable = 1; #12;

        SEND_START(6'h11,1'b0);
        SEND_REG_ADDR(8'h0);
        SEND_BYTE_DATA(8'h1);
        SEND_BYTE_DATA(8'h2);
        SEND_BYTE_DATA(8'h3);
        SEND_BYTE_DATA(8'h4);
        SEND_BYTE_DATA(8'h5);
        SEND_BYTE_DATA(8'h6);
        SEND_BYTE_DATA(8'h7);
        SEND_BYTE_DATA(8'h8);
        SEND_STOP();
        #100;
        SEND_START(6'h11,1'b0);
        SEND_REG_ADDR(8'h5);
        SEND_START(6'h11,1'b1);
        //SEND_REG_ADDR(8'h0);
        enable = 0;#100;
        $finish;
    end

    I2C_Slave slave0(clk,SCL,SDA,7'h11,8'h00,rst);

endmodule