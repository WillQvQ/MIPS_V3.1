`timescale 1ns / 1ps

module flopr #(parameter WIDTH = 32)(
    input   logic               clk,reset,
    input   logic [WIDTH-1:0]   flopr_d,
    output  logic [WIDTH-1:0]   flopr_q
);
    always_ff @(posedge clk, posedge reset) begin
        if(reset)   flopr_q <= 0;
        else        flopr_q <= flopr_d;
    end
endmodule
