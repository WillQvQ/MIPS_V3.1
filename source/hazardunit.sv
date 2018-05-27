`timescale 1ns / 1ps

module hazardunit(
    input   logic       clk,reset,
    input   logic       branchD,
    input   logic [4:0] rsD,rtD,rsE,rtE,
    input   logic [4:0] writeregE,writeregM,writeregW,
    input   logic       memtoregE, memtoregM,regwriteE,regwriteM,regwriteW,
    output  logic       StallF,StallD,FlushE,
    output  logic       ForwardAD,ForwardBD,
    output  logic [1:0] ForwardAE,ForwardBE
);
    logic   lwStallD, branchStallD;
    assign ForwardAD = rsD !=0 & (rsD == writeregM) & regwriteM;
    assign ForwardBD = rtD !=0 & (rtD == writeregM) & regwriteM;
    always_comb begin
        ForwardAE = 2'b00; ForwardBE = 2'b00;
        if (rsE != 0)
            if (rsE == writeregM & regwriteM)
                ForwardAE = 2'b10;
            else if (rsE == writeregW & regwriteW)
                ForwardAE = 2'b01;
        if (rtE != 0)
            if (rtE == writeregM & regwriteM)
                ForwardBE = 2'b10;
            else if (rtE == writeregW & regwriteW)
                ForwardBE = 2'b01;
    end
    assign #1 lwStallD = memtoregE & (rtE == rsD | rtE == rtD);
    assign #1 branchStallD = branchD & (regwriteE & (writeregE == rsD | writeregE == rtD) | 
                                       memtoregM & (writeregM == rsD | writeregM == rtD));
    assign #1 StallD = lwStallD | branchStallD;
    assign #1 StallF = StallD;
    assign #1 FlushE = StallD;
endmodule