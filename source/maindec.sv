`timescale 1ns / 1ps


module maindec(
    input   logic       clk, reset,   
    input   logic [5:0] op,
    output  logic       regwrite, memtoreg, regdst,
    output  logic [1:0] memwrite, 
    output  logic [1:0] alusrc,
    output  logic       branch, jump,
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
    assign {regwrite,memtoreg, regdst, memwrite,
            alusrc, branch, jump, aluop} = controls; 
    always_comb
        case (op)
            RTYPE:  controls <= 12'b101_00_00_00_111;
            SW:     controls <= 12'b000_01_01_00_000;
            LW:     controls <= 12'b110_00_01_00_000;
            ADDI:   controls <= 12'b100_00_01_00_000;
            ANDI:   controls <= 12'b100_00_10_00_001;
            ORI:    controls <= 12'b100_00_10_00_010;
            SLTI:   controls <= 12'b100_00_10_00_011;
            BEQ:    controls <= 12'b000_00_00_10_000;
        endcase
endmodule