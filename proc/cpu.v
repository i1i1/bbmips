module cpu(i_clk, o_ctl, o_disp);

	input			i_clk;

	output	[7:0]	o_ctl, o_disp;

	reg		[15:0]	tm;
    reg				rst, clock;


    bbmips	bbmips(.i_clk(!i_clk),
				   .i_rst(rst),
				   .o_ctl(o_ctl),
				   .o_disp(o_disp));
	
    initial begin
        rst = 1'b0;
        #70 rst = 1'b1;
    end

/*
	always @(posedge i_clk) begin
		if (tm % 2500 == 0)
			clock <= ~clock;
		tm <= tm + 15'b1;
	end

    initial begin
		tm = 16'b0;
		clock = 1'b0;

        rst = 1'b0;
        #70 rst = 1'b1;
    end
*/
endmodule

