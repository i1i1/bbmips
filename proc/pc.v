module pc(i_clk, i_rst, i_pc, o_pc);

	input			i_clk, i_rst;
	input	[31:0]	i_pc;

	output	[31:0]	o_pc;

	reg		[31:0]	pc;

	assign o_pc = pc;

	always @ (posedge i_clk) begin
		if (!i_rst)
			pc <= 32'b0;
		else
			pc <= i_pc;
	end

endmodule
