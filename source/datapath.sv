`timescale 1ns / 1ps

module datapath #(parameter N = 64, W = 32, I = 16 ,B = 8)(
    input   logic       clk, reset,
    input   logic       pcen, irwrite,
    input   logic       regwrite, dtype,
    input   logic       iord, memtoreg, regdst, alusrca, 
    input   logic [2:0] alusrcb,
    input   logic [1:0] pcsrc,
    input   logic [3:0] alucontrol,
    input   logic [1:0] ltype,
    output  logic [5:0] op, funct,
    output  logic       zero,
    output  logic [N-1:0]dataadr,
    output  logic [N-1:0]writedata,
    input   logic [N-1:0]readdata,
    output  logic [7:0]  pclow,
    input   logic [4:0]  checka,
    output  logic [N-1:0]check
);
    logic [4:0]     writereg;
    logic [N-1:0]   pcnext, pc;
    logic [W-1:0]   instr;
    logic [N-1:0]   data, srca, srcb;
    logic [N-1:0]   rda;
    logic [N-1:0]   aluresult, aluout;
    logic [N-1:0]   signimm; 
    logic [N-1:0]   zeroimm; 
    logic [N-1:0]   signimmsh; 
    logic [N-1:0]   wd3, rd1, rd2;
    logic [N-1:0]   memdata, mbytezext, mbytesext; 
    logic [B-1:0]   mbyte;
    assign op = instr[31:26];
    assign funct = instr[5:0];
    assign pclow = pc[9:2];
    flopenr #(N)    pcreg(clk, reset, pcen, pcnext, pc);
    mux2 #(N)       adrmux(pc, aluout, iord, dataadr);
    flopenr #(W)    instrreg(clk, reset, irwrite, readdata[W-1:0], instr);
    mux4 #(B)       lbmux(readdata[31:24], readdata[23:16], readdata[15:8],
                        readdata[7:0], aluout[1:0], mbyte);
    zeroext #(B,N)  lbze(mbyte, mbytezext);
    signext #(B,N)  lbse(mbyte, mbytesext);
    mux3 #(N)       datamux(readdata, mbytezext, mbytesext, ltype, memdata);
    flopr #(N)      datareg(clk, reset, memdata, data);
    mux2 #(5)       regdstmux(instr[20:16],instr[15:11], regdst, writereg);
    mux2 #(N)       wdmux(aluout, data, memtoreg, wd3);
    regfile#(N,32)  regfile(clk, regwrite, instr[25:21], instr[20:16],
                        writereg, wd3, rd1, rd2, checka, check);
    flopr #(N)      rdareg(clk, reset, rd1, rda);
    flopr #(N)      wdreg(clk, reset, rd2, writedata);
    signext#(I,N)   signext(instr[15:0], signimm);
    zeroext#(I,N)   zeroext(instr[15:0], zeroimm);
    sl2 #(N)        immsh(signimm, signimmsh);
    mux2 #(N)       srcamux(pc, rda, alusrca, srca);
    mux5 #(N)       srcbmux(writedata, 64'b100, signimm, signimmsh, zeroimm, alusrcb, srcb);
    alu #(N)        alu64(srca, srcb, alucontrol, aluresult, zero);
    flopr #(N)      alureg(clk, reset, aluresult, aluout);
    mux3 #(N)       pcmux(aluresult, aluout, {32'b0,pc[31:28], instr[25:0], 2'b00},pcsrc, pcnext);
endmodule
