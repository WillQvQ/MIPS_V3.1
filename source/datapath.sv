`timescale 1ns / 1ps

module datapath #(parameter N = 64, W = 32, I = 16 ,B = 8)(
    input   logic       clk, reset,
    output  logic [5:0] op, funct,
    output  logic       zero,
    input   logic [1:0] pcsrc,
    input   logic       regwriteD,memtoregD,
    input   logic [1:0] memwriteD,
    input   logic       iord,
    input   logic       dtype,
    input   logic [1:0] ltype,
    input   logic       regdstD,
    input   logic [1:0] alusrcD,
    input   logic [3:0] alucontrolD,
    output  logic[N-1:0]dataadr,
    output  logic[N-1:0]writedata,
    input   logic[N-1:0]readdata,
    output  logic [7:0] pclow,
    input   logic [4:0] checka,
    output  logic[N-1:0]check
);
    logic           branchD, jumpD;
    logic           regwriteE,regwriteM,regwriteW;
    logic           memtoregE,memtoregM,memtoregW;
    logic           memwriteE,memwriteM;
    logic [1:0]     alusrcE;
    logic [3:0]     alucontrolE;
    logic           regdstE;
    logic           StallF,StallD,ForwardAD,ForwardBD,FlushE;
    logic [1:0]     ForwardAE,ForwardBE;
    assign StallF = 1'b1;
    assign StallD = 1'b1;
    assign ForwardAD = 1'b0;
    assign ForwardBD = 1'b0;
    assign FlushE = 1'b0;
    assign ForwardAE = 1'b0;
    assign ForwardBE = 1'b0;
    logic [W-1:0]   pcnextF,pcF,pc4F,pc4D,pcbranchD;
    logic [W-1:0]   instrD;
    logic [5:0]     rsD,rtD,rdD,rsE,rtE,rdE;
    logic [N-1:0]   signimmD,zeroimmD,signimmE,zeroimmE;
    logic [N-1:0]   signbyteD,zerobyteD,signbyteE,zerobyteE;
    logic [W-1:0]   signimm4D;
    logic [3:0]     mbyte;
    logic [N-1:0]   rd1,rd2;
    logic [N-1:0]   writedataE,writedataM;
    logic [4:0]     writeregE,writeregM,writeregW;
    logic [N-1:0]   readdataM,readdataW;
    logic [N-1:0]   aluoutE,aluoutM,aluoutW;
    logic [N-1:0]   resultW;
    logic [N-1:0]   srca1D,srcb1D,srca1E,srcb1E,srcaE,srcb2E,srcbE;
    logic           zero;
    assign dataadr= {32'b0,pcF};
    //Stage F
    flopenr #(W)    pcreg(clk, reset, StallF, pcnextF, pcF);
    assign  pclow = pcF[9:2];
    
    adder   #(W)    pcplus4(pcF,32'b100,pc4F);
    mux3    #(W)    pcmux(pc4F,pcbranchD,{pc4D[31:28],instrD[25:0],2'b00},pcsrc,pcnextF);
    flopencr#(64)   regF2D(clk,reset,StallD,1'b0,//32+32=64
                        {readdata[W-1:0],pc4F},
                        {instrD,pc4D});
    assign FlushD = pcsrc[0]|pcsrc[1];//not sure
    //Stage D
    assign  op    = instrD[31:26];
    assign  funct = instrD[5:0];
    assign  rsD   = instrD[25:21];
    assign  rtD   = instrD[20:16];
    assign  rdD   = instrD[15:11];
    regfile#(N,32)  regfile(clk,regwriteD,rsD,rtD,writeregW,resultW,rd1,rd2,checka,check);
    signext#(I,N)   signext(instrD[15:0],signimmD);
    zeroext#(I,N)   zeroext(instrD[15:0],zeroimmD);
    sl2     #(W)    sl2(signimmD[W-1:0],signimm4D);
    adder   #(W)    branchcalc(pcF,signimm4D,pcbranchD);
    mux2    #(N)    admux(rd1,aluoutM,ForwardAD,srca1D);
    mux2    #(N)    bdmux(rd2,aluoutM,ForwardBD,srcb1D);
    
    flopcr#(156)    regD2E(clk,reset,1'b0,//64*2+6*3+3+4+2+1=128+28=156
                        {srca1D,srcb1D,rsD,rtD,rdD,regwriteD,memtoregD,memwriteD[0],alucontrolD,alusrcD,regdstD},
                        {srca1E,srcb1E,rsE,rtE,rdE,regwriteE,memtoregE,memwriteE,alucontrolE,alusrcE,regdstE});
    //Stage E
    mux3    #(N)    srcamux(srca1E,resultW,aluoutM,ForwardAE,srcaE);
    mux3    #(N)    wdmux(srcb1E,resultW,aluoutM,ForwardBE,writedataE);
    mux3    #(N)    srcbmux(writedataE,signimm,zeroimm,alusrcE,srcbE);
    mux2    #(5)    regdstmux(rtE, rdE, regdstE, writeregE);
    alu     #(N)    alu(srcaE,srcbE,alucontrolE,aluoutE,zero);
    flopr #(136)    regE2M(clk,reset,//64+64+5+3=128+8=136
                        {aluoutE,writedataE,writeregE,regwriteE,memtoregE,memwriteE},
                        {aluoutM,writedataM,writeregM,regwriteM,memtoregM,memwriteM});
                        
    //Stage M
    assign writedata =  writedataM; 
    assign readdataM =  readdata;
    flopr #(135)    regM2W(clk,reset,//64+64+5+2=135
                        {readdataM,aluoutM,writeregM,regwriteM,memtoregM},
                        {readdataW,aluoutW,writeregW,regwriteW,memtoregW});
    //Stage W
    mux2    #(N)    resultmux(aluoutW,readdataW,memtoregW,resultW);
endmodule
