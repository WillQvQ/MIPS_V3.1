`timescale 1ns / 1ps

module top#(parameter N = 64)(
    input   logic           clk, reset,
    output  logic [N-1:0]   writedata, dataadr,
    output  logic [1:0]     memwrite,
    output  logic [N-1:0]   readdata,
    output  logic [7:0]     pclow,
    input   logic [4:0]     checkra,
    output  logic [N-1:0]   checkr,
    input   logic [7:0]     checkma,
    output  logic [31:0]    checkm,
    output  logic           regwriteW,
    output  logic [4:0]     writeregW,
    input   logic [7:0]     rx_data,
    output  logic [31:0]    rx_check,
    output  logic [31:0]    rx_checkh,
    output  logic [31:0]    rx_checkl
);
    logic dword;
    logic [31:0] instradr,instr;
    mips mips(clk,reset,dataadr,writedata,memwrite,instradr,instr,dword,readdata,pclow,checkra,checkr,regwriteW,writeregW);
    mem mem(clk,dword,memwrite,dataadr,writedata,instradr,instr,readdata,checkma,checkm,rx_data,rx_check,rx_checkh,rx_checkl);

endmodule