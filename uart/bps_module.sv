`timescale 1ns / 1ps

module bps_module(
    input    logic    clk, rst_n, count_sig,
    output   logic    bps_clk
);
logic [12:0] count_bps;

always@(posedge clk,negedge rst_n)
    if(!rst_n)
        count_bps <=13'd0;
    else if(count_bps ==13'd5207)
        count_bps <=13'd0;
    else if(count_sig)
        count_bps <= count_bps + 1'b1;
    else 
        count_bps <= 13'd0;
    
assign bps_clk = (count_bps == 13'd2604)?1'b1:1'b0;

endmodule
