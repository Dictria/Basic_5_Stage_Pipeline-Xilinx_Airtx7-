module alu(
	input  [11:0]	alu_op		,
	input  [31:0]	alu_src1	,
	input  [31:0]	alu_src2    ,
	output [31:0]	alu_res
	);
	
	wire op_add ;
	wire op_sub ;
	wire op_slt ;
	wire op_sltu;
	wire op_and ;
	wire op_nor ;
	wire op_or  ;
	wire op_xor ;
	wire op_sll ;	// Shift Word Left Logical
	wire op_srl ;	// Shift Word Right Logical
	wire op_sra ;	// Shift Word Right Arithmetic
	wire op_lui ;

	assign op_add  = alu_op[ 0];
	assign op_sub  = alu_op[ 1];
	assign op_slt  = alu_op[ 2];
	assign op_sltu = alu_op[ 3];
	assign op_and  = alu_op[ 4];
	assign op_nor  = alu_op[ 5];
	assign op_or   = alu_op[ 6];
	assign op_xor  = alu_op[ 7];
	assign op_sll  = alu_op[ 8];
	assign op_srl  = alu_op[ 9];
	assign op_sra  = alu_op[10];
	assign op_lui  = alu_op[11];
	wire [31:0]	add_sub_res;
	wire [31:0]	slt_res ;
	wire [31:0]	sltu_res;
	wire [31:0]	and_res ;
	wire [31:0]	nor_res ;
	wire [31:0]	or_res  ;
	wire [31:0]	xor_res ;
	wire [31:0]	sll_res ;
	wire [31:0]	srl_res ;
	wire [31:0]	sra_res ;
	wire [31:0]	lui_res ;
	// adder
	wire [31:0]	adder_a;
	wire [31:0] adder_b;
	wire 		adder_cin;
	wire		adder_cout;
	wire [31:0]	adder_res;
	assign adder_a = alu_src1;
	assign adder_b   = (op_sub | op_slt | op_sltu) ? ~alu_src2 : alu_src2;
	assign adder_cin = (op_sub | op_slt | op_sltu) ? 1'b1 : 1'b0;
	assign {adder_cout, adder_res} = adder_a + adder_b + adder_cin;
	// ADD, SUB
	assign add_sub_res = adder_res;
	// SLT
	assign slt_res[31:1] = 31'b0;
	assign slt_res[0] = (alu_src1[31] & ~alu_src2[31]) | (~(alu_src1[31] ^ alu_src2[31]) & adder_res[31]);
	// SLTU
	assign sltu_res[31:1] = 31'b0;
	assign sltu_res[0] = ~adder_cout;
	// bit operation
	assign and_res = alu_src1 & alu_src2;
	assign nor_res = ~(alu_src1 | alu_src2);
	assign or_res  = alu_src1 | alu_src2;
	assign xor_res = alu_src1 ^ alu_src2;
	assign lui_res = {alu_src2[15:0],16'b0};
	// 
	wire [31:0] shft_src;
	wire [31:0] sra_mask;
	wire [31:0] shft_res;
	assign shft_src = op_sll ? {alu_src1[ 0], alu_src1[ 1], alu_src1[ 2], alu_src1[ 3],
								alu_src1[ 4], alu_src1[ 5], alu_src1[ 6], alu_src1[ 7],
								alu_src1[ 8], alu_src1[ 9], alu_src1[10], alu_src1[11],
								alu_src1[12], alu_src1[13], alu_src1[14], alu_src1[15],
								alu_src1[16], alu_src1[17], alu_src1[18], alu_src1[19],
								alu_src1[20], alu_src1[21], alu_src1[22], alu_src1[23],
								alu_src1[24], alu_src1[25], alu_src1[26], alu_src1[27],
								alu_src1[28], alu_src1[29], alu_src1[30], alu_src1[31]}
							: alu_src1;
	assign sra_mask = ~(32'hffff_ffff >> alu_src2[4:0]);
	assign shft_res = shft_src >> alu_src2[4:0];

	assign srl_res = shft_res;
	assign sra_res = ({32{alu_src1[31]}} & sra_mask) | shft_res;
	assign sll_res = {shft_res[ 0], shft_res[ 1], shft_res[ 2], shft_res[ 3],
						 shft_res[ 4], shft_res[ 5], shft_res[ 6], shft_res[ 7],
						 shft_res[ 8], shft_res[ 9], shft_res[10], shft_res[11],
						 shft_res[12], shft_res[13], shft_res[14], shft_res[15],
						 shft_res[16], shft_res[17], shft_res[18], shft_res[19],
						 shft_res[20], shft_res[21], shft_res[22], shft_res[23],
						 shft_res[24], shft_res[25], shft_res[26], shft_res[27],
						 shft_res[28], shft_res[29], shft_res[30], shft_res[31]};
	// final MUX
	assign alu_res = ({32{op_add | op_sub}} & add_sub_res)
					|({32{op_slt         }} & slt_res)
					|({32{op_sltu		 }} & sltu_res)
					|({32{op_and		 }} & and_res)
					|({32{op_nor		 }} & nor_res)
					|({32{op_or 		 }} & or_res)
					|({32{op_xor		 }} & xor_res)
					|({32{op_lui  		 }} & lui_res)
					|({32{op_srl		 }} & srl_res)
					|({32{op_sra		 }} & sra_res)
					|({32{op_sll		 }} & sll_res);

endmodule