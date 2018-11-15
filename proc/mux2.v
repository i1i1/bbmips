module mux2(i_data0, i_data1, i_ctl, o_data);

	input	[31:0] i_data0, i_data1;
	input	i_ctl;

	output	[31:0] o_data;

	assign o_data = i_ctl ? i_data1 : i_data0;

endmodule

