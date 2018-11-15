module adder(i_op1, i_op2, o_res);
	input	[31:0]	i_op1, i_op2;
	output	[31:0]	o_res;

	assign o_res = i_op1 + i_op2;

endmodule

