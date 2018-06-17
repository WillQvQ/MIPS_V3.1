`timescale 1ns / 1ps

module zeroext#(parameter PART = 16, ALL = 32)(
    input   logic [PART-1:0]    ze_a,
    output  logic [ALL-1:0]  ze_y
);
    assign  ze_y = {{(ALL-PART){1'b0}},ze_a};
endmodule
