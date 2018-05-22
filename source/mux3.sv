`timescale 1ns / 1ps

module mux3#(parameter WIDTH = 32)(
    input   logic [WIDTH-1:0]   mux3_d0,mux3_d1,mux3_d2,
    input   logic [1:0]         mux3_s,
    output  logic [WIDTH-1:0]   mux3_y
);
    assign mux3_y = mux3_s[1] ? mux3_d2 : (mux3_s[0] ? mux3_d1 : mux3_d0);
endmodule