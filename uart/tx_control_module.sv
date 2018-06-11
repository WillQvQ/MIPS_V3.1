`timescale 1ns / 1ps

module tx_control_module(
    input    logic    clk, rst_n,
    input     logic    tx_sig,
    input     logic    [7:0] tx_data,
    output    logic    tx_pin_out
);

logic bps_clk;
logic [3:0]i;
logic count_sig;

always@(posedge clk,negedge rst_n)
if(!rst_n)
    begin
        i <= 4'd0;
        tx_pin_out <= 1'b1;
        count_sig <= 1'b0;
    
    end
else 
    case(i)
        4'd0:if(tx_sig) begin i <= i + 1'b1;count_sig <= 1'b1; end
        4'd1:if(bps_clk) begin i <= i + 1'b1;tx_pin_out <= 1'b0;end
        4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8,4'd9:
                if(bps_clk) begin i <= i + 1'b1;tx_pin_out <= tx_data[i-2];end

        4'd10:if(bps_clk) begin i <= i + 1'b1;tx_pin_out <= 1'b1;end
        4'd11:if(bps_clk) begin i <= i + 1'b1;tx_pin_out <= 1'b1;end
        4'd12:if(bps_clk)begin i <= 1'b0;count_sig <= 1'b0;end
    
    endcase

bps_module bps_module(clk,rst_n,count_sig,bps_clk);

endmodule
