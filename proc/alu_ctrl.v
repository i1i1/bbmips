`include "defs.v"

module alu_ctrl(i_op, i_func, o_aluctl);
	input	[9:0]	i_func;
	input	[3:0]	i_op;
	output	[3:0]	o_aluctl;

	reg		[3:0]	aluctl;

	assign o_aluctl = aluctl;

	always @ (*) begin
		case (i_op)
			`OP_RTYPE:
				case (i_func)
					`FUNC_JIE:	aluctl <= `ALU_SIE;
					`FUNC_JIL:	aluctl <= `ALU_SIL;
					`FUNC_JIER:	aluctl <= `ALU_SIE;
					`FUNC_JILR:	aluctl <= `ALU_SIL;
					`FUNC_OR:	aluctl <= `ALU_OR;
					`FUNC_AND:	aluctl <= `ALU_AND;
					`FUNC_XOR:	aluctl <= `ALU_XOR;
					`FUNC_NOR:	aluctl <= `ALU_NOR;
					`FUNC_SUB:	aluctl <= `ALU_SUB;
					`FUNC_ADD:	aluctl <= `ALU_ADD;
					`FUNC_MUL:	aluctl <= `ALU_MUL;
					`FUNC_DIV:	aluctl <= `ALU_DIV;
					`FUNC_MOD:	aluctl <= `ALU_MOD;
					`FUNC_SLL:	aluctl <= `ALU_SLL;
					`FUNC_SLA:	aluctl <= `ALU_SLA;
					`FUNC_SRL:	aluctl <= `ALU_SRL;
					`FUNC_SRA:	aluctl <= `ALU_SRA;

					default:	/* Nothing! */;

				endcase
			default:	aluctl <= `ALU_ADD;
		endcase
	end

endmodule
