`timescale 1ns / 1ps

module mips#(parameter N = 64)(
    input   logic       clk, reset,
    output  logic[N-1:0]dataadr, writedata,
    output  logic [1:0] memwriteM,
    output  logic [31:0]instradr,
    input   logic [31:0]instr,
    output  logic       dtype,
    input   logic[N-1:0]readdata,
    output  logic [7:0] pclow,
    output  logic [4:0] state,
    input   logic [4:0] checka,
    output  logic [N-1:0]check
);
    logic       lbu;
    logic       memtoregE,memtoregM,memtoregW;  
    logic [1:0] alusrcE;    
    logic [3:0] alucontrolE;
    logic [1:0] ltype; 
    logic       bneD,branchD,jumpD;       
    logic       regdstE, regwriteE,regwriteM,regwriteW; 
    logic [5:0] op, funct;
    logic       FlushE;

    datapath datapath(clk, reset, op, funct, bneD, branchD, jumpD,
                        regwriteE, regwriteM, regwriteW,
                        memtoregE, memtoregM, memtoregW,
                        dtype, ltype, regdstE,
                        alusrcE,alucontrolE, dataadr,
                        writedata, readdata, instradr,instr,
                        FlushE, pclow, checka, check);
    controller controller(clk, reset, op, funct, FlushE, dtype,
                        regdstE, regwriteE,regwriteM,regwriteW,
                        memtoregE,memtoregM,memtoregW, memwriteM,
                        alusrcE, alucontrolE, bneD, branchD, jumpD);
endmodule