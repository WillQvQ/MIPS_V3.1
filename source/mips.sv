`timescale 1ns / 1ps

module mips#(parameter N = 64)(
    input   logic       clk, reset,
    output  logic[N-1:0]dataadr, writedata,
    output  logic [1:0] memwrite,
    output  logic       dtype,
    input   logic[N-1:0]readdata,
    output  logic [7:0] pclow,
    output  logic [4:0] state,
    input   logic [4:0] checka,
    output  logic [N-1:0]check
);
    logic       iord, lbu;
    logic       memtoreg, regdst, regwrite, zero;  
    logic [1:0] alusrc;    
    logic [3:0] alucontrol;
    logic [1:0] ltype; 
    logic       branch,jump;        
    logic [5:0] op, funct;
    

    datapath datapath(clk, reset, op, funct, zero, branch, jump,
                        regwrite,memtoreg,memwrite,iord,dtype,
                        ltype, regdst,alusrc,alucontrol, dataadr,
                        writedata, readdata, pclow, checka,check);
    controller controller(clk, reset, op, funct, iord, dtype,
                        regwrite,memtoreg, memwrite, regdst,
                        alusrc,alucontrol, branch,jump);
endmodule