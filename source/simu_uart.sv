`timescale 1ns / 1ps

module simu_uart();
    logic clk;
    logic reset;
    initial reset <= 1; 
    always begin
        clk <= 1; #5 clk <= 0; #5;
    end
    uart_top uart_top(clk,~reset,tx_pin_out,rx_pin_in);
endmodule  
