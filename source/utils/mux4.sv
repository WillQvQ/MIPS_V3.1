`timescale 1ns / 1ps

module mux4#(parameter WIDTH = 32)(
    input   logic [WIDTH-1:0]   mux4_d0,mux4_d1,mux4_d2,mux4_d3,
    input   logic [1:0]         mux4_s,
    output  logic [WIDTH-1:0]   mux4_y
);
    always_comb begin
        case(mux4_s)
            3'b00: mux4_y <= mux4_d0;
            3'b01: mux4_y <= mux4_d1;
            3'b10: mux4_y <= mux4_d2;
            3'b11: mux4_y <= mux4_d3;
        endcase
    end
endmodule