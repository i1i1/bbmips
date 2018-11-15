`include "defs.v"

module alu(i_op1, i_op2, i_ctl, o_res);
	input	[31:0]	i_op1, i_op2;
	input	[3:0]	i_ctl;

	output	[31:0]	o_res;

	reg		[31:0]	res;


	assign o_res = res;

	always @ (*) begin
		case (i_ctl)
			`ALU_OR:		res <= i_op1 | i_op2;
			`ALU_AND:		res <= i_op1 & i_op2;
			`ALU_XOR:		res <= i_op1 ^ i_op2;
			`ALU_NOR:		res <= ~(i_op1 | i_op2);
			`ALU_SUB:		res <= i_op1 - i_op2;
			`ALU_ADD:		res <= i_op1 + i_op2;
			`ALU_MUL:		res <= i_op1 * i_op2;
			`ALU_DIV:		res <= i_op1 / i_op2;
			`ALU_MOD:		res <= i_op1 % i_op2;
			`ALU_SLL:		res <= i_op1 << i_op2;
			`ALU_SLA:		res <= i_op1 <<< i_op2;
			`ALU_SRL:		res <= i_op1 >> i_op2;
			`ALU_SRA:		res <= i_op1 >>> i_op2;
			`ALU_SIE:		res <= i_op1 == i_op2;
			`ALU_SIL:		res <= i_op1 < i_op2;
		endcase
	end

endmodule

