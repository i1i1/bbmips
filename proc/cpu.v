module cpu(i_clk, i_rst, o_ctl, o_disp);

	input			i_clk, i_rst;

	output	[7:0]	o_ctl, o_disp;

	reg		[15:0]	tm;
    reg				clock;


    bbmips	bbmips(.i_clk(clock),
				   .i_rst(i_rst),
				   .o_ctl(o_ctl),
				   .o_disp(o_disp));


	always @(posedge i_clk) begin
		if (tm % 2500 == 0)
			clock <= ~clock;
		tm <= tm + 15'b1;
	end

    initial begin
		tm = 16'b0;
		clock = 1'b0;
    end

endmodule

