`timescale 1ns / 1ps

module rx_control_module(
	clk,rst_n,h2l_sig,
	rx_pin_in,bps_clk,
	count_sig,rx_data,rx_done_sig
);

input clk;
input rst_n;
input h2l_sig;

input rx_pin_in;
input bps_clk;
output count_sig;
output [7:0] rx_data;
output rx_done_sig;

reg [3:0]i;
reg [7:0] rdata;
reg iscount;
reg isdone;

always@(posedge clk,negedge rst_n)
if(!rst_n)
	begin
		i <= 4'd0;
		rdata <= 8'd0;
		iscount <= 1'b0;
		isdone <= 1'b0;
	end
else 
	case(i)
		4'd0:if(h2l_sig) begin i <= i + 1'b1;iscount <= 1'b1;end
		4'd1:if(bps_clk) begin i <= i + 1'b1;end
		4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8,4'd9:
				if(bps_clk) begin i <= i + 1'b1;rdata[i-2] <= rx_pin_in;end

		4'd10:if(bps_clk) begin i <= i + 1'b1;end
		4'd11:if(bps_clk) begin i <= i + 1'b1;end
		4'd12:begin i <= i + 1'b1;isdone <= 1'b1;iscount <= 1'b0;end
		4'd13:begin i <= 1'b0;isdone <= 1'b0;end
	
	endcase

assign count_sig = iscount;
assign rx_data = rdata;
assign rx_done_sig = isdone;

endmodule
