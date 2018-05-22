`timescale 1ns / 1ps


module maindec(
    input   logic       clk, reset,   
    input   logic [5:0] op,
    output  logic       pcwrite, 
    output  logic [1:0] memwrite, 
    output  logic       irwrite, regwrite, dtype,
    output  logic       branch, iord, memtoreg, regdst, alusrca, 
    output  logic [2:0] alusrcb,
    output  logic [1:0] pcsrc,
    output  logic [2:0] aluop,
    output  logic       bne, 
    output  logic [1:0] ltype,
    output  logic [4:0] stateshow
); 
    typedef enum logic [4:0] {IF, ID, EX_LS, MEM_LW, WB_L, 
            MEM_SW, EX_RTYPE, WB_RTYPE, EX_BEQ, EX_ADDI, EX_J,
            EX_ANDI, EX_BNE, MEM_LBU, MEM_LB, EX_ORI, EX_SLTI,
            MEM_SB, WB_I, MEM_LD, MEM_SD, EX_DADDI} statetype;
    statetype state, nextstate;
    assign stateshow = state;
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
    logic [21:0] controls; 
    always_ff @(posedge clk or posedge reset) begin
        $display("State is %d",state);
        if(reset) state <= IF;
        else state <= nextstate;
    end
    always_comb
        case(state)
            IF: nextstate <= ID;
            ID: case(op)
                SD:     nextstate <= EX_LS;
                SW:     nextstate <= EX_LS;
                SB:     nextstate <= EX_LS;
                LD:     nextstate <= EX_LS;
                LW:     nextstate <= EX_LS;
                LB:     nextstate <= EX_LS; 
                LBU:    nextstate <= EX_LS; 
                RTYPE:  nextstate <= EX_RTYPE;
                J:      nextstate <= EX_J;
                BNE:    nextstate <= EX_BNE;
                BEQ:    nextstate <= EX_BEQ;
                ADDI:   nextstate <= EX_ADDI;
                ANDI:   nextstate <= EX_ANDI;
                ORI:    nextstate <= EX_ORI; 
                SLTI:   nextstate <= EX_SLTI;
                DADDI:  nextstate <= EX_DADDI; 
                default:nextstate <= IF;
            endcase
            EX_LS: case(op)
                SD:     nextstate <= MEM_SD;
                SW:     nextstate <= MEM_SW;
                SB:     nextstate <= MEM_SB;
                LD:     nextstate <= MEM_LD;
                LW:     nextstate <= MEM_LW;
                LBU:    nextstate <= MEM_LBU; 
                LB:     nextstate <= MEM_LB;
                default:nextstate <= IF;
            endcase
            MEM_LD:     nextstate <= WB_L;
            MEM_LW:     nextstate <= WB_L;
            MEM_LBU:    nextstate <= WB_L;
            MEM_LB:     nextstate <= WB_L;
            MEM_SD:     nextstate <= IF;
            MEM_SW:     nextstate <= IF;
            MEM_SB:     nextstate <= IF;
            WB_L:       nextstate <= IF;
            EX_RTYPE:   nextstate <= WB_RTYPE;
            WB_RTYPE:   nextstate <= IF;
            EX_BEQ:     nextstate <= IF;
            EX_BNE:     nextstate <= IF;
            EX_J:       nextstate <= IF;
            EX_ADDI:    nextstate <= WB_I;
            EX_ANDI:    nextstate <= WB_I; 
            EX_ORI:     nextstate <= WB_I;
            EX_SLTI:    nextstate <= WB_I;
            EX_DADDI:   nextstate <= WB_I;
            WB_I:       nextstate <= IF; 
            default:    nextstate <= IF;
        endcase
    assign {memwrite, pcwrite, irwrite, regwrite,
            alusrca, branch, iord, memtoreg, regdst,
            bne, alusrcb, pcsrc, aluop, ltype, dtype} = controls; 
    always_comb
        case(state)
            IF:         controls <= 22'b00_110_00000_0_001_00_000_000;
            ID:         controls <= 22'b00_000_00000_0_011_00_000_000;
            EX_LS:      controls <= 22'b00_000_10000_0_010_00_000_000;
            MEM_LD:     controls <= 22'b00_000_00100_0_000_00_000_001;
            MEM_LW:     controls <= 22'b00_000_00100_0_000_00_000_000;
            MEM_LB:     controls <= 22'b00_000_00100_0_000_00_000_100;
            MEM_LBU:    controls <= 22'b00_000_00100_0_000_00_000_010;
            WB_L:       controls <= 22'b00_001_00010_0_000_00_000_000;
            MEM_SD:     controls <= 22'b11_000_00100_0_000_00_000_000;
            MEM_SW:     controls <= 22'b01_000_00100_0_000_00_000_000;
            MEM_SB:     controls <= 22'b10_000_00100_0_000_00_000_000;
            EX_RTYPE:   controls <= 22'b00_000_10000_0_000_00_010_000;
            WB_RTYPE:   controls <= 22'b00_001_00001_0_000_00_000_000;
            EX_BEQ:     controls <= 22'b00_000_11000_0_000_01_001_000;
            EX_BNE:     controls <= 22'b00_000_10000_1_000_01_001_000;
            EX_J:       controls <= 22'b00_100_00000_0_000_10_000_000;
            EX_ADDI:    controls <= 22'b00_000_10000_0_010_00_000_000;
            EX_ANDI:    controls <= 22'b00_000_10000_0_100_00_011_000; 
            EX_ORI:     controls <= 22'b00_000_10000_0_100_00_100_000; 
            EX_SLTI:    controls <= 22'b00_000_10000_0_010_00_101_000; 
            EX_DADDI:   controls <= 22'b00_000_10000_0_010_00_110_000; 
            WB_I:       controls <= 22'b00_001_00000_0_000_00_000_000;
            default:    controls <= 22'b00_000_xxxxx_x_xxx_xx_xxx_xxx;
        endcase
endmodule