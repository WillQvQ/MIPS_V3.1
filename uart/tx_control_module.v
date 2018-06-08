`timescale 1ns / 1ps

module tx_control_module(
	clk,rst_n,rx_done_sig,
	tx_data,bps_clk,
	tx_pin_out,count_sig
);

input clk;
input rst_n;
input rx_done_sig;
input [7:0] tx_data;
input bps_clk;

output tx_pin_out;
output count_sig;

reg [3:0]i;
reg rtx;
reg iscount;
//reg [7:0] Rtx_data;

always@(posedge clk,negedge rst_n)
if(!rst_n)
	begin
		i <= 4'd0;
		rtx <= 1'b1;
		iscount <= 1'b0;
	
	end
else 
	case(i)
		4'd0:if(rx_done_sig) begin i <= i + 1'b1;iscount <= 1'b1; end
		4'd1:if(bps_clk) begin i <= i + 1'b1;rtx <= 1'b0;end
		4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8,4'd9:
				if(bps_clk) begin i <= i + 1'b1;rtx <= tx_data[i-2];end

		4'd10:if(bps_clk) begin i <= i + 1'b1;rtx <= 1'b1;end
		4'd11:if(bps_clk) begin i <= i + 1'b1;rtx <= 1'b1;end
		4'd12:if(bps_clk)begin i <= 1'b0;iscount <= 1'b0;end
	
	endcase


assign tx_pin_out = rtx;
assign count_sig = iscount;

endmodule
