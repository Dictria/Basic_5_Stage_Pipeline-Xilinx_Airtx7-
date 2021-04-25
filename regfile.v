module regfile (
	input clk,
	//read port 1
	input [4:0] raddr1,
	output [31:0] rdata1,
	//read port 2
	input [4:0] raddr2,
	output [31:0] rdata2,
	//write port
	input we,
	input [4:0] waddr,
	input [31:0] wdata
);

reg [31:0] rf[31:0];
always @(posedge clk) begin 
	if(we && waddr != 5'd0) begin 
		rf[waddr] <= wdata;
	end
end
//read 1
assign rdata1 = rf[raddr1];
//read2
assign rdata2 = rf[raddr2];

endmodule