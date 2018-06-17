`timescale 1ns / 1ps

module signext#(parameter PART = 16, ALL = 32)(
    input   logic [PART-1:0]    se_a,
    output  logic [ALL-1:0]  se_y
);
    assign  se_y = {{(ALL-PART){se_a[PART-1]}},se_a};
endmodule
