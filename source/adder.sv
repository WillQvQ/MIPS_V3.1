`timescale 1ns / 1ps

module adder#(parameter N = 32)(
    input   logic [N-1:0]    adder_a, adder_b,
    output  logic [N-1:0]    adder_y
    );
assign  adder_y = adder_a + adder_b;
endmodule
