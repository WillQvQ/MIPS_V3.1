`timescale 1ns / 1ps

module flopenr #(parameter WIDTH = 8)(
    input   logic               clk, reset, en,
    input   logic [WIDTH-1:0]   flopenr_d,
    output  logic [WIDTH-1:0]   flopenr_q
);
always_ff @(posedge clk, posedge reset)
    if (reset) flopenr_q <= 0;
    else if (en) flopenr_q <= flopenr_d;
endmodule