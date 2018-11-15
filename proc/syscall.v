`include "defs.v"

module syscall(i_clk, i_op, i_num, i_op1, i_op2);
	input	[31:0]	i_num, i_op1, i_op2;
	input	[3:0]	i_op;
	input			i_clk;


	always @ (posedge i_clk) begin
		if (i_op == `OP_SYSCALL) begin
			case (i_num)
				2:	$write("%0d", i_op1); //$write("print '%0d'\n", i_op1);
				3:	$write("%c",  i_op1); //$write("print '%c' (%x)\n", i_op1, i_op1);
			endcase
		end
	end
endmodule

