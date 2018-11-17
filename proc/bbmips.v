module bbmips(i_clk, i_rst, o_ctl, o_disp);

	input			i_clk, i_rst;

	output	[7:0]	o_ctl, o_disp;

	wire	[31:0]	pc, pc_rel, pc_inc_res, instr, memtoreg_mux_out;
	wire	[31:0]	sext_out, jmp_mux_out, next_pc_mux_out, ram_out, alu_res;
	wire	[31:0]	bus_a, bus_b, bus_c, alu_src_mux_out;

	wire	[15:0]	imm;
	wire	[9:0]	func;
	wire	[5:0]	r0, r1, r2;
	wire	[3:0]	op, alu_ctl;

	wire	[2:0]	in_size, out_size;

	wire			regwrite, jmp, jmp_rel, memtoreg, alusrc, extop, in_sign;

	assign op   = instr[31:28];
	assign r0   = instr[27:22];
	assign r1   = instr[21:16];
	assign r2   = instr[15:10];
	assign func = instr[ 9: 0];
	assign imm  = instr[15: 0];


	pc			pc_(.i_clk(i_clk),
				    .i_rst(i_rst),
				    .i_pc(next_pc_mux_out),
				    .o_pc(pc));

	adder		pc_inc(.i_op1(pc),
					   .i_op2(32'd4),
					   .o_res(pc_inc_res));

	rom			rom(.i_addr(pc),
				    .o_data(instr));

	regf		regf(.i_clk(i_clk),
					 .i_raddr0(r0),
					 .i_raddr1(r1),
					 .i_raddr2(r2),
					 .i_waddr(r0),
					 .i_wdata(memtoreg_mux_out),
					 .i_we(regwrite),
					 .i_pc(next_pc_mux_out),
					 .o_rdata0(bus_a),
					 .o_rdata1(bus_b),
					 .o_rdata2(bus_c));

	control		control(.i_op(op),
						.i_func(func),
						.o_jmp(jmp),
						.o_jmprel(jmp_rel),
						.o_memtoreg(memtoreg),
						.o_insize(in_size),
						.o_insign(in_sign),
						.o_outsize(out_size),
						.o_alusrc(alusrc),
						.o_regwrite(regwrite),
						.o_extop(extop));
	
	wire sign = extop ? imm[15] : 1'd0;

	sext		sext(.i_data(imm),
					 .i_sign(sign),
					 .o_data(sext_out));

	mux2		alu_src_mux(.i_data0(bus_c),
							.i_data1(sext_out),
							.i_ctl(alusrc),
							.o_data(alu_src_mux_out));

	alu_ctrl	alu_ctrl(.i_op(op),
						 .i_func(func),
						 .o_aluctl(alu_ctl));

	alu			alu(.i_op1(bus_b),
					.i_op2(alu_src_mux_out),
					.i_ctl(alu_ctl),
					.o_res(alu_res));

	ram			ram(.i_clk(i_clk),
					.i_addr(alu_res),
					.i_insize(in_size),
					.i_insign(in_sign),
					.i_outsize(out_size),
					.i_data(bus_c),
					.o_data(ram_out));

	syscall		syscall(.i_clk(i_clk),
						.i_op(op),
						.i_num(alu_src_mux_out),
						.i_op1(bus_a),
						.i_op2(bus_b),
						.o_ctl(o_ctl),
						.o_disp(o_disp));

	mux2		memtoreg_mux(.i_data0(alu_res),
							 .i_data1(ram_out),
							 .i_ctl(memtoreg),
							 .o_data(memtoreg_mux_out));

	adder		pc_relat(.i_op1(pc_inc_res),
						 .i_op2(bus_a),
						 .o_res(pc_rel));

	mux2		jmp_mux(.i_data0(bus_a),
						.i_data1(pc_rel),
						.i_ctl(jmp_rel),
						.o_data(jmp_mux_out));

	mux2		next_pc_mux(.i_data0(pc_inc_res),
							.i_data1(jmp_mux_out),
							.i_ctl((jmp | jmp_rel) &
									(alu_res == 32'b1)),
							.o_data(next_pc_mux_out));


endmodule

