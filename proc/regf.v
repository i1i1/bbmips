`include "defs.v"


module regf(i_clk, i_raddr0, i_raddr1, i_raddr2, i_waddr,
						i_wdata, i_we, i_pc, o_rdata0, o_rdata1, o_rdata2);
	input	[31:0]	i_wdata, i_pc;

	input	[5:0]	i_raddr0, i_raddr1, i_raddr2, i_waddr;

	input			i_clk, i_we;

	output	[31:0]	o_rdata0, o_rdata1, o_rdata2;

	reg		[31:0]	regs[1:62];

	/*
	 * There are total 64 registers(from 0 to 63), but the first one is $zero
	 * register which is RO and always contains 0. Last register is $pc register
	 * which is also RO and contains programm counter.
	 */


	assign o_rdata0 = (i_raddr0 == `REG_ZERO) ? 0 :
			((i_raddr0 == `REG_PC) ? i_pc : regs[i_raddr0]);
	assign o_rdata1 = (i_raddr1 == `REG_ZERO) ? 0 :
			((i_raddr1 == `REG_PC) ? i_pc : regs[i_raddr1]);
	assign o_rdata2 = (i_raddr2 == `REG_ZERO) ? 0 :
			((i_raddr2 == `REG_PC) ? i_pc : regs[i_raddr2]);


	initial begin
		regs[01] = 0; regs[02] = 0; regs[03] = 0; regs[04] = 0;
		regs[05] = 0; regs[06] = 0; regs[07] = 0; regs[08] = 0;
		regs[09] = 0; regs[10] = 0; regs[11] = 0; regs[12] = 0;
		regs[13] = 0; regs[14] = 0; regs[15] = 0; regs[16] = 0;
		regs[17] = 0; regs[18] = 0; regs[19] = 0; regs[20] = 0;
		regs[21] = 0; regs[22] = 0; regs[23] = 0; regs[24] = 0;
		regs[25] = 0; regs[26] = 0; regs[27] = 0; regs[28] = 0;
		regs[29] = 0; regs[30] = 0; regs[31] = 0; regs[32] = 0;
		regs[33] = 0; regs[34] = 0; regs[35] = 0; regs[36] = 0;
		regs[37] = 0; regs[38] = 0; regs[39] = 0; regs[40] = 0;
		regs[41] = 0; regs[42] = 0; regs[43] = 0; regs[44] = 0;
		regs[45] = 0; regs[46] = 0; regs[47] = 0; regs[48] = 0;
		regs[49] = 0; regs[50] = 0; regs[51] = 0; regs[52] = 0;
		regs[53] = 0; regs[54] = 0; regs[55] = 0; regs[56] = 0;
		regs[57] = 0; regs[58] = 0; regs[59] = 0; regs[60] = 0;
		regs[61] = 0; regs[62] = 0;
	end

	always @ (posedge i_clk) begin
		if (i_we && i_waddr != `REG_ZERO && i_waddr != `REG_PC)
			regs[i_waddr] <= i_wdata;
	end

endmodule
