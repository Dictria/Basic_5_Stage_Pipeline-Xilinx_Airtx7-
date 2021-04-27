`include "defination.h"

module mem_stage(
	input clk,
	input reset,
	//allowin
	input ws_allowin,
	output ms_allowin,
	//from es
	input es_to_ms_valid,
	input [`ES_TO_MS_BUS_WD-1:0] es_to_ms_bus,
	//to ws
	output ms_to_ws_valid,
	output [`MS_TO_WS_BUS_WD-1:0] ms_to_ws_bus,
	//from data SRAM
	input [31:0] data_sram_rdata
);

reg ms_valid;
wire ms_ready_go;

reg [`ES_TO_MS_BUS_WD-1:0] es_to_ms_bus_r;
wire ms_res_from_mem;
wire ms_gr_we;
wire [4:0] ms_dest;
wire [31:0] ms_alu_res;
wire [31:0] ms_pc;

assign {ms_res_from_mem,//70:70
		ms_gr_we,//69:69
		ms_dest,//68:64
		ms_alu_res,//63:32
		ms_pc//31:0
		} = es_to_ms_bus_r;

wire [31:0] mem_res;
wire [31:0] ms_final_res;

assign ms_to_ws_bus = {ms_gr_we,//69:69
					   ms_dest,//68:64
					   ms_final_res,//63:32
					   ms_pc//31:0
						};

assign ms_ready_go = 1'b1;
assign ms_allowin = !ms_valid || ms_ready_go && ws_allowin;
assign ms_to_ws_valid = ms_valid && ms_ready_go;

always @(posedge clk) begin 
	if(reset) begin 
		ms_valid <= 1'b0;
	end
	else if(ms_allowin) begin 
		ms_valid <= es_to_ms_valid; 
	end

	if(es_to_ms_valid && ms_allowin) begin 
		es_to_ms_bus_r = es_to_ms_bus;
	end
end

assign mem_res = data_sram_rdata;
assign ms_final_res = ms_res_from_mem ? mem_res
										:ms_alu_res;
 	
endmodule