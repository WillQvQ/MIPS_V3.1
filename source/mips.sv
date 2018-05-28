`timescale 1ns / 1ps

module mips#(parameter N = 64)(
    input   logic       clk, reset,
    output  logic[N-1:0]dataadr, writedata,
    output  logic [1:0] memwriteM,
    output  logic [31:0]instradr,
    input   logic [31:0]instr,
    output  logic       dword,
    input   logic[N-1:0]readdata,
    output  logic [7:0] pclow,
    input   logic [4:0] checka,
    output  logic [N-1:0]check,
    output  logic       regwriteW,
    output  logic [4:0] writeregW
);
    logic       lbu;
    logic       memtoregE,memtoregM,memtoregW;  
    logic [1:0] alusrcE;    
    logic [3:0] alucontrolE;
    logic       bneD,branchD,jumpD;       
    logic       regdstE, regwriteE,regwriteM; 
    logic [5:0] op, funct;
    logic       FlushE;
    logic [2:0] readtypeM;
    assign  dword = readtypeM[2];

    datapath datapath(clk, reset, op, funct, bneD, branchD, jumpD,
                        regwriteE, regwriteM, regwriteW,
                        memtoregE, memtoregM, memtoregW,
                        readtypeM, regdstE, 
                        alusrcE,alucontrolE, dataadr,
                        writedata, readdata, instradr,instr,
                        FlushE, pclow, checka, check, writeregW);
    controller controller(clk, reset, op, funct, FlushE,
                        regdstE, regwriteE,regwriteM,regwriteW,
                        memtoregE,memtoregM,memtoregW, memwriteM,
                        alusrcE, alucontrolE, bneD, branchD, jumpD, readtypeM);
endmodule