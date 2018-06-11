## MIPS_V3.1——流水线64位CPU

[TOC]



### 一、项目概述

本次实验我实现了64位MIPS流水线CPU，支持三种冒险的完整解决方法，支持包括5种64位指令在内的24条指令。但目前的指令都是可以在FDEMW五个周期内完成的指令，在下一版本的CPU种，我会实现支持不同时钟周期结束的指令。

我花了很多时间研究并实现了硬件上串口调试的功能（助教给的代码不知道为什么运行不了）， 支持通过串口在电脑上显示数据情况的功能。

我还花时间调研了不同解决冒险方法对CPI的影响，分析出重定向是能节约最多时间的方法。

### 二、支持指令

1. LD，LWU，LW，LBU，LB，SD，SW，SB 共8种读写指令
2. ADD，SUB，OR，AND，SLT，DADD，DSUB，NOP* 共8种R类指令
3. ADDI，ANDI，ORI，SLTI，DADDI 共5种I类计算指令
4. BEQ，BNE，J 共3种分支、跳转指令

*：根据官方文档\<MIPS64-Vol2\>，NOP 指令实际上是SLL r0, r0, 0，所以也属于R类指令

### 三、项目文件

根目录（/）

```
/test/                  存放各种版本的汇编文件(.s)、十六进制文件(.dat)
/images/                存放实验报告所需的图片(.png)
/source/                源代码(.sv)
/uart/                  参考网上资料的串口功能代码(.v)
/Reference/             MIPS64官方文档等参考资料
.gitignore              git配置文件
memfile.dat             当前使用的十六进制文件（每行两条指令）
guide.txt               Nexys4实验板演示说明
report.md               实验报告
Nexys4DDR_Master.xdc    Nexys4实验板引脚锁定文件
simulation_behav.wcfg   仿真波形图配置文件
```

源代码（/source/）

```
adder.sv                加法器单元
alu.sv                  ALU计算单元
aludec.sv               ALU控制单元，用于输出alucontrol信号
clkdiv.sv               时钟分频模块模块，用于演示
controller.sv           mips的控制单元，包含maindec和aludec两部分
datapath.sv             数据通路，mips的核心结构
flopenr.sv              时钟控制的可复位的触发寄存器
flopr.sv                可复位的触发寄存器
flopencr.sv             时钟控制的可复位、可清零的触发寄存器
flopcr.sv               可复位、可清零的触发寄存器
hazardunit.sv           冒险处理单元
maindec.sv              主控单元
mem.sv                  指令和数据的混合存储器
mips.sv                 mips处理器的顶层模块
monboard.sv             在Nexys4实验板上测试的顶层模块（不含串口调试）
mux2.sv                 2:1复用器
mux3.sv                 3:1复用器
mux4.sv                 4:1复用器
mux5.sv                 5:1复用器
onboard.sv              在Nexys4实验板上测试的顶层模块（含串口调试）
regfile.sv              寄存器文件
signext.sv              符号拓展模块
simulation.sv           仿真时使用的顶层模块
sl2.sv                  左移2位
top.sv                  包含mips和内存的顶层模块
zeroext.sv              零拓展模块
```

串口调试（/uart/）

```
top.v                   串口调试顶层模块
bps_module.v            控制发射速率的模块
rx_control_module.v     rx控制模块
tx_control_module.v     tx控制模块
test_module.v           下降沿检测模块
```

### 四、数据通路设计

![流水线图](/images/流水线图.png)

我的数据通路设计如上图所示，更清晰的图可以见/Reference/流水线图.pdf



  





### 五、控制单元设计

控制单元和数据路径一样需要进行阶段上的传递

```verilog
//controller.sv
maindec maindec(clk, reset, op,
                    regwriteD,memtoregD, regdstD, memwriteD,
                    alusrcD, bneD, branchD, jumpD,
                    aluopD, readtypeD);
aludec aludec(funct, aluopD, alucontrolD);
flopcr#(14)     regD2E(clk,reset,FlushE,...);
flopr #(7)      regE2M(clk,reset,...);
flopr #(2)      regM2W(clk,reset,...);
```



```verilog
//maindec.sv
assign {regwrite,memtoreg,regdst, memwrite, alusrc,
            bne,branch,jump, aluop, readtype} = controls; 
    always_comb
        case (op)
            RTYPE:  controls <= 16'b101_00_00_000_111_000;
            SD:     controls <= 16'b000_11_01_000_000_000;
            SW:     controls <= 16'b000_01_01_000_000_000;
            SB:     controls <= 16'b000_10_01_000_000_000;
            LD:     controls <= 16'b110_00_01_000_000_100;
            LWU:    controls <= 16'b110_00_01_000_000_001;
            LW:     controls <= 16'b110_00_01_000_000_000;
            LBU:    controls <= 16'b110_00_01_000_000_011;
            LB:     controls <= 16'b110_00_01_000_000_010;
            ADDI:   controls <= 16'b100_00_01_000_000_000;
            ANDI:   controls <= 16'b100_00_10_000_001_000;
            ORI:    controls <= 16'b100_00_10_000_010_000;
            SLTI:   controls <= 16'b100_00_01_000_011_000;
            DADDI:  controls <= 16'b100_00_01_000_100_000;
            BEQ:    controls <= 16'b000_00_00_010_000_000;
            BNE:    controls <= 16'b000_00_00_110_000_000;
            J:      controls <= 16'b000_00_00_001_000_000;
         endcase
```



