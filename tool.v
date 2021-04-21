module decoder_3_8(
	input	[2:0]	in,
	output	[7:0]	out
	);
	
	genvar i;
	generate
		for(i = 0; i < 8; i = i + 1) begin: gen_for_dec_3_8
			assign out[i] = (in == i);
		end
	endgenerate

endmodule : decoder_3_8

module decoder_4_16(
	input	[3:0]	in,
	output	[15:0]	out
	);
	
	genvar i;
	generate
		for(i = 0; i < 16; i = i + 1) begin: gen_for_dec_4_16
			assign out[i] = (in == i);
		end
	endgenerate

endmodule : decoder_4_16

module decoder_5_32(
	input	[4:0]	in,
	output	[31:0]	out
	);
	
	genvar i;
	generate
		for(i = 0; i < 32; i = i + 1) begin: gen_for_dec_5_32
			assign out[i] = (in == i);
		end
	endgenerate

endmodule : decoder_5_32

module decoder_6_64(
	input	[5:0]	in,
	output	[63:0]	out
	);
	
	genvar i;
	generate
		for(i = 0; i < 64; i = i + 1) begin: gen_for_dec_6_64
			assign out[i] = (in == i);
		end
	endgenerate

endmodule : decoder_6_64