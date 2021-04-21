# 基础五级流水线指令集
* ADDU, ADDIU, SUBU, SLT, SLTU, SLL, SRL, SRA, AND, OR, XOR, NOR
* LW, SW
* BEQ, BNE, JAL, JR
* LUI,
# 流水线划分
* IF, ID, EX, MEM, WB
* **流水线寄存器命名规范：将触发器归到输出对应的一级流水阶段，即将IF/ID_reg，命名为ID_reg**<br>IF->ID_reg->ID->EX_reg->EX->MEM_reg->MEM->WB_reg->WB
* 流水线寄存器划分为控制内容和数据内容：
  * 控制内容：暂时仅有1bit缓存有效位
  * 数据内容：流水指令信号or控制器信号，以供使用
# 关于RAM
* 异步读RAM：类似于BUAA_CO上的RAM或者regfile，一拍内输入读出(Xilinx FPGA distributed RAM)
* 同步读RAM：类似于BUAA_CO流水线中的数据RAM，一拍输入，在下一个时钟上升沿读出(Xilinx FPGA block RAM)
* 本流水线采用同步读RAM(与工程实践一致)
## 同步RAM设计
两种方案：  
1. 指令RAM的读请求放在IF阶段，则在指令到达ID时，RAM成为有效输出
2. 在生成next_pc时，将next_pc同时传递给pc和RAM，在指令位于IF时，RAM成为有效输出(pre_IF)
* **在ASIC实现下，第二种更好，**因为对于ASIC实现，同步RAM的clk-to-Q延迟远大于输入端口的Setup，也远大于触发器的clk-to-Q延迟。<br>方案一下，ID阶段存在关键路径“RAM读出->通用寄存器堆读出”和“RAM读出->指令译码->ALU源操作数选择”两条，通用寄存器读出和指令译码的延迟已经很大，加上RAM的clock-to-Q延迟，会导致延迟非常大
* 在FPGA实现下，同步RAM使用block RAM实现的，这些RAM的底层电路就是RMA，对于Xilinx7及更先进的FPGA，这些RAM的频率很高，相比通常100-200MHZ的CPU。因此上述问题不再成为主要矛盾。
&nbsp;
* **采用方案二**，方案一下，在流水线阻塞的时候，RAM读出的数据难以维护。
* **数据RAM采用同样的方式**  
# 其他标准
* 根据MIPS标准，PC复位到0xBFC0_0000，由于pre_IF存在，将pc设置为0xBFBF_FFFC刚好可以满足要求
* 各级流水线寄存器使用如下信号(ID_reg为例)：
```verilog
// allowin
input           es_allowin
output          ds_allowin
// from fs
input           fs_to_ds_valid
// to es
output          ds_to_es_valid
```
# 命名规范
整体采用下划线分割  
1. * IF_stage  -> fs
   * ID_stage  -> ds
   * EX_stage  -> es
   * MEM_stage -> ms
   * WB_stage  -> ws
2. regfile -> rf
3. write_enable -> we
4. 指令信号: instr + "instruction name"
5. 选择信号: "port name" + is + "signal name"
6. ALU信号: alu + other
# 控制信号
## ALU 控制信号
**独热码**  
|bit|operation|relative instr|
|:----:|:----:|:----:|
|0|op_add|ADDU,ADDIU,LW,SW|
|1|op_sub|SUBU|
|2|op_slt|SLT|
|3|op_sltu|SLTU|
|4|op_and|AND|
|5|op_nor|NOR|
|6|op_or|OR|
|7|op_xor|XOR|
|8|op_sll|SLL|
|9|op_srl|SRL|
|10|op_sra|SRA|
|11|op_lui|LUI|
## Controller（集成于module ID_stage）信号
直接流水指令的独热码？流水各部件控制信号？  
**由于目前指令较少，暂时采用1**  
