`include "defs.v"

module control(i_op, i_func, o_jmp, o_jmprel, o_syscall,
					o_memtoreg, o_insize, o_insign, o_outsize,
						o_memwrite, o_alusrc, o_regwrite, o_extop);
	input	[9:0]	i_func;
	input	[3:0]	i_op;


	output	[2:0]	o_insize, o_outsize;
	output			o_jmp, o_jmprel, o_memtoreg, o_memwrite, o_insign,
									o_syscall, o_alusrc, o_regwrite, o_extop;

	reg				regw;


	assign o_jmp = (i_op == `OP_RTYPE &&
					(i_func == `FUNC_JIE || i_func == `FUNC_JIL));
	assign o_jmprel = (i_op == `OP_RTYPE &&
					(i_func == `FUNC_JIER || i_func == `FUNC_JILR));
	assign o_alusrc = (i_op != `OP_RTYPE);
	assign o_memtoreg = (i_op == `OP_LB || i_op == `OP_LBU ||
						 i_op == `OP_LH || i_op == `OP_LHU ||
						 i_op == `OP_LW);
	assign o_memwrite = (i_op == `OP_STB ||
						 i_op == `OP_STH ||
						 i_op == `OP_STW);
	assign o_regwrite = regw;
	assign o_extop = (i_op == `OP_ADDIU || i_op == `OP_SYSCALL) ? 1'd0 : 1'd1;
	assign o_insize = (i_op == `OP_LB || i_op == `OP_LBU) ? 3'd1 :
						(i_op == `OP_LH || i_op == `OP_LHU) ? 3'd2 :
							(i_op == `OP_LW) ? 3'd4 : 3'd0;
	assign o_insign = (i_op == `OP_LB || i_op == `OP_LH || i_op == `OP_LW) ? 1'd1 : 1'd0;

	assign o_outsize = (i_op == `OP_STB) ? 3'd1 :
							(i_op == `OP_STH) ? 3'd2 :
								(i_op == `OP_STW) ? 3'd4 : 3'd0;
	assign o_syscall = (i_op == `OP_SYSCALL);


	always @ (*) begin
		if (i_op == `OP_RTYPE) begin
			if (i_func == `FUNC_JIE ||
					i_func == `FUNC_JIL  ||
					i_func == `FUNC_JIER ||
					i_func == `FUNC_JILR)
				regw <= 1'd0;
			else
				regw <= 1'd1;
		end else if (i_op == `OP_SYSCALL || i_op == `OP_STB ||
								i_op == `OP_STH || i_op == `OP_STW)
			regw <= 1'd0;
		else
			regw <= 1'd1;
	end

endmodule
