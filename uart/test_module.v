`timescale 1ns / 1ps

module test_module(
	clk,rst_n,
	rx_pin_in,h2l_sig
);

input clk;
input rst_n;
input rx_pin_in;
output h2l_sig;

reg h2l_f1;
reg h2l_f2;

always@(posedge clk,negedge rst_n)
if(!rst_n)
	begin
		h2l_f1 <= 1'b1;
		h2l_f2 <= 1'b1;
	end
else
	begin
		h2l_f1 <= rx_pin_in;
		h2l_f2 <= h2l_f1;
	end
assign h2l_sig = h2l_f2 & !h2l_f1;


endmodule
