`timescale 1ns / 1ps

module mux2#(parameter WIDTH = 32)(
    input [WIDTH-1:0]   mux2_d0,mux2_d1,
    input               mux2_s,
    output [WIDTH-1:0]  mux2_y
);
    assign  mux2_y = mux2_s ? mux2_d1 : mux2_d0;
endmodule
