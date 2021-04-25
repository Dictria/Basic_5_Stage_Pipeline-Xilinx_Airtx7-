`include "defination.h"

module if_stage(
	input 								clk			   ,
	input 								reset		   ,

	input 								ds_allowin	   ,
	
	input	[`JUMP_BUS_WD 	  -1:0]		jump_bus 	   ,
	// to ds
	output 								fs_to_ds_valid ,
	output	[`FS_TO_DS_BUS_WD -1:0]		fs_to_ds_bus   ,
	
	// instr SRAM interface
	output		  instr_sram_en   ,
	output [ 3:0] instr_sram_wen  ,
	output [31:0] instr_sram_addr ,
	output [31:0] instr_sram_wdata,
	input  [31:0] instr_sram_rdata
	)
	
	reg	fs_valid;
	wire fs_ready_go;
	wire fs_allow_in;
	wire to_fs_valid;
	
	wire [31:0] seq_pc;
	wire [31:0] next_pc;

	wire jump_taken;
	wire [31:0] jump_target;
	assign {jump_taken,jump_target} = jump_bus;
	
	wire [31:0] fs_instr;
	reg  [31:0] fs_pc;
	assign fs_to_ds_bus = {fs_instr,
							fs_pc};

	// pre_IF stage
	assign to_fs_valid = ~reset;
	assign seq_pc      = fs_pc + 4;
	assign next_pc     = jump_taken ? jump_target : seq_pc;
	// IF stage
	assign fs_ready_go    = 1'b1;
	assign fs_allow_in    = !fs_valid || fs_ready_go && ds_allowin;
	assign fs_to_ds_valid = fs_valid && fs_ready_go;

	always @(posedge clk) begin 
		if(reset) begin 
			fs_valid <= 1'b0;
		end
		else if(fs_allow_in) begin 
			fs_valid <= to_fs_valid;
		end

		if(reset) begin 
			fs_pc <= 32'hbfbf_fffc;
		end
		else if(to_fs_valid && fs_allow_in) begin 
			fs_pc <= next_pc;
		end
	end 

	assign instr_sram_en    = to_fs_valid && fs_allow_in;
	assign instr_sram_wen   = 4'h0;
	assign instr_sram_addr  = next_pc;
	assign instr_sram_wdata = 32'b0;

	assign fs_instr = instr_sram_rdata;

endmodule