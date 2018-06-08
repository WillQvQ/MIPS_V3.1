`timescale 1ns / 1ps

module uart_top(
	clk,rst_n,tx_pin_out,rx_pin_in  
);


input clk;
input rst_n;
input rx_pin_in;
output tx_pin_out;


wire clk_out;


  div_clk u1
   (// Clock in ports
    .CLK_IN1(clk),      // IN
    // Clock out ports
    .CLK_OUT1(clk_out));

wire h2l_sig;
test_module u2 (
    .clk(clk_out), 
    .rst_n(rst_n), 
    .rx_pin_in(rx_pin_in), 
    .h2l_sig(h2l_sig)
    );
wire bps_clk;
wire count_sig;
wire rx_done_sig;
wire [7:0] rx_data;
rx_control_module u3 (
    .clk(clk_out), 
    .rst_n(rst_n), 
    .h2l_sig(h2l_sig), 
    .rx_pin_in(rx_pin_in), 
    .bps_clk(bps_clk), 
    .count_sig(count_sig), 
    .rx_data(rx_data), 
    .rx_done_sig(rx_done_sig)
    );
wire bps_clk1;
wire count_sig1;

tx_control_module u4 (
    .clk(clk_out), 
    .rst_n(rst_n), 
    .rx_done_sig(rx_done_sig), 
    .tx_data(rx_data), 
    .bps_clk(bps_clk1), 
    .tx_pin_out(tx_pin_out), 
    .count_sig(count_sig1)
    );


bps_module u5 (
    .clk(clk_out), 
    .rst_n(rst_n), 
    .count_sig(count_sig), 
    .bps_clk(bps_clk)
    );

bps_module u6 (
    .clk(clk_out), 
    .rst_n(rst_n), 
    .count_sig(count_sig1), 
    .bps_clk(bps_clk1)
    );


endmodule
