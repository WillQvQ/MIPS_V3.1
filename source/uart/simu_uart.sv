`timescale 1ns / 1ps

module simu_uart();
    logic clk;
    logic clk2;
    logic reset;
    logic [7:0] data;
    initial data = 8'b10001000;
    initial reset <= 0; 
    always begin
        clk <= 1; #5 clk <= 0; #5;
    end
    always begin
        clk2 <= 1; #400 clk2 <= 0; #400;
    end
    uart_top uart_top(clk,clk2,~reset,tx_pin_out,rx_pin_in,data);
endmodule  
