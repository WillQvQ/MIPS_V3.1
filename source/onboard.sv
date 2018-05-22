`timescale 1ns / 1ps

module onboard(
    input   logic 	reset,clken,show,quick,
    input   logic 	CLK100MHZ,
    input   logic   [7:0]addr,
    output  logic 	[6:0]seg,
    output  logic 	[7:0]an,
    output  logic 	[7:0]clks
);
	logic clk,CLK380,CLK48,CLK04,CLK1_6,clkrun;

	logic [63:0]writedata64, dataadr64;
	logic [31:0]writedata, dataadr;
	logic [1:0] memwrite;
	logic [63:0]readdata64;
	logic [31:0]readdata;
	logic [2:0]cnt;
	logic [3:0]digit;   
	logic [31:0]data;   
	logic [31:0]datamem;
	logic [4:0] state;
	logic [31:0]showdata;
	logic [7:0] pclow;
	logic [4:0] stateout;
    logic [4:0] checka;
    logic [31:0]check;
    logic [63:0]check64;
	logic [31:0]memdata;
	clkdiv clkdiv(CLK100MHZ,CLK380,CLK48,CLK1_6,CLK0_4);
	assign writedata = writedata64[31:0];
	assign readdata = readdata64[31:0];
	assign dataadr = dataadr64[31:0];
	assign check = check64[31:0];
	assign checka = addr[4:0];
	assign clkrun = quick ? CLK1_6:CLK0_4;
	assign clk = clkrun & clken;
	top top(clk,reset,writedata64,dataadr64,memwrite,readdata64,pclow,checka,check64,addr,memdata);
	assign showdata = show ? memdata:{addr,check[7:0],pclow,3'b0,stateout};
	assign data = memwrite[0]?datamem:showdata;
	initial cnt=2'b0;
    initial datamem=32'b0;
    initial clks=8'b0;
    initial stateout=5'b0;
    initial state=5'b0;
    always@(posedge clk,posedge reset)
        begin
            if (reset)
                begin
                    clks <= 8'b0;
                    stateout <= 5'b0;
                end
            else
                begin 
                    clks <= clks + 1;
                    stateout <= state;
                end
        end
	always@(posedge CLK380)  
		begin  
			if (memwrite) begin
				datamem[31:28] = 14;
				datamem[27:24] = 14;
				datamem[23:16] = dataadr[9:2];
				datamem[15:0] = writedata[15:0];
			end
			an=8'b11111111;   
			an[cnt]=0;  
			case(cnt)   
				0:digit=data[3:0];
				1:digit=data[7:4];
				2:digit=data[11:8];
				3:digit=data[15:12];
				4:digit=data[19:16];
				5:digit=data[23:20];
				6:digit=data[27:24];
				7:digit=data[31:28];  
			endcase  
			case(digit)  
				0:seg=   7'b1000000;  
				1:seg=   7'b1111001;  
				2:seg=   7'b0100100;       
				3:seg=   7'b0110000;  
				4:seg=   7'b0011001;  
				5:seg=   7'b0010010;  
				6:seg=   7'b0000010;  
				7:seg=   7'b1111000;  
				8:seg=   7'b0000000;  
				9:seg=   7'b0010000;  
				10:seg=  7'b0001000;
				11:seg=  7'b0000011;
				12:seg=  7'b1000110;
				13:seg=  7'b0100001;
				14:seg=  7'b0000110;
				15:seg=  7'b0001110;
				default:seg=7'b1111110;  
			endcase 
			cnt <=cnt+1'b1; 
		end  

endmodule  