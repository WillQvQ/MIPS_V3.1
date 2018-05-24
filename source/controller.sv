`timescale 1ns / 1ps

module controller(
    input   logic       clk, reset,
    input   logic [5:0] op, funct,
    input   logic       FlushE,
    output  logic       dtype,
    output  logic       regdstE, regwriteE,regwriteM,regwriteW, 
    output  logic       memtoregE,memtoregM,memtoregW,
    output  logic [1:0] memwriteM,
    output  logic [1:0] alusrcE,
    output  logic [3:0] alucontrolE,
    output  logic       bneD,branchD,jumpD
); 
    logic [2:0] aluopD;
    logic [1:0] memwriteD,memwriteE;
    logic       memtoregD,memtoregE,memtoregM,memtoregW;
    logic       regwriteD,regdstD;
    logic [1:0] alusrcD;
    logic [3:0] alucontrolD;
    assign dtype = 1'b0;//should be modified for B/W/D
    maindec maindec(clk, reset, op,
                    regwriteD,memtoregD, regdstD, memwriteD,
                    alusrcD, bneD, branchD, jumpD, aluopD);
    aludec aludec(funct, aluopD, alucontrolD);

    
    flopcr#(11)     regD2E(clk,reset,FlushE,//1+1+2+4+2+1 = 11
                        {regwriteD,memtoregD,memwriteD,alucontrolD,alusrcD,regdstD},
                        {regwriteE,memtoregE,memwriteE,alucontrolE,alusrcE,regdstE});
    flopr #(4)      regE2M(clk,reset,{regwriteE,memtoregE,memwriteE},
                                     {regwriteM,memtoregM,memwriteM});      
    flopr #(2)      regM2W(clk,reset,{regwriteM,memtoregM},
                                     {regwriteW,memtoregW});
endmodule