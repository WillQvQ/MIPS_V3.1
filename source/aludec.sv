`timescale 1ns / 1ps

module aludec(
    input   logic [5:0] funct,
    input   logic [2:0] aluop,
    output  logic [3:0] alucontrol
);
    always_comb
        case(aluop)
            3'b000: alucontrol <= 4'b0010; // ADDI
            3'b001: alucontrol <= 4'b0110; // SUBI
            3'b011: alucontrol <= 4'b0000; // ANDI
            3'b100: alucontrol <= 4'b0001; // ORI
            3'b101: alucontrol <= 4'b0111; // SLTI
            3'b110: alucontrol <= 4'b1111; // DADDI
            3'b010: case(funct) // RTYPE
                6'b100000: alucontrol <= 4'b0010; // ADD
                6'b100010: alucontrol <= 4'b0110; // SUB
                6'b100100: alucontrol <= 4'b0000; // AND
                6'b100101: alucontrol <= 4'b0001; // OR
                6'b101010: alucontrol <= 4'b0111; // SLT
                6'b101100: alucontrol <= 4'b1010; // DADD
                6'b101110: alucontrol <= 4'b1110; // DSUB
                default: alucontrol <= 4'bxxxx; 
            endcase
            default: alucontrol <= 3'bxxx; 
        endcase
endmodule