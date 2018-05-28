`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2018 08:38:33 PM
// Design Name: 
// Module Name: Demo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Demo(input fpga_gclk,
    input rx,
    output tx,
    input rst_n,
    output vga_hs,
    output vga_vs,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    input key1
    );
    
    wire uartclk, vga_clk;
    UARTCLK U1(.clk_in1(fpga_gclk),
    .clk_out1(uartclk),
    .locked());
    
    VGACLK U2(
            .clk_in1(fpga_gclk),
            .clk_out1(vga_clk),
            .locked());
    uart_test U3(.clk50(uartclk),
    .rx(rx),
    .tx(tx),
    .reset(rst_n));
    
    vga U4(
    .rst_n(rst_n),
    .vga_clk(vga_clk),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b),
    .key1(key1));
    
    
endmodule
