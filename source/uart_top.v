module uart_top(clk,rst_n,rs232_rx,rs232_tx);
 input clk;    //时钟信号50M
 input rst_n;   //复位信号,低有�?
 input rs232_rx;  //数据输入信号
 output rs232_tx;  //数据输出信号
 
 wire bps_start1,bps_start2;//
 wire clk_bps1,clk_bps2;
 wire [7:0] rx_data;   //接收数据存储�?,用来存储接收到的数据,直到下一个数据接�?
 wire rx_int;     //接收数据中断信号,接收过程中一直为�?,
 
///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////子模块端口申�?///////////////////////////////////
speed_select_rx     speed_rx(   //数据接收波特率�?�择模块
         .clk(clk),
         .rst_n(rst_n),
         .bps_start(bps_start1),
         .clk_bps(clk_bps1)
         );
        
uart_rx    uart_rx(    //数据接收模块
         .clk(clk),
         .rst_n(rst_n),
         .bps_start(bps_start1),
         .clk_bps(clk_bps1),
         .rs232_rx(rs232_rx),
         .rx_data(rx_data),
         .rx_int(rx_int)
        );
speed_select_tx  speed_tx(   //数据发�?�波特率控制模块
         .clk(clk),
         .rst_n(rst_n),
         .bps_start(bps_start2),
         .clk_bps(clk_bps2)         
         );
         
uart_tx    uart_tx(
         .clk(clk),
         .rst_n(rst_n),
         .bps_start(bps_start2),
         .clk_bps(clk_bps2),
         .rs232_tx(rs232_tx),
         .rx_data(rx_data),
         .rx_int(rx_int)        
        );
endmodule

 

//接收端时钟模块：

module speed_select_rx(clk,rst_n,bps_start,clk_bps);//波特率设�?
 input clk;   //50M时钟
 input rst_n;  //复位信号
 input bps_start; //接收到信号以�?,波特率时钟信号置�?,当接收到uart_rx传来的信号以�?,模块�?始运�?
 output clk_bps; //接收数据中间采样�?,
 
// `define BPS_PARA 5207;//9600波特率分频计数�??
// `define BPS_PARA_2 2603;//计数�?半时采样
 
 reg[12:0] cnt;//分频计数�?
 reg clk_bps_r;//波特率时钟寄存器
 
 reg[2:0] uart_ctrl;//波特率�?�择寄存�?
 
 always @(posedge clk or negedge rst_n)
  if(!rst_n)
   cnt<=13'd0;
  else if((cnt==512)|| !bps_start)//判断计数是否达到1个脉�?
   cnt<=13'd0;
  else
   cnt<=cnt+1'b1;//波特率时钟启�?
   
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
   clk_bps_r<=1'b0;
  else if(cnt== 205)//当波特率计数到一半时,进行采样存储
   clk_bps_r<=1'b1;
  else
   clk_bps_r<=1'b0;
 end
 assign clk_bps = clk_bps_r;//将采样数据输出给uart_rx模块
endmodule

//发�?�端时钟模块�?

 

module speed_select_tx(clk,rst_n,bps_start,clk_bps);//波特率设�?
 input clk;   //50M时钟
 input rst_n;  //复位信号
 input bps_start; //接收到信号以�?,波特率时钟信号置�?,当接收到uart_rx传来的信号以�?,模块�?始运�?
 output clk_bps; //接收数据中间采样�?,
 
// `define BPS_PARA 5207;//9600波特率分频计数�??
// `define BPS_PARA_2 2603;//计数�?半时采样
 
 reg[12:0] cnt;//分频计数�?
 reg clk_bps_r;//波特率时钟寄存器
 
 reg[2:0] uart_ctrl;//波特率�?�择寄存�?
 
 always @(posedge clk or negedge rst_n)
  if(!rst_n)
   cnt<=13'd0;
  else if((cnt==512)|| !bps_start)//判断计数是否达到1个脉�?
   cnt<=13'd0;
  else
   cnt<=cnt+1'b1;//波特率时钟启�?
   
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
   clk_bps_r<=1'b0;
  else if(cnt== 205)//当波特率计数到一半时,进行采样存储
   clk_bps_r<=1'b1;
  else
   clk_bps_r<=1'b0;
 end
 assign clk_bps = clk_bps_r;//将采样数据输出给uart_rx模块
endmodule

 

//接收模块�?

 

