`timescale 1ns / 1ps

module controller(
    input   logic       clk, reset,
    input   logic [5:0] op, funct,
    input   logic       iord,
    output  logic       dtype,
    output  logic       regwrite, memtoreg, memwrite, regdst,
    output  logic [1:0] alusrc,
    output  logic [3:0] alucontrol,
    output  logic [1:0] pcsrc
); 
    logic [2:0] aluop;
    assign dtype = 1'b0;
    maindec maindec(clk, reset, op, iord,
                    regwrite,memtoreg, memwrite, regdst,
                    alusrc, pcsrc, aluop);
    aludec aludec(funct, aluop, alucontrol);
endmodule