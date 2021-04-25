`include "defination.h"

module id_stage(
	input clk,
	input reset,
	//allowin
	input es_allowin,
	output ds_allowin,
	//from fs
	input fs_to_ds_valid,
	input [`FS_TO_DS_BUS_WD-1:0] fs_to_ds_bus,
	//to es
	output ds_to_es_valid,
	output [`DS_TO_ES_BUS_WD-1:0] ds_to_es_bus,
	//to fs
	output [`JUMP_BUS_WD-1:0] jump_bus,
	//to rf: for write back
	input  [`WS_TO_RF_BUS_WD] ws_to_rf_bus
);

reg ds_valid;
wire ds_ready_go;

//wire [31:0] fs_pc;
reg [`FS_TO_DS_BUS_WD-1:0] fs_to_ds_bus_r; //pipeline register
//assign fs_pc = fs_to_ds_bus[31:0];

wire [31:0] ds_instr;
wire [31:0] ds_pc;
assign {ds_instr,
		ds_pc} = fs_to_ds_bus_r

wire rf_we;
wire [4:0] rf_waddr;
wire [31:0] rf_wdata;
assign {rf_we,//37:37
		rf_waddr,//36:32
		rf_wdata //31:0
		} = ws_to_rf_bus;

wire jump_taken;
wire [31:0] jump_target;

wire [11:0] alu_op;
wire load_op;
wire src1_is_sa;
wire src1_is_pc;
wire src2_is_imm;
wire src2_is_8;
wire res_from_mem;
wire gr_we;
wire mem_we;
wire [ 4:0] dest;
wire [15:0] imm;
//wire [31:0] rs_value;
//wire [31:0] rt_value;

wire [ 5:0] op;
wire [ 4:0] rs;
wire [ 4:0] rt;
wire [ 4:0] rd;
wire [ 4:0] sa;
wire [ 5:0] func;
wire [25:0] index;
wire [63:0] op_d;
wire [31:0] rs_d;
wire [31:0] rt_d;
wire [31:0] rd_d;
wire [31:0] sa_d;
wire [63:0] func_d;

wire instr_addu;
wire instr_subu;
wire instr_slt;
wire instr_sltu;
wire instr_and;
wire instr_or;
wire instr_nor
wire instr_xor;
wire instr_sll;
wire instr_srl;
wire instr_sra;
wire instr_addiu;
wire instr_lui;
wire instr_lw;
wire instr_sw;
wire instr_beq;
wire instr_bne;
wire instr_jal;
wire instr_jr;

wire dst_is_r31;
wire dst_is_rt;

wire [ 4:0] rf_raddr1;
wire [31:0] rf_rdata1;
wire [ 4:0] rf_raddr2;
wire [31:0] rf_rdata2;

wire rs_eq_rt;

assign jump_bus = {jump_taken, jump_target};

assign ds_to_es_bus = {alu_op,//135:124
					   load_op,//123:123
					   src1_is_sa,//122:122
					   src1_is_pc,//121:121
					   src2_is_imm,//120:120
					   src2_is_8,//119:119
					   gr_we,//118:118
					   mem_we,//117:117
					   dest,//116:112
					   imm,//111:96
					   rf_rdata1,//95:64
					   rf_rdata2,//63:32
					   ds_pc//31:0
					   };
assign ds_ready_go = 1'b1;
assign ds_allowin = !ds_valid || ds_ready_go && es_allowin;
assign ds_to_es_valid = ds_valid && ds_ready_go;

always @(posedge clk) begin 
	if(fs_to_ds_valid && ds_allowin) begin 
		fs_to_ds_bus <= fs_to_ds_bus_r;
	end
end

assign op    = ds_instr[31:26];
assign rs    = ds_instr[25:21];
assign rt    = ds_instr[20:16];
assign rd    = ds_instr[15:11];
assign sa    = ds_instr[10: 6];
assign func  = ds_instr[ 5: 0];
assign imm   = ds_instr[15: 0];
assign index = ds_instr[25: 0];