### 六、冒险处理单元设计

冒险处理单元的核心代码在书上基本上都给出了。其中重定向包含了两个部分：一个是ALU运算数选择上的重定向、一个是分支预测读取寄存器值的重定向。而刷新流水线主要用于解决lw后读冒险和分支预测冒险。

冒险处理单元的完整代码如下：

```verilog
module hazardunit(
    input   logic       clk,reset,
    input   logic       branchD,
    input   logic [4:0] rsD,rtD,rsE,rtE,
    input   logic [4:0] writeregE,writeregM,writeregW,
    input   logic       memtoregE,memtoregM,regwriteE,
        				regwriteM,regwriteW,
    output  logic       StallF,StallD,FlushE,
    output  logic       ForwardAD,ForwardBD,
    output  logic [1:0] ForwardAE,ForwardBE
);
    logic   lwStallD, branchStallD;
    // 重定向
    assign ForwardAD = rsD !=0 & (rsD == writeregM) & regwriteM;
    assign ForwardBD = rtD !=0 & (rtD == writeregM) & regwriteM;
    always_comb begin
        ForwardAE = 2'b00; ForwardBE = 2'b00;
        if (rsE != 0)
            if (rsE == writeregM & regwriteM)
                ForwardAE = 2'b10;
            else if (rsE == writeregW & regwriteW)
                ForwardAE = 2'b01;
        if (rtE != 0)
            if (rtE == writeregM & regwriteM)
                ForwardBE = 2'b10;
            else if (rtE == writeregW & regwriteW)
                ForwardBE = 2'b01;
    end
    // 刷新流水线
    assign #1 lwStallD = memtoregE & (rtE == rsD | rtE == rtD);
    assign #1 branchStallD = branchD & (regwriteE & 
        (writeregE == rsD | writeregE == rtD) |
        memtoregM & (writeregM == rsD | writeregM == rtD));
    assign #1 StallD = lwStallD | branchStallD;
    assign #1 StallF = StallD;
    assign #1 FlushE = StallD;
endmodule
```

### 七、冒险解决策略研究

如果不使用冒险处理单元，我们必须在代码中插入足够多的NOP来使程序可以在流水线上运行（插入NOP的功能实际上应该由编译器实现）。我通过分析使用不同冒险处理策略时所需要插入的NOP数和CPI，来考察不同冒险处理策略的效果。

**测试方法**：通过修改冒险处理单元中如下两行的代码，达到开关冒险处理策略的效果。

```verilog
assign #1 lwStallD = memtoregE & (rtE == rsD | rtE == rtD); 
//assign #1 lwStallD = 0；
assign #1 StallD = lwStallD | branchStallD; 
//assign #1 StallD = lwStallD;
```

**测试结果**：

**1.只插入nop来解决冒险**

| 代码        | 指令数 | 数据NOP* | 跳转NOP | 时钟周期 | CPI  |
| ----------- | ------ | -------- | ------- | -------- | ---- |
| standard2.s | 17     | 28       | 4       | 53       | 3.12 |
| testls.s    | 12     | 10       | 0       | 26       | 2.16 |
| power2.s    | 341    | 336      | 112     | 793      | 2.33 |
| testmore.s  | 1092   | 1188     | 396     | 2680     | 2.45 |

\*：数据NOP包括lw后NOP和数据依赖

**2.使用重定向后的情况**

| 代码        | 指令数 | lw后NOP | 跳转NOP | 时钟周期 | CPI  |
| ----------- | ------ | ------- | ------- | -------- | ---- |
| standard2.s | 17     | 0       | 2       | 23       | 1.35 |
| testls.s    | 12     | 1       | 0       | 17       | 1.42 |
| power2.s    | 341    | 0       | 56      | 411      | 1.21 |
| testmore.s  | 1092   | 99      | 198     | 1393     | 1.28 |


**3.使用三种解决冒险的方法**

| 代码        | 指令数 | 时钟周期 | CPI  |
| ----------- | ------ | -------- | ---- |
| standard2.s | 17     | 23       | 1.35 |
| testls.s    | 12     | 17       | 1.42 |
| power2.s    | 341    | 411      | 1.21 |
| testmore.s  | 1092   | 1393     | 1.28 |

**结论:**

寄存器的重定向可以化解大部分的冒险，使CPI明显的下降，但无法解决lw后读冒险和分支冒险；而使用刷新流水线的方法来解决分支冒险和lw后读冒险，可以节省下编译器插入NOP的时间，但无法加快处理器运算速度、降低CPI。

### 八、测试与演示设计



### 九、串口演示设计



### 十、时钟与资源



### 十一、实验总结



### 十二、参考文献



