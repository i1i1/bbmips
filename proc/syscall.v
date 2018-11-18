`include "defs.v"

module disp (i_clk, i_val, o_ctl, o_leds);

	input	[31:0]	i_val;
	input 			i_clk;

	output	[7:0]	o_ctl, o_leds;

	reg		[2:0]	ctl = 0;

	wire	[7:0]	nums [0:16];
	wire	[4:0]	digs [0:7];
	wire	[4:0]	dig;

	assign nums[5'h0] = 8'b00111111;
	assign nums[5'h1] = 8'b00000110;
	assign nums[5'h2] = 8'b01011011;
	assign nums[5'h3] = 8'b01001111;
	assign nums[5'h4] = 8'b01100110;
	assign nums[5'h5] = 8'b01101101;
	assign nums[5'h6] = 8'b01111101;
	assign nums[5'h7] = 8'b00000111;
	assign nums[5'h8] = 8'b01111111;
	assign nums[5'h9] = 8'b01101111;
	assign nums[5'hA] = 8'b11110111;
	assign nums[5'hB] = 8'b11111111;
	assign nums[5'hC] = 8'b10111001;
	assign nums[5'hD] = 8'b10111111;
	assign nums[5'hE] = 8'b11111001;
	assign nums[5'hF] = 8'b11110001;

	parameter D_EMPTY_CODE = 5'd16;

	assign nums[D_EMPTY_CODE] = 8'b00000000;

	assign digs[4'd0] = { 1'b0, i_val[ 3: 0] };
	assign digs[4'd1] = i_val[31: 4] ? { 1'b0, i_val[ 7: 4] } : D_EMPTY_CODE;
	assign digs[4'd2] = i_val[31: 8] ? { 1'b0, i_val[11: 8] } : D_EMPTY_CODE;
	assign digs[4'd3] = i_val[31:12] ? { 1'b0, i_val[15:12] } : D_EMPTY_CODE;
	assign digs[4'd4] = i_val[31:16] ? { 1'b0, i_val[19:16] } : D_EMPTY_CODE;
	assign digs[4'd5] = i_val[31:20] ? { 1'b0, i_val[23:20] } : D_EMPTY_CODE;
	assign digs[4'd6] = i_val[31:24] ? { 1'b0, i_val[27:24] } : D_EMPTY_CODE;
	assign digs[4'd7] = i_val[31:28] ? { 1'b0, i_val[31:28] } : D_EMPTY_CODE;


	assign o_ctl = ~(8'b1 << ctl);
	assign o_leds = ~nums[dig];
	assign dig = digs[ctl];

	always @(posedge i_clk)
		ctl <= ctl + 3'd1;

endmodule

module syscall(i_clk, i_sys, i_num, i_op1, i_op2, i_run, o_run, o_ctl, o_disp);
	input	[31:0]	i_num, i_op1, i_op2;
	input			i_clk, i_sys, i_run;

	output	[7:0]	o_ctl, o_disp;
	output			o_run;

	reg		[31:0]	val;
	reg				first_run = 1'b0;
	reg				run;


	disp	disp(.i_clk(first_run & i_clk),
				 .i_val(val),
				 .o_ctl(o_ctl),
				 .o_leds(o_disp));


	always @ (posedge i_clk) begin
		if (i_sys) begin
			case (i_num)
				0: run <= 1'b0;
				2: begin
					first_run <= 1;
					val <= i_op1;
					run <= i_run;
				end
				default: run <= i_run;
			endcase
		end else begin
			run <= i_run;
		end
	end

endmodule
