//      reg[3 : 0] vga_dis_mode = 4'b1100;
//      reg[3 : 0]  vga_r_reg;
//      reg[3 : 0]  vga_g_reg;
//      reg[3 : 0]  vga_b_reg;  
//      wire CLK_OUT;

//reg [11:0] h_cntr_reg,v_cntr_reg;
//reg h_sync_reg, v_sync_reg;
//reg active;

//reg[27:0] cntDyn;
   
//reg [3:0] bg_red;
//reg [3:0] bg_green;
//reg [3:0] bg_blue;

//reg signed [11:0] red_temp,green_temp,blue_temp;

//    always @(posedge vga_clk)
//    if(~rst_n) h_cntr_reg <= 0;
//    else begin
//        if (h_cntr_reg == (LinePeriod - 1))
//            h_cntr_reg <= 0;
//        else
//            h_cntr_reg <= h_cntr_reg + 1;
//    end
   
//    always @(posedge vga_clk)
//    if(~rst_n) v_cntr_reg <= 0;
//    else begin
//        if ((h_cntr_reg == (LinePeriod - 1)) && (v_cntr_reg == (FramePeriod - 1)))
//            v_cntr_reg <= 0;
//        else if (h_cntr_reg == (LinePeriod - 1))
//            v_cntr_reg <= v_cntr_reg + 1;
//    end
   
//    always @(posedge vga_clk)
//    if(~rst_n) h_sync_reg <= 0;
//    else begin
//         if ((h_cntr_reg >= (H_FrontPorch + H_ActivePix - 1)) && (h_cntr_reg < (H_FrontPorch + H_ActivePix + H_SyncPulse - 1)))
//            h_sync_reg <= 1;
//         else
//            h_sync_reg <= 0;
//    end
   
//    always @(posedge vga_clk)
//    if(~rst_n) v_sync_reg <= 0;
//    else begin
//        if ((v_cntr_reg >= (V_FrontPorch + V_ActivePix - 1)) && (v_cntr_reg < (V_FrontPorch + V_ActivePix + V_SyncPulse - 1)))
//            v_sync_reg <= 1;
//        else
//            v_sync_reg <= 0;
//    end

///*
//    always @(posedge vga_clk)
//    if(~rst_n) begin cntDyn <= 0; end
//    else begin
//         cntDyn <= cntDyn + 1;
//         end
    
//    always@(*) begin
//        red_temp <= 0;//(h_cntr_reg + v_cntr_reg + cntDyn/2 ** 20); //20: control the speed
//        green_temp <= 0;//(v_cntr_reg + cntDyn/2 ** 20);
//        blue_temp <= (h_cntr_reg + cntDyn/2 ** 20);
//    end

//    always@(*) begin
//        bg_red <= red_temp[7:4]<4'b1101 ? red_temp[7:4]+4'd2 : 4'b1111;
//        bg_green <= green_temp[7:4]<4'b1101 ? green_temp[7:4]+4'd2 : 4'b1111;
//        bg_blue <= blue_temp[7:4]<4'b1101 ? blue_temp[7:4]+4'd2 :4'b1111;
//    end
//*/        

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:00:39 06/06/2016 
// Design Name: 
// Module Name:    VGA
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga
                (
                vga_clk ,
                rst_n ,
                key1,
                vga_r,
                vga_g,
                vga_b,
                vga_hs,
                vga_vs
                ); 
input   vga_clk ;   // VGA像素时钟
input   rst_n ;      // 异步复位信号
input key1;
output      [3:0] vga_r ; 
output    [3:0]  vga_g ;
output   [3:0]   vga_b ; 
output   vga_hs ;  // VGA管脚 行同步
output   vga_vs ;  // VGA管脚 场同步

parameter H_SYNC  = 16'd112;   // 同步脉冲      vga_hs
parameter H_BACK  = 16'd248;    // 显示后沿 
parameter H_DISP  = 16'd1280;   // 显示时序
parameter H_FRONT = 16'd48;    // 显示前沿
parameter H_TOTAL = 16'd1688;  // 时序帧长   ---hs_cnt 

