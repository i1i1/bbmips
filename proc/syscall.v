`include "defs.v"

module syscall(i_clk, i_sys, i_run, i_num, i_op1, i_op2, o_run);
	input	[31:0]	i_num, i_op1, i_op2;
	input	[3:0]	i_op;
	input			i_clk, i_sys, i_run;

	output			o_run;

	reg				run;

	assign o_run = run;

	always @ (posedge i_clk) begin
		if (i_sys) begin
			case (i_num)
				0:	begin
					run <= 1'b0;
					$finish();
				end
				2:	begin
					$write("%0d", i_op1);
					run <= i_run;
				end
				3:	begin
					$write("%c",  i_op1);
					run <= i_run;
				end
				default:	run <= i_run;
			endcase
		end else begin
			run <= i_run;
		end
	end

endmodule

