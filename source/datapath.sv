`timescale 1ns / 1ps

module datapath #(parameter N = 64, W = 32, I = 16 ,B = 8)(
    input   logic       clk, reset,
    output  logic [5:0] op, funct,
    input   logic       bneD,branchD,jumpD,
    input   logic       regwriteE,regwriteM,regwriteW,
    input   logic       memtoregE,memtoregM,memtoregW,
    input   logic [2:0] readtypeM,
    input   logic       regdstE,
    input   logic [1:0] alusrcE,
    input   logic [3:0] alucontrolE,
    output  logic[N-1:0]dataadr,
    output  logic[N-1:0]writedata,
    input   logic[N-1:0]readdata,
    output  logic [31:0]instradr,
    input   logic [31:0]instrF,
    output  logic       FlushE,
    output  logic [7:0] pclow,
    input   logic [4:0] checka,
    output  logic[N-1:0]check,
    output logic  [4:0] writeregW
);
    logic           StallF,StallD,ForwardAD,ForwardBD,FlushD;
    logic [1:0]     ForwardAE,ForwardBE;
    logic [W-1:0]   pcnextF,pcF,pc4F,pc4D,pcbranchD;
    logic [W-1:0]   instrD;
    logic [4:0]     rsD,rtD,rdD,rsE,rtE,rdE;
    logic [N-1:0]   signimmD,zeroimmD,signimmE,zeroimmE;
    logic [N-1:0]   signbyteD,zerobyteD,signbyteE,zerobyteE;
    logic [W-1:0]   signimm4D;
    logic [B-1:0]   mbyte;
    logic [N-1:0]   mbytezext,mbytesext,mwordzext,mwordsext;
    logic [N-1:0]   writedataE,writedataM;
    logic [4:0]     writeregE,writeregM;
    logic [N-1:0]   readdataM,readdataW;
    logic [N-1:0]   aluoutE,aluoutM,aluoutW;
    logic [N-1:0]   resultW;
    logic [N-1:0]   srca1D,srcb1D,srca1E,srcb1E,srcaE,srcbE;
    logic           zero;
    logic [1:0]     pcsrcD;
    logic [N-1:0]   euqalAD,euqalBD;
    logic           equalD;
    assign instradr = pcF;
    hazardunit      hazardunit(clk,reset,branchD,rsD,rtD,rsE,rtE,
                            writeregE,writeregM,writeregW,
                            memtoregE,memtoregM,regwriteE,regwriteM,regwriteW,
                            StallF,StallD,FlushE,
                            ForwardAD,ForwardBD,ForwardAE,ForwardBE);
    //Stage F
    flopenr #(W)    pcreg(clk, reset, ~StallF, pcnextF, pcF);

    assign  pclow = pcF[9:2];
    
    adder   #(W)    pcplus4(pcF,32'b100,pc4F);
    mux3    #(W)    pcmux(pc4F,pcbranchD,{pc4D[31:28],instrD[25:0],2'b00},pcsrcD,pcnextF);
    flopencr#(64)   regF2D(clk,reset,~StallD,FlushD,//32+32=64
                        {instrF,pc4F},
                        {instrD,pc4D});
    //Stage D
    assign  op    = instrD[31:26];
    assign  funct = instrD[5:0];
    assign  rsD   = instrD[25:21];
    assign  rtD   = instrD[20:16];
    assign  rdD   = instrD[15:11];
    regfile#(N,32)  regfile(clk,regwriteW,rsD,rtD,writeregW,resultW,srca1D,srcb1D,checka,check);
    signext#(I,N)   signext(instrD[15:0],signimmD);
    zeroext#(I,N)   zeroext(instrD[15:0],zeroimmD);
    sl2     #(W)    sl2(signimmD[W-1:0],signimm4D);
    adder   #(W)    branchcalc(pcF,signimm4D,pcbranchD);
    mux2    #(N)    eq1mux(srca1D,aluoutM,ForwardAD,euqalAD);
    mux2    #(N)    eq2mux(srcb1D,aluoutM,ForwardBD,euqalBD);
    assign equalD = (euqalAD==euqalBD)^bneD;
    assign pcsrcD = {jumpD,branchD & equalD};
    assign FlushD = pcsrcD[0] | pcsrcD[1];
    flopcr#(271)    regD2E(clk,reset,FlushE,//64*264*2+5*3=256+15=271
                        {srca1D,srcb1D,signimmD,zeroimmD,rsD,rtD,rdD},
                        {srca1E,srcb1E,signimmE,zeroimmE,rsE,rtE,rdE});
    //Stage E
    mux3    #(N)    srcamux(srca1E,resultW,aluoutM,ForwardAE,srcaE);
    mux3    #(N)    wdmux(srcb1E,resultW,aluoutM,ForwardBE,writedataE);
    mux3    #(N)    srcbmux(writedataE,signimmE,zeroimmE,alusrcE,srcbE);
    mux2    #(5)    regdstmux(rtE, rdE, regdstE, writeregE);
    alu     #(N)    alu(srcaE,srcbE,alucontrolE,aluoutE,zero);
    flopr #(133)    regE2M(clk,reset,//64+64+5=128+5=133
                        {aluoutE,writedataE,writeregE},
                        {aluoutM,writedataM,writeregM});
                        
    //Stage M
    assign dataadr   =  aluoutM;
    assign writedata =  writedataM; 
    mux4 #(B)       lbmux(readdata[31:24], readdata[23:16], readdata[15:8],
                        readdata[7:0], dataadr[1:0], mbyte);
    zeroext #(B,N)  lbze(mbyte, mbytezext);
    signext #(B,N)  lbse(mbyte, mbytesext);
    zeroext #(W,N)  lwze(readdata[31:0], mwordzext);
    signext #(W,N)  lwse(readdata[31:0], mwordsext);
    mux5    #(N)    datamux(mwordsext,mwordzext,mbytesext,mbytezext,readdata,readtypeM,readdataM);
    flopr #(133)    regM2W(clk,reset,//64+64+5=133
                        {readdataM,aluoutM,writeregM},
                        {readdataW,aluoutW,writeregW});
    //Stage W
    mux2    #(N)    resultmux(aluoutW,readdataW,memtoregW,resultW);
endmodule
