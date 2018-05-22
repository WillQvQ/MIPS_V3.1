`timescale 1ns / 1ps


module maindec(
    input   logic       clk, reset,   
    input   logic [5:0] op,
    output  logic       iord, 
    output  logic       regwrite, memtoreg, memwrite, regdst, 
    output  logic [1:0] alusrc,
    output  logic [1:0] pcsrc,
    output  logic [2:0] aluop
); 
    parameter RTYPE = 6'b000000;
    parameter LD    = 6'b110111;
    parameter LW    = 6'b100011;
    parameter LBU   = 6'b100100;
    parameter LB    = 6'b100000;
    parameter SD    = 6'b111111;
    parameter SW    = 6'b101011;
    parameter SB    = 6'b101000;
    parameter BEQ   = 6'b000100;
    parameter BNE   = 6'b000101;
    parameter J     = 6'b000010;
    parameter ADDI  = 6'b001000;
    parameter ANDI  = 6'b001100;
    parameter ORI   = 6'b001101;
    parameter SLTI  = 6'b001010;
    parameter DADDI = 6'b011000;
    logic [11:0] controls;
    assign {iord,regwrite,memtoreg, memwrite, regdst,
            alusrc, pcsrc, aluop} = controls; 
    always_comb
        case (op)
            RTYPE:  controls <= 12'b01001_00_00_010;
            SW:     controls <= 12'b00010_00_00_000;
        endcase
endmodule