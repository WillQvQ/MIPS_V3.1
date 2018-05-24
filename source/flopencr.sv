`timescale 1ns / 1ps

module flopencr #(parameter WIDTH = 32)(
    input   logic               clk,reset,en,clr,
    input   logic [WIDTH-1:0]   flopr_d,
    output  logic [WIDTH-1:0]   flopr_q
);
    
    always_ff @(posedge clk, posedge reset) begin
        if(reset|clr)   flopr_q <= 0;
        else if(en)     flopr_q <= flopr_d;
    end
endmodule
