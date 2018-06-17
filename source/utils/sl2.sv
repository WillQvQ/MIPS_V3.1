`timescale 1ns / 1ps


module sl2#(parameter N = 32)(
    input   logic [N-1:0] sl2_a,
    output  logic [N-1:0] sl2_y
);
    assign sl2_y = {sl2_a[N-3:0],2'b00};
endmodule
