`timescale 1ns / 1ps

module mux5#(parameter WIDTH = 32)(
    input   logic [WIDTH-1:0]   mux5_d0,mux5_d1,mux5_d2,mux5_d3,mux5_d4,
    input   logic [2:0]         mux5_s,
    output  logic [WIDTH-1:0]   mux5_y
);
    always_comb begin
        case(mux5_s)
            3'b000: mux5_y <= mux5_d0;
            3'b001: mux5_y <= mux5_d1;
            3'b010: mux5_y <= mux5_d2;
            3'b011: mux5_y <= mux5_d3;
            3'b100: mux5_y <= mux5_d4;
            default:mux5_y <= mux5_d0;
        endcase
    end
endmodule