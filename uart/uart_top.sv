`timescale 1ns / 1ps

module uart_top(
    input   logic   CLK100MHZ,
    input   logic   rst_n,
    output  logic   tx_pin_out,
    input   logic   rx_pin_in  
);
logic       rx_done_sig;
logic [7:0] rx_data;
logic       cnt,clk_out;
logic       h2l_sig;

initial cnt = 1'b0;
always@(posedge CLK100MHZ)cnt <= cnt +1;
assign clk_out = cnt;

test_module u2 (
    .clk(clk_out), 
    .rst_n(rst_n), 
    .rx_pin_in(rx_pin_in), 
    .h2l_sig(h2l_sig)
    );

// input control
rx_control_module u3 (
    .clk(clk_out), 
    .rst_n(rst_n), 
    .h2l_sig(h2l_sig), 
    .rx_pin_in(rx_pin_in), 
    .rx_data(rx_data), 
    .rx_done_sig(rx_done_sig)
    );

// output control
tx_control_module u4 (
    .clk(clk_out), 
    .rst_n(rst_n), 
    .tx_sig(rx_done_sig), 
    .tx_data(rx_data), 
    .tx_pin_out(tx_pin_out)
    );


endmodule
