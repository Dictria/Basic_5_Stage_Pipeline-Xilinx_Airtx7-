`include "defination.h"

module exe_stage(
	input 							clk,
	input 							reset,
	//allowin
	input 							ms_allowin,
	output 							es_allowin,
	//from ds
	input 							ds_to_es_valid,
	input  [`DS_TO_ES_BUS_WD-1:0] 	ds_to_es_bus,
	//to ms
	output es_to_ms_valid,
	output [`DS_TO_MS_BUS_WD-1:0] 	ds_to_ms_bus,
	//data SRAM insterface
	output 							data_sram_en,
	output [ 3:0] 					data_sram_wen,
	output [31:0] 					data_sram_addr,
	output [31:0] 					data_sram_wdata
	);
	
reg  es_valid;
wire es_ready_go;

reg	[`DS_TO_ES_ DS_TO_MS_BUS_WD-1:0]	ds_to_es_bus_r;
wire	[11:0]							es_alu_op;
wire									es_load_op;
wire									es_src1_is_sa;
wire									es_src1_is_pc;
wire									es_src2_is_imm;
wire									es_src2_is_8;
wire									es_gr_we;
wire									es_mem_we;
wire	[ 4:0]							es_dest;
wire	[15:0]							es_imm;
wire	[31:0]							es_rf_rdata1;
wire	[31:0]							es_rf_rdata2;
wire	[4:0]							es_rf_raddr1;
wire	[4:0]							es_rf_raddr2;
wire	[31:0]							es_pc;
assign {es_alu_op, //145:134
		es_load_op,//133:133
		es_src1_is_sa,//132:132
		es_src1_is_pc,//131:131
		es_src2_is_imm,//130:130
		es_src2_is_8,//129:129
		es_gr_we,//128:128
		es_mem_we,//127:127
		es_dest,//126:122
		es_imm,//121:106
		es_rf_rdata1,//105:74
		es_rf_raddr1,//73:69
		es_rf_rdata2,//68:37
		es_rf_raddr2,//36:32
		es_pc//31:0
		} = ds_to_es_bus_r;

wire [31:0] es_alu_src1;
wire [31:0] es_alu_src2;
wire [31:0] es_alu_res;

wire es_res_from_mem;

assign es_res_from_mem = es_load_op;
assign es_to_ms_bus = {es_res_from_mem,//70:70
						es_gr_we,//69:69
						es_dest,//68:64
						es_alu_res,//63:32
						es_pc//31:0
						};

assign es_ready_go    = 1'b1;
assign es_allowin     = !es_valid || es_ready_go && ms_allowin;
assign es_to_ms_valid =  es_valid && es_ready_go;
always @(posedge clk) begin 
	if(reset) begin 
		es_valid <= 1'b0;
	end
	else if(es_allowin) begin 
		es_valid <= ds_to_es_valid;
	end

	if(ds_to_es_valid && es_allowin) begin 
		ds_to_es_bus_r <= ds_to_es_bus;
	end
end

assign es_alu_src1 = es_src1_is_sa ? {27'b0,es_imm[10:6]} :
					 es_src1_is_pc ? es_pc:
					 				 es_rf_rdata1;
assign es_alu_src2 = es_src2_is_imm ? {{16{es_imm[15]}},es_imm} :
					 es_src2_is_8	? 32'd8:
					 				  es_rf_rdata2;
alu u_alu(
	.alu_op  (es_alu_op  ),
	.alu_src1(es_alu_src1),
	.alu_src2(es_alu_src2),
	.alu_res (es_alu_res )
	);
assign data_sram_en    = 1'b1;
assign data_sram_wen   = es_men_we && es_VALID ? 4'hf : 4'h0;
assign data_sram_addr  = es_alu_res;
assign data_sram_wdata = es_rf_rdata2;

endmodule