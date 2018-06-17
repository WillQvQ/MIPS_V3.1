`timescale 1ns / 1ps

module simulation();
    logic clk;
    logic reset;
    
    logic [63:0]writedata, dataadr;
    logic [1:0] memwrite;
    logic [63:0]datapc;
    logic [63:0]readdata;
    logic [31:0] cnt;
    logic [7:0] pclow;
    logic [7:0] addr;
    logic [4:0] checka;
    logic [63:0]check;
    logic [31:0]memdata;
    logic [31:0]instradr,instr;
    logic [4:0] wreg;
    logic       we;
    logic [32:0]rx_check;
    logic [32:0]rx_checkh;
    logic [32:0]rx_checkl;
	logic [7:0] rx_data;
    top top(clk,reset,writedata,dataadr,memwrite,readdata,pclow,checka,check,addr,memdata,we,wreg,rx_data,rx_check,rx_checkh,rx_checkl);
    
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
            if (dataadr === 100 & writedata === 7)begin
                $display("Test-standard2 pass!");
                #100 $stop;
            end
            if (dataadr === 508 & writedata === 7)begin
                 $display("Test-power2 pass!");
                 #100 $stop;
            end            
            if (dataadr === 80 & writedata === 1)begin
                 $display("Test-loadstore pass!");
                 #100 $stop;
            end
            if (dataadr === 320 & writedata === 4950)begin
                $display("Test-more ends!");
                $display(cnt);
                #100 $stop;
            end
        end
        cnt = cnt + 1;
        if(cnt === 1580)begin
            $display("Some error occurs!");
            $stop;
        end
    end

endmodule  