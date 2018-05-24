`timescale 1ns / 1ps

module simulation();
    logic clk;
    logic reset;
    logic [63:0]writedata, dataadr;
    logic [1:0] memwrite;
    logic [63:0]datapc;
    logic [63:0]readdata;
    logic [9:0] cnt;
    logic [7:0] pclow;
    logic [7:0] addr;
    logic [4:0] checka;
    logic [63:0]check;
    logic [31:0]memdata;
    logic [31:0]instradr,instr;
    top top(clk,reset,writedata,dataadr,memwrite,instradr,instr,readdata,pclow,checka,check,addr,memdata);
    
    initial begin
        cnt <= 7'b0;
        reset <= 1; #22; reset <= 0;
        end    
    always begin
        clk <= 1; #5 clk <= 0; #5;
    end
    always @(negedge clk) begin
        if (memwrite) begin
            $display("Write %d in %d",writedata,dataadr);
            if (dataadr === 84 & writedata === 7)begin
                $display("Test-standard2 pass!");
//                $stop;
            end
            if (dataadr === 128 & writedata === 7)begin
                 $display("Test-power2 pass!");
                 $stop;
            end            
            if (dataadr === 80 & writedata === 1)begin
                 $display("Test-loadstore pass!");
                 $stop;
            end
        end
        cnt = cnt + 1;
        if(cnt === 48)begin
            $display("Some error occurs!");
            $stop;
        end
    end

endmodule  