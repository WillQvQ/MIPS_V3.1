`timescale 1ns / 1ps


module alu#(parameter N = 64)(
    input   logic [N-1:0] alu_a,alu_b,
    input   logic [3:0]   alu_control,
    output  logic [N-1:0] alu_y,
    output  logic         zero
);
    parameter S_OR = 3'b001;
    parameter S_AND = 3'b000;
    parameter S_PLUS = 3'b010;
    parameter S_UNUSED = 3'b011;
    parameter S_AND_NEG = 3'b100;
    parameter S_OR_NE = 3'b101;
    parameter S_MINUS = 3'b110;
    parameter S_STL = 3'b111;

    logic [31:0] alu_y32;
    logic [31:0] alu_a32;
    logic [31:0] alu_b32;
    assign alu_a32 = alu_a[31:0];
    assign alu_b32 = alu_b[31:0];

    always_comb begin
        if (alu_control[3]) begin
            case(alu_control[2:0])
                S_AND:      alu_y = alu_a & alu_b;
                S_OR:       alu_y = alu_a | alu_b;
                S_PLUS:     alu_y = alu_a + alu_b;
                S_AND_NEG:  alu_y = alu_a &~alu_b;
                S_OR_NE:    alu_y = alu_a |~alu_b;
                S_MINUS:    alu_y = alu_a - alu_b;
                S_STL:      alu_y = alu_a < alu_b;
                S_UNUSED:   alu_y = 0;
            endcase
        end
        else begin
            case(alu_control[2:0])
                S_AND:      alu_y32 = alu_a32 & alu_b32;
                S_OR:       alu_y32 = alu_a32 | alu_b32;
                S_PLUS:     alu_y32 = alu_a32 + alu_b32;
                S_AND_NEG:  alu_y32 = alu_a32 &~alu_b32;
                S_OR_NE:    alu_y32 = alu_a32 |~alu_b32;
                S_MINUS:    alu_y32 = alu_a32 - alu_b32;
                S_STL:      alu_y32 = alu_a32 < alu_b32;
                S_UNUSED:   alu_y32 = 0;
            endcase
            alu_y = {32'b0,alu_y32};
        end
    end
    assign zero = alu_y==0 ? 1 : 0;
endmodule