`include "defs.v"

module alu(i_op1, i_op2, i_ctl, o_res);
	input	[31:0]	i_op1, i_op2;
	input	[3:0]	i_ctl;

	output	[31:0]	o_res;

	wire	[31:0]	res [0:15];


	assign o_res = res[i_ctl];

	assign res[`ALU_OR ] = i_op1 | i_op2;
	assign res[`ALU_AND] = i_op1 & i_op2;
	assign res[`ALU_XOR] = i_op1 ^ i_op2;
	assign res[`ALU_NOR] = ~(i_op1 | i_op2);
	assign res[`ALU_SUB] = i_op1 - i_op2;
	assign res[`ALU_ADD] = i_op1 + i_op2;
	assign res[`ALU_MUL] = i_op1 * i_op2;
	assign res[`ALU_DIV] = i_op1 / i_op2;
	assign res[`ALU_MOD] = i_op1 % i_op2;
	assign res[`ALU_SLL] = i_op1 << i_op2;
	assign res[`ALU_SLA] = i_op1 <<< i_op2;
	assign res[`ALU_SRL] = i_op1 >> i_op2;
	assign res[`ALU_SRA] = i_op1 >>> i_op2;
	assign res[`ALU_SIE] = (i_op1 == i_op2 ? 32'b1 : 32'b0);
	assign res[`ALU_SIL] = (i_op1 < i_op2 ? 32'b1 : 32'b0);

	assign res[4'hF] = 0;

endmodule
