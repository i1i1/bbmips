module pc(i_clk, i_rst, i_run, i_pc, o_run, o_pc);

	input	[31:0]	i_pc;
	input			i_clk, i_rst, i_run;

	output	[31:0]	o_pc;
	output			o_run;

	reg		[31:0]	pc;
	reg				run;

	assign o_pc = pc;
	assign o_run = run;

	always @ (posedge i_clk) begin
		if (i_rst) begin
			pc <= 32'b0;
			run <= 1'b1;
		end else begin
			if (i_run)
				pc <= i_pc;
			run <= i_run;
		end
	end

endmodule