module uart_rx(
     clk,
     rst_n,
     bps_start,
     clk_bps,
     rs232_rx,
     rx_data,
     rx_int
     );
 input clk;   //时钟
 input rst_n;  //复位
 input rs232_rx; //接收数据信号
 input clk_bps;  //高电平时为接收信号中间采样点
 output bps_start; //接收信号�?,波特率时钟信号置�?
 output [7:0] rx_data;//接收数据寄存�?
 output rx_int;  //接收数据中断信号,接收过程中为�?
 reg rs232_rx0,rs232_rx1,rs232_rx2,rs232_rx3;//接收数据寄存�?
 wire neg_rs232_rx;//表示数据线接收到下沿
 
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n) begin
   rs232_rx0 <= 1'b0;
   rs232_rx1 <= 1'b0;
   rs232_rx2 <= 1'b0;
   rs232_rx3 <= 1'b0;
  end
  
  else begin
   rs232_rx0 <= rs232_rx;
   rs232_rx1 <= rs232_rx0;
   rs232_rx2 <= rs232_rx1;
   rs232_rx3 <= rs232_rx2;
  end
 end 
 assign neg_rs232_rx = rs232_rx3 & rs232_rx2 & ~rs232_rx1 & ~rs232_rx0;//串口传输线的下沿标志
 reg bps_start_r;
 reg [3:0] num;//移位次数
 reg rx_int;  //接收中断信号
 
 always @(posedge clk or negedge rst_n)
  if(!rst_n) begin
   bps_start_r <=1'bz;
   rx_int <= 1'b0;
  end
  else if(neg_rs232_rx) begin//
  bps_start_r <= 1'b1;  //启动串口,准备接收数据
   rx_int <= 1'b1;   //接收数据中断使能
  end
  else if(num==4'd12) begin //接收完有用的信号,
   bps_start_r <=1'b0;  //接收完毕,改变波特率置�?,方便下次接收
   rx_int <= 1'b0;   //接收信号关闭
  end
  
  assign bps_start = bps_start_r;
  
  reg [7:0] rx_data_r;//串口数据寄存�?
  reg [7:0] rx_temp_data;//当前数据寄存�?
  
  always @(posedge clk or negedge rst_n)
   if(!rst_n) begin
     rx_temp_data <= 8'd0;
     num <= 4'd0;
     rx_data_r <= 8'd0;
   end
   else if(rx_int) begin //接收数据处理
    if(clk_bps) begin
     num <= num+1'b1;
     case(num)
       4'd1: rx_temp_data[0] <= rs232_rx;
       4'd2: rx_temp_data[1] <= rs232_rx;
       4'd3: rx_temp_data[2] <= rs232_rx;
       4'd4: rx_temp_data[3] <= rs232_rx;
       4'd5: rx_temp_data[4] <= rs232_rx;
       4'd6: rx_temp_data[5] <= rs232_rx;
       4'd7: rx_temp_data[6] <= rs232_rx;
       4'd8: rx_temp_data[7] <= rs232_rx;
       default: ;
     endcase
    end
    else if(num==4'd12) begin
     num <= 4'd0;   //数据接收完毕
     rx_data_r <= rx_temp_data;
    end          
   end
  assign rx_data = rx_data_r;
endmodule

 

//发�?�模块：

module uart_tx(
     clk,
     rst_n,
     bps_start,
     clk_bps,
     rs232_tx,
     rx_data,
     rx_int 
    );

 input clk;
 input rst_n;
 input clk_bps;//中间采样�?
 input [7:0] rx_data;//接收数据寄存�?
 input rx_int;//数据接收中断信号
 output rs232_tx;//发�?�数据信�?
 output bps_start;//发�?�信号置�?
 
 reg rx_int0,rx_int1,rx_int2;//信号寄存�?,捕捉下降�?
 wire neg_rx_int;    //下降沿标�?
 
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
   rx_int0 <= 1'b0;
   rx_int1 <= 1'b0;
   rx_int2 <= 1'b0;
  end
  else begin
    rx_int0 <= rx_int;
    rx_int1 <= rx_int0;
    rx_int2 <= rx_int1;
  end
 end
 
  assign neg_rx_int = ~rx_int1 & rx_int2;//捕捉下沿
  
  reg [7:0] tx_data;//待发送数�?
  reg bps_start_r;
  reg tx_en;//发�?�信号使�?,高有�?
  reg [3:0] num;
 
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
   bps_start_r <= 1'bz;
   tx_en <= 1'b0;
   tx_data <= 8'd0;
  end
  else if(neg_rx_int) begin//当检测到下沿的时�?,数据�?始传�?
   bps_start_r <= 1'b1;
   tx_data <= rx_data;
   tx_en <= 1'b1;
  end
  else if(num==4'd11) begin
   bps_start_r <= 1'b0;
   tx_en <= 1'b0;
  end 
 end
 
 assign bps_start = bps_start_r;
 
 reg rs232_tx_r;
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
   num<=4'd0;
   rs232_tx_r <= 1'b1;
  end
  else if(tx_en) begin
   if(clk_bps) begin
    num<=num+1'b1;
    case(num)
      4'd0: rs232_tx_r <= 1'b0;//起始�?
      4'd1: rs232_tx_r <= tx_data[0];//数据�? �?�?
      4'd2: rs232_tx_r <= tx_data[1];
      4'd3: rs232_tx_r <= tx_data[2];
      4'd4: rs232_tx_r <= tx_data[3];
      4'd5: rs232_tx_r <= tx_data[4];
      4'd6: rs232_tx_r <= tx_data[5];
      4'd7: rs232_tx_r <= tx_data[6];
      4'd8: rs232_tx_r <= tx_data[7];
      4'd9: rs232_tx_r <= 1'b1;//数据结束�?,1�?
      default: rs232_tx_r <= 1'b1;
    endcase
   end
   else if(num==4'd11)
    num<=4'd0;//发�?�完�?,复位
  end
 end
 assign rs232_tx =rs232_tx_r;
endmodule