parameter V_SYNC  = 16'd3;     // 同步脉冲      vga_vs
parameter V_BACK  = 16'd38;    // 显示后沿
parameter V_DISP  = 16'd1024;   // 显示时序 
parameter V_FRONT = 16'd1;    // 显示前沿
parameter V_TOTAL = 16'd1066;   // 时序帧长   --- vs_cnt 
//------------------------------------------
reg [15:0] hs_cnt ; 
reg [15:0] vs_cnt ;
always @ (posedge vga_clk )
    if(!rst_n) hs_cnt <= 16'd0; 
    else if(hs_cnt == H_TOTAL-1) hs_cnt <= 16'd0 ; 
    else     hs_cnt <= hs_cnt + 16'd1 ; 
always @(posedge vga_clk)
    if(!rst_n) vs_cnt <= 16'd0 ; 
    else if (vs_cnt == V_TOTAL-1) vs_cnt <= 16'd0 ; 
    else if (hs_cnt == H_TOTAL-1) vs_cnt <= vs_cnt + 16'd1 ; 
    
reg hsync_r,vsync_r;    //同步信号
//------------------------------------------------- 
always @ (posedge vga_clk)
    if(!rst_n) hsync_r <= 1'b1;                                
    else if(hs_cnt == 16'd0)    hsync_r <= 1'b0;    //产生hsync信号
    else if(hs_cnt == H_SYNC-1) hsync_r <= 1'b1;

always @ (posedge vga_clk )
    if(!rst_n) vsync_r <= 1'b1;                              
    else if(vs_cnt == 16'd0)    vsync_r <= 1'b0;    //产生vsync信号
    else if(vs_cnt == V_SYNC-1) vsync_r <= 1'b1;

assign vga_hs = hsync_r;
assign vga_vs = vsync_r;

//--------------------------------------------------------------------------
//有效信号范围
reg     x_en ,y_en ; 
always @ (posedge vga_clk)
    if(!rst_n) x_en  <= 1'd0 ; 
    else if (hs_cnt==(H_SYNC + H_BACK)) x_en  <= 1'd1 ; 
    else if (hs_cnt==(H_SYNC + H_BACK + H_DISP)) x_en  <= 1'd0 ; 

always @ (posedge vga_clk)
    if(!rst_n) y_en <= 1'd0 ; 
    else if (vs_cnt == (V_SYNC + V_BACK)) y_en <= 1'd1 ; 
    else if (vs_cnt == (V_SYNC + V_BACK + V_DISP)) y_en <= 1'd0 ; 
reg [11:0]iter;
wire [1279:0] douta;
reg [9:0] addra;
ROM U2 (
   .clka(vga_clk),    // input wire clka
   .ena(1'b1),      // input wire ena
   .addra(addra),  // input wire [9 : 0] addra
   .douta(douta)  // output wire [1279 : 0] douta
);
reg [3:0] vga_r_reg,vga_g_reg,vga_b_reg;
always @ (posedge vga_clk)
    if(!rst_n) begin
    vga_r_reg<=0; 
    vga_g_reg<=0;
    vga_b_reg<=0;  
    addra<=0; 
    iter<= 0;
    end
    else begin
        if(x_en&y_en)begin
            iter <= iter + 1;
            if (hs_cnt==(H_SYNC + H_BACK)+1) begin
                addra <= addra + 1;
                iter <= 0;
            end
            if (~douta[1279-iter]) begin  
                vga_r_reg <= 4'b0000;  
                vga_g_reg <= 4'b0000;  
                vga_b_reg <= 4'b0000;  
            end  
            else begin  
                vga_r_reg <= 4'b1111;  
                vga_g_reg <= 4'b1111;  
                vga_b_reg <= 4'b1111;  
            end
        end
    end
    
assign vga_r = (x_en&y_en) ? vga_r_reg: 4'd0 ; 
assign vga_g = (x_en&y_en) ? vga_g_reg: 4'd0 ; 
assign vga_b = (x_en&y_en) ? vga_b_reg: 4'd0 ;
endmodule 