`include "defs.v"

module disp (i_clk, i_val, o_ctl, o_leds);

	input [31:0]	i_val;
	input 			i_clk;

	output	[7:0]	o_ctl, o_leds;


	reg		[7:0]	leds;
	reg		[4:0]	dig;
	reg		[2:0]	ctl = 0;

	wire	[31:0]	digs;


	//  ###0###
	// #       #
	// #       #
	// 5       1
	// #       #
	// #       #
	//  ###6###
	// #       #
	// #       #
	// 4       2
	// #       # ###
	// #       # #7#
	//  ###3###  ###


	parameter D_0 = 8'b00111111;
	parameter D_1 = 8'b00000110;
	parameter D_2 = 8'b01011011;
	parameter D_3 = 8'b01001111;
	parameter D_4 = 8'b01100110;
	parameter D_5 = 8'b01101101;
	parameter D_6 = 8'b01111101;
	parameter D_7 = 8'b00000111;
	parameter D_8 = 8'b01111111;
	parameter D_9 = 8'b01101111;
	parameter D_A = 8'b11110111;
	parameter D_B = 8'b11111111;
	parameter D_C = 8'b10111001;
	parameter D_D = 8'b10111111;
	parameter D_E = 8'b11111001;
	parameter D_F = 8'b11110001;

	parameter D_EMPTY = 8'b00000000;

	parameter D_EMPTY_CODE = 5'd31;


	assign digs = i_val;
	assign o_ctl = ~(8'b1 << ctl);
	assign o_leds = ~leds;


	always @(posedge i_clk)
	begin
		case (dig)
			0:	leds <= D_0;
			1:	leds <= D_1;
			2:	leds <= D_2;
			3:	leds <= D_3;
			4:	leds <= D_4;
			5:	leds <= D_5;
			6:	leds <= D_6;
			7:	leds <= D_7;
			8:	leds <= D_8;
			9:	leds <= D_9;
			10:	leds <= D_A;
			11:	leds <= D_B;
			12:	leds <= D_C;
			13:	leds <= D_D;
			14:	leds <= D_E;
			15:	leds <= D_F;
			default: leds <= D_EMPTY;
		endcase

		case(ctl)
			0: dig <= digs[ 3: 0];
			1: dig <= digs[31: 4] ? { 1'b0, digs[ 7: 4] } : D_EMPTY_CODE;
			2: dig <= digs[31: 8] ? { 1'b0, digs[11: 8] } : D_EMPTY_CODE;
			3: dig <= digs[31:12] ? { 1'b0, digs[15:12] } : D_EMPTY_CODE;
			4: dig <= digs[31:16] ? { 1'b0, digs[19:16] } : D_EMPTY_CODE;
			5: dig <= digs[31:20] ? { 1'b0, digs[23:20] } : D_EMPTY_CODE;
			6: dig <= digs[31:24] ? { 1'b0, digs[27:24] } : D_EMPTY_CODE;
			7: dig <= digs[31:28] ? { 1'b0, digs[31:28] } : D_EMPTY_CODE;
		endcase

		ctl <= ctl + 3'd1;

	end

endmodule

module syscall(i_clk, i_op, i_num, i_op1, i_op2, o_ctl, o_disp);
	input	[31:0]	i_num, i_op1, i_op2;
	input	[3:0]	i_op;
	input			i_clk;

	output	[7:0]	o_ctl, o_disp;

	reg		[31:0]	val;
	reg				first_run = 1'b0;


	disp	disp(.i_clk(first_run & i_clk),
				 .i_val(i_val),
				 .o_ctl(o_ctl),
				 .o_leds(o_disp));


	always @ (posedge i_clk) begin
		if (i_op == `OP_SYSCALL && i_num == 32'd2) begin
			first_run <= 1'b1;
			val <= i_op1;
		end
	end

endmodule
