`timescale 1ns/1ns
//`include "i2c_slave.v"

module tb_top();
    
    reg SCL,SDA_r,rst,enable,clk;
    reg data_recv_enable;
    reg[7:0] data_received;
    //always #5 SCL <= ~SCL;
    always #1 clk <= ~clk;
    assign SDA = (enable) ? SDA_r : 1'bz;
    
    always@(posedge SCL or posedge rst) data_received <= (rst) ? 8'd0 : ~enable ? {data_received[6:0],SDA} : data_received;

    task SEND_START(input[6:0] addr,input RW);
        begin
            $display("Sending START Signal at ",$time);
            enable = 1'b1; SDA_r = 1'b1;
            #9; SDA_r = 0; #6;      // START
            SDA_r = addr[6]; #10;     // ADDR6
            SDA_r = addr[5]; #10;     // ADDR5
            SDA_r = addr[4]; #10;     // ADDR4
            SDA_r = addr[3]; #10;     // ADDR3
            SDA_r = addr[2]; #10;     // ADDR2
            SDA_r = addr[1]; #10;     // ADDR1
            SDA_r = addr[0]; #10;     // ADDR0
            SDA_r = RW; #5;     // RW
            enable = 1'b0; SDA_r = 1'b1; #10;
            enable = 1'b1; SDA_r = 1'b1;
        end
    endtask

    task SEND_START_AGAIN(input[6:0] addr,input RW);
        begin
            $display("Sending START Signal at ",$time);
            enable = 1'b1; SDA_r = 1'b1;
            #9; SDA_r = 0; #6;      // START
            SDA_r = addr[6]; #10;     // ADDR6
            SDA_r = addr[5]; #10;     // ADDR5
            SDA_r = addr[4]; #10;     // ADDR4
            SDA_r = addr[3]; #10;     // ADDR3
            SDA_r = addr[2]; #10;     // ADDR2
            SDA_r = addr[1]; #10;     // ADDR1
            SDA_r = addr[0]; #10;     // ADDR0
            SDA_r = RW; #5;     // RW
            enable = 1'b0; SDA_r = 1'b1; #10;
            enable = 1'b1; SDA_r = 1'b1;
        end
    endtask

    task SEND_REG_ADDR(input[7:0] addr);
        begin
            $display("Sending Register ", addr, " at ",$time);
            enable = 1'b1; SDA_r = 1'b1;
            SDA_r = addr[7]; #10;     // ADDR7
            SDA_r = addr[6]; #10;     // ADDR6
            SDA_r = addr[5]; #10;     // ADDR5
            SDA_r = addr[4]; #10;     // ADDR4
            SDA_r = addr[3]; #10;     // ADDR3
            SDA_r = addr[2]; #10;     // ADDR2
            SDA_r = addr[1]; #10;     // ADDR1
            SDA_r = addr[0]; #10;     // ADDR0
            enable = 1'b0; SDA_r = 1'b1; #10;enable = 1'b1; SDA_r = 1'b1;
        end
    endtask

    task SEND_BYTE_DATA(input[7:0] addr);
        begin
            enable = 1'b1; SDA_r = 1'b1;
            SDA_r = addr[7]; #10;     // DATA
            SDA_r = addr[6]; #10;     // DATA
            SDA_r = addr[5]; #10;     // DATA
            SDA_r = addr[4]; #10;     // DATA
            SDA_r = addr[3]; #10;     // DATA
            SDA_r = addr[2]; #10;     // DATA
            SDA_r = addr[1]; #10;     // DATA
            SDA_r = addr[0]; #10;     // DATA
            enable = 1'b0; SDA_r = 1'b1; #10;enable = 1'b1; SDA_r = 1'b1;
        end
    endtask

    task SEND_STOP();
        begin
            $display("Sending STOP Signal at ",$time);
            enable = 1'b1;SDA_r = 0; #8;
            SDA_r = 1; #2;
        end
    endtask

    task WAIT_DATA(input ACK);
        begin
            data_recv_enable = 1;
            enable = 0; SDA_r = 1'b1;#80;
            data_recv_enable = 0;
            enable = 1; SDA_r = ACK; #10;
        end
    endtask

    task REAL_WAVE();
        #0; SDA_r = 1; SCL = 1;
        #9198; SDA_r = 0; SCL = 1;
        #5000; SDA_r = 0; SCL = 0;
        #6082; SDA_r = 0; SCL = 1;
        #5084; SDA_r = 0; SCL = 0;
        #6082; SDA_r = 0; SCL = 1;
        #5166; SDA_r = 0; SCL = 0;
        #4083; SDA_r = 1; SCL = 0;
        #1917; SDA_r = 1; SCL = 1;
        #5083; SDA_r = 1; SCL = 0;
        #2499; SDA_r = 0; SCL = 0;
        #3500; SDA_r = 0; SCL = 1;
        #5166; SDA_r = 0; SCL = 0;
        #6000; SDA_r = 0; SCL = 1;
        #5083; SDA_r = 0; SCL = 0;
        #4166; SDA_r = 1; SCL = 0;
        #1833; SDA_r = 1; SCL = 1;
        #5083; SDA_r = 1; SCL = 0;
        #2499; SDA_r = 0; SCL = 0;
        #3584; SDA_r = 0; SCL = 1;
        #5083; SDA_r = 0; SCL = 0;
        #6082; SDA_r = 0; SCL = 1;
        #5167; SDA_r = 0; SCL = 0;
        #1749; SDA_r = 1; SCL = 0;
        #4749; SDA_r = 1; SCL = 1;
        #5083; SDA_r = 1; SCL = 0;
        #2500; SDA_r = 0; SCL = 0;
        #3500; SDA_r = 0; SCL = 1;
        #6916; SDA_r = 1; SCL = 1;
        #12582; SDA_r = 1; SCL = 1;
    endtask

    initial begin
        $dumpfile("tb_wave.vcd");
        $dumpvars(0, tb_top);
        rst = 1; SCL = 1'b1; clk=1'b1; SDA_r = 1; enable = 1; data_recv_enable = 0; #7;
        rst = 0; enable = 1; #8; //SDA_r = 1'b0;

        SEND_START(6'h12,1'b0);
        SEND_REG_ADDR(8'h00);

        SEND_BYTE_DATA(8'h00);
        SEND_BYTE_DATA(8'h11);
        SEND_BYTE_DATA(8'h22);
        SEND_BYTE_DATA(8'h33);
        SEND_BYTE_DATA(8'h44);
        SEND_BYTE_DATA(8'h55);
        SEND_BYTE_DATA(8'h66);
        SEND_BYTE_DATA(8'h77);
        SEND_STOP();
        
        //enable = 1; SDA_r = 1;
        SEND_START(6'h11,1'b0);
        SEND_REG_ADDR(8'h03);
        data_recv_enable = 1;
        SEND_START_AGAIN(6'h11,1'b1);
        WAIT_DATA(1'b0);
        WAIT_DATA(1'b0);
        WAIT_DATA(1'b1);
        SEND_STOP();#100;
        $finish;
    end


    i2c_slave slave0(clk,SCL,SDA,7'h12,rst);
    i2c_slave slave1(clk,SCL,SDA,7'h0F,rst);
endmodule