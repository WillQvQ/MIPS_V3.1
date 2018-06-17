`timescale 1ns / 1ps


module maindec(
    input   logic       clk, reset,   
    input   logic [5:0] op,
    output  logic       regwrite, memtoreg, regdst,
    output  logic [1:0] memwrite, 
    output  logic [1:0] alusrc,
    output  logic       bne, branch, jump,
    output  logic [2:0] aluop, readtype
); 
    parameter RTYPE = 6'b000000;
    parameter LD    = 6'b110111;
    parameter LWU   = 6'b100111;
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
    logic [15:0] controls;
    assign {regwrite,memtoreg,regdst, memwrite, alusrc,
            bne,branch,jump, aluop, readtype} = controls; 
    always_comb
        case (op)
            RTYPE:  controls <= 16'b101_00_00_000_111_000;
            SD:     controls <= 16'b000_11_01_000_000_000;
            SW:     controls <= 16'b000_01_01_000_000_000;
            SB:     controls <= 16'b000_10_01_000_000_000;
            LD:     controls <= 16'b110_00_01_000_000_100;
            LWU:    controls <= 16'b110_00_01_000_000_001;
            LW:     controls <= 16'b110_00_01_000_000_000;
            LBU:    controls <= 16'b110_00_01_000_000_011;
            LB:     controls <= 16'b110_00_01_000_000_010;
            ADDI:   controls <= 16'b100_00_01_000_000_000;
            ANDI:   controls <= 16'b100_00_10_000_001_000;
            ORI:    controls <= 16'b100_00_10_000_010_000;
            SLTI:   controls <= 16'b100_00_01_000_011_000;
            DADDI:  controls <= 16'b100_00_01_000_100_000;
            BEQ:    controls <= 16'b000_00_00_010_000_000;
            BNE:    controls <= 16'b000_00_00_110_000_000;
            J:      controls <= 16'b000_00_00_001_000_000;
        endcase
endmodule