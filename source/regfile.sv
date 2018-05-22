`timescale 1ns / 1ps

module regfile#(parameter N = 32, L = 32)(
    input   logic           clk,
    input   logic           we3,
    input   logic [4:0]     ra1, ra2, wa3,
    input   logic [N-1:0]   wd3,
    output  logic [N-1:0]   rd1, rd2,
    input   logic [4:0]     checka,
    output  logic [N-1:0]   check
);
    logic [N-1:0] rf[L-1:0];
    always_ff @(posedge clk)
        if (we3) begin
            $display("REG%d=%d",wa3,wd3);
            rf[wa3] <= wd3;
        end
    assign rd1 = (ra1 !=0) ? rf[ra1] : 0;
    assign rd2 = (ra2 !=0) ? rf[ra2] : 0;
    assign check = rf[checka];
endmodule