decoder_6_64 u_dec0(.in(op  ),.out(op_d  ));
decoder_6_64 u_dec1(.in(func),.out(func_d));
decoder_5_32 u_dec2(.in(rs  ),.out(rs_d  ));
decoder_5_32 u_dec3(.in(rt  ),.out(rt_d  ));
decoder_5_32 u_dec4(.in(rd  ),.out(rd_d  ));
decoder_5_32 u_dec2(.in(ra  ),.out(ra_d  ));

assign instr_addu  = op_d[6'h00] & sa_d[5'h00] & func_d[6'h21];
assign instr_subu  = op_d[6'h00] & sa_d[5'h00] & func_d[6'h23];
assign instr_slt   = op_d[6'h00] & rs_d[5'h00] &   sa_d[5'h00] & func_d[6'h2a];
assign instr_sltu  = op_d[6'h00] & rs_d[5'h00] &   sa_d[5'h00] & func_d[6'h2b];
assign instr_and   = op_d[6'h00] & sa_d[5'h00] & func_d[6'h24];
assign instr_or    = op_d[6'h00] & sa_d[5'h00] & func_d[6'h25];
assign instr_nor   = op_d[6'h00] & sa_d[5'h00] & func_d[6'h27];
assign instr_xor   = op_d[6'h00] & sa_d[5'h00] & func_d[6'h26];
assign instr_sll   = op_d[6'h00] & rs_d[5'h00] & func_d[6'h00];
assign instr_srl   = op_d[6'h00] & rs_d[5'h00] & func_d[6'h02];
assign instr_sra   = op_d[6'h00] & rs_d[5'h00] & func_d[6'h03];
assign instr_addiu = op_d[6'h09];
assign instr_lui   = op_d[6'h0f] & rs_d[5'h00];
assign instr_lw    = op_d[6'h23];
assign instr_sw    = op_d[6'h2b];
assign instr_beq   = op_d[6'h04];
assign instr_bne   = op_d[6'h05];
assign instr_jal   = op_d[6'h03];
assign instr_jr    = op_d[6'h00] & rt_d[5'h00] &   rd_d[5'h00] &    ra_d[5'h00] & func_d[6'h08];

assign alu_op [ 0] = instr_addu | instr_addiu | instr_sw | instr_lw;
assign alu_op [ 1] = instr_subu;
assign alu_op [ 2] = instr_slt;
assign alu_op [ 3] = instr_sltu;
assign alu_op [ 4] = instr_and;
assign alu_op [ 5] = instr_nor;
assign alu_op [ 6] = instr_or;
assign alu_op [ 7] = instr_xor;
assign alu_op [ 8] = instr_sll;
assign alu_op [ 9] = instr_srl;
assign alu_op [10] = instr_sra;
assign alu_op [11] = instr_lui;

assign src1_is_sa   = instr_sll   | instr_srl | instr_sra;
assign src1_is_pc   = instr_jal;
assign src2_is_imm  = instr_addiu | instr_lui | instr_lw | instr_sw;
assign src2_is_8    = instr_jal;
assign res_from_mem = instr_lw;
assign dst_is_r31   = instr_jal;
assign dst_is_rt    = instr_addiu | instr_lui | instr_lw;
assign gr_we        = ~instr_sw & ~instr_beq & ~instr_bne & ~instr_jr;

assign dest = dst_is_r31 ? 5'd31 :
				 dst_is_rt  ? rt    :
				 			  rd;

assign rf_raddr1 = rs;
assign rf_raddr2 = rt;
regfile u_regfile(
	.clk   (clk		 ),
	.raddr1(rf_raddr1),
	.rdata1(rf_rdata1),
	.raddr2(rf_raddr2),
	.rdara2(rf_rdata2),
	.we    (rf_we	 ),
	.waddr (rf_waddr ),
	.wdata (rf_wdata )
	);

assign rs_eq_rt = (rf_rdata1 == rf_rdata2);
assign jump_taken = (  instr_beq &&  rs_eq_rt
					|| instr_bne && !rs_eq_rt
					|| instr_jal
					|| instr_jr) && ds_valid;
assign jump_target = (instr_beq || instr_bne) ? (ds_pc + {{14{imm[15]}},imm[15:0],2'b0}):
					 (instr_jr) 			  ? rf_rdata1:
					/*instr_jal*/			    {fs_pc[31:28],index[25:0],2'b0};

endmodule