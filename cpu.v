`include "defination.v"

module cpu(
	input clk,
	input resetn,
	//instr SRAM interface
	output  instr_sram_en,
	output [3:0] instr_sram_wen,
	output [31:0] instr_sram_addr,
	output [31:0] instr_sram_wdata,
	input [31:0] instr_sram_rdata,
	//data sram interface
	output data_sram_en,
	output [3:0] data_sram_wen,
	output [31:0] data_sram_addr,
	output [31:0] data_sram_wdata,
	input [31:0] data_sram_rdata,
	//trace debug interface
	output [31:0] debug_wb_pc,
	output [3:0] debug_wb_rf_wen,
	output [4:0] debug_wb_rf_wnum,
	output [31:0] debug_wb_rf_wdata 
);

reg reset;
always @(posedge clk) begin 
	reset <= ~resetn;
end

wire ds_allowin;
wire es_allowin;
wire ms_allowin;
wire ws_allowin;
wire fs_to_ds_valid;
wire ds_to_es_valid;
wire es_to_ms_valid;
wire ms_to_ws_valid;
wire [`FS_TO_DS_BUS_WD-1:0] fs_to_ds_bus;
wire [`DS_TO_ES_BUS_WD-1:0] ds_to_es_bus;
wire [`ES_TO_MS_BUS_WD-1:0] es_to_ms_bus;
wire [`MS_TO_WS_BUS_WD-1:0] ms_to_ws_bus;
wire [`WS_TO_RF_BUS_WD-1:0] ws_to_rf_bus;
wire [`JUMP_BUS_WD-1:0] jump_bus;

if_stage if_stage(
	.clk(clk),
	.reset(reset),
	//allowin
	.ds_allowin(ds_allowin),
	//jump_bus
	.jump_bus_jump_bus),
	//outputs
	.fs_to_ds_valid(fs_to_ds_valid),
	.fs_to_ds_bus(fs_to_ds_bus),
	//instr SRAM interface
	.instr_sram_en(instr_sram_en),
	.instr_sram_wen(instr_sram_wen),
	.instr_sram_addr(instr_sram_addr),
	.instr_sram_wdata(instr_sram_wdata),
	.instr_sram_rdata(instr_sram_rdata)
);

id_stage id_stage(
	.clk(clk),
	.reset(reset),
	//allowin
	.es_allowin(es_allowin),
	.ds_allowin(ds_allowin),
	//from fs
	.fs_to_ds_valid(fs_to_ds_valid),
	.fs_to_ds_bus(fs_to_ds_bus),
	//to es
	.ds_to_es_valid(ds_to_es_valid),
	.ds_to_es_bus(ds_to_es_bus),
	//to fs
	.jump_bus(jump_bus),
	//to rf: for write back
	.ws_to_rf_bus(ws_to_rf_bus)
);

ex_stage ex_stage(
	.clk(clk),
	.reset(reset),
	//allowin
	.ms_allowin(ms_allowin),
	.es_allowin(es_allowin),
	//from ds
	.ds_to_es_valid(ds_to_es_valid),
	.ds_to_es_bus(ds_to_es_bus),
	//to ms
	.es_to_ms_valid(es_to_ms_valid),
	.es_to_ms_bus(es_to_ms_bus),
	//data SRAM interface
	.data_sram_en(data_sram_en),
	.data_sram_wen(data_sram_wen),
	.data_sram_addr(data_sram_addr),
	.data_sram_wdata(data_sram_wdata)
);

mem_stage mem_stage(
	.clk(clk),
	.reset(reset),
	//allowin
	.ws_allowin(ws_allowin),
	.ms_allowin(ms_allowin),
	//from es
	.es_to_ms_valid(es_to_ms_valid),
	.es_to_ms_bus(es_to_ms_bus),
	//to ws
	.ms_to_ws_valid(ms_to_ws_valid),
	.ms_to_ws_bus(ms_to_ws_bus),
	//from data SRAM
	.data_sram_rdata(data_sram_rdata)
);

wb_stage wb_stage(
	.clk(clk),
	.reset(reset),
	//allowin
	.ws_allowin(ws_allowin),
	//from ms
	.ms_to_ws_valid(ms_to_ws_valid),
	.ms_to_ws_bus(ms_to_ws_bus),
	//to rf : for write back
	.ws_to_rf_bus(ws_to_rf_bus),
	//trace debug interface
	.debug_wb_pc(debug_wb_pc),
	.debug_wb_rf_wen(debug_wb_rf_wen),
	.debug_wb_rf_wnum(debug_wb_rf_wnum),
	.debug_wb_rf_wdata(debug_wb_rf_wdata)
);

endmodule