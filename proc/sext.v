module sext(i_data, i_sign, o_data);
	input	[15:0]	i_data;
	input			i_sign;
	output	[31:0]	o_data;

	wire			tmp;

	assign tmp = (i_sign ? i_data[15] : 0);

	assign o_data = { { 16 { tmp } }, i_data };

endmodule

