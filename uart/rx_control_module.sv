`timescale 1ns / 1ps

module rx_control_module(
    input     logic    clk, rst_n, h2l_sig,
    input     logic    rx_pin_in,
    output    logic    [7:0] rx_data,
    output    logic    rx_done_sig
);

logic [3:0]i;
logic count_sig;
logic bps_clk;

always@(posedge clk,negedge rst_n)
if(!rst_n)
    begin
        i <= 4'd0;
        rx_data <= 8'd0;
        count_sig <= 1'b0;
        rx_done_sig <= 1'b0;
    end
else 
    case(i)
        4'd0:if(h2l_sig) begin i <= i + 1'b1;count_sig <= 1'b1;end
        4'd1:if(bps_clk) begin i <= i + 1'b1;end
        4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8,4'd9:
                if(bps_clk) begin i <= i + 1'b1;rx_data[i-2] <= rx_pin_in;end

        4'd10:if(bps_clk) begin i <= i + 1'b1;end
        4'd11:if(bps_clk) begin i <= i + 1'b1;end
        4'd12:begin i <= i + 1'b1;rx_done_sig <= 1'b1;count_sig <= 1'b0;end
        4'd13:begin i <= 1'b0;rx_done_sig <= 1'b0;end
    
    endcase

bps_module bps_module(clk,rst_n,count_sig,bps_clk);

endmodule
