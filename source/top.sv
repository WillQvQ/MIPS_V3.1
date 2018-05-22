`timescale 1ns / 1ps

module top#(parameter N = 64)(
    input   logic       clk, reset,
    output  logic[N-1:0]writedata, dataadr,
    output  logic [1:0] memwrite,
    output  logic[N-1:0]readdata,
    output  logic [7:0] pclow,
    input   logic [4:0] checkra,
    output  logic [N-1:0]checkr,
    input   logic [7:0] checkma,
    output  logic [31:0]checkm
);
    logic readtype;
    mips mips(clk,reset,dataadr,writedata,memwrite,readtype,readdata,pclow,checkra,checkr);
    mem mem(clk,readtype,memwrite,dataadr,writedata,readdata,checkma,checkm);

endmodule