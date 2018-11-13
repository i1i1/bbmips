`define OP_RTYPE	'd0
`define OP_ADDI		'd1
`define OP_ADDIU	'd2
`define OP_LB		'd3
`define OP_LBU		'd4
`define OP_LH		'd5
`define OP_LHU		'd6
`define OP_LW		'd7
`define OP_STB		'd8
`define OP_STH		'd9
`define OP_STW		'd10
`define OP_SYSCALL	'd11

`define	FUNC_JIE	10'h00
`define	FUNC_JIL	10'h01
`define	FUNC_JIER	10'h02
`define	FUNC_JILR	10'h03
`define	FUNC_OR		10'h04
`define	FUNC_AND	10'h05
`define	FUNC_XOR	10'h06
`define	FUNC_NOR	10'h07
`define	FUNC_SUB	10'h08
`define	FUNC_ADD	10'h09
`define	FUNC_MUL	10'h0A
`define	FUNC_DIV	10'h0B
`define	FUNC_MOD	10'h0C
`define	FUNC_SLL	10'h0D
`define	FUNC_SLA	10'h0E
`define	FUNC_SRL	10'h0F
`define	FUNC_SRA	10'h10

// JUST FOR PROCESSOR USAGE
`define	FUNC_ADDI	10'h11
`define	FUNC_NOP	10'h12
//

`define ZERO	regf.r[0]
`define PC		regf.r[63]


//`define TRACE


module ripple_add(output [31:0] s, input [31:0] a, input [31:0] b, input cin);
	wire [32:0] c;

	assign c[0] = cin;

	generate
		genvar i;

		for (i = 0; i < 32; i = i + 1)
		begin : FOR
			assign c[i + 1] = a[i] & (b[i] | c[i]) | b[i] & c[i];
			assign s[i] = a[i] ^ b[i] ^ c[i];
		end
	endgenerate
endmodule

module add(output [31:0] s, input [31:0] a, input [31:0] b);
	ripple_add add_res(s, a, b, 1'b0);
endmodule

module sub(output [31:0] s, input [31:0] a, input [31:0] b);
	ripple_add sub_res(s, a, b ^ 32'hFFFFFFFF, 1'b1);
endmodule

module srl(output [31:0] s, input [31:0] a, input [31:0] b);
	assign s = a >> b;
endmodule

module sra(output [31:0] s, input [31:0] a, input [31:0] b);
	assign s = a >>> b;
endmodule

module sll(output [31:0] s, input [31:0] a, input [31:0] b);
	assign s = a << b;
endmodule

module sla(output [31:0] s, input [31:0] a, input [31:0] b);
	assign s = a <<< b;
endmodule

module and_(output [31:0] s, input [31:0] a, input [31:0] b);
	assign s = a & b;
endmodule

module or_(output [31:0] s, input [31:0] a, input [31:0] b);
	assign s = a | b;
endmodule

module jil(pc_out, pc_in, r0_, r1_, r2_);
	output	[31:0]	pc_out;
	input	[31:0]	pc_in, r0_, r1_, r2_;

	assign pc_out = (r0_ < r1_) ? r2_ : pc_in;
endmodule

module jilr(pc_out, pc_in, r0_, r1_, r2_);
	output	[31:0]	pc_out;
	input	[31:0]	pc_in, r0_, r1_, r2_;

	wire	[31:0]	jmp_res;

	ripple_add	jmp(pc_in, r2_, jmp_res, 1'b0);

	assign pc_out = (r0_ < r1_) ? jmp_res : pc_in;
endmodule

module jie(pc_out, pc_in, r0_, r1_, r2_);
	output	[31:0]	pc_out;
	input	[31:0]	pc_in, r0_, r1_, r2_;

	assign pc_out = (r0_ == r1_) ? r2_ : pc_in;
endmodule

module jier(pc_out, pc_in, r0_, r1_, r2_);
	output	[31:0]	pc_out;
	input	[31:0]	pc_in, r0_, r1_, r2_;

	wire	[31:0]	jmp_res;

	ripple_add	jmp(pc_in, r2_, jmp_res, 1'b0);

	assign pc_out = (r0_ == r1_) ? jmp_res : pc_in;
endmodule

module xor_(output [31:0] s, input [31:0] a, input [31:0] b);
	assign s = a ^ b;
endmodule

module nor_(output [31:0] s, input [31:0] a, input [31:0] b);
	assign s = ~(a | b);
endmodule

module mul(output [31:0] s, input [31:0] a, input [31:0] b);
	assign s = a * b;
endmodule

module div(output [31:0] s, input [31:0] a, input [31:0] b);
	assign s = a / b;
endmodule

module mod(output [31:0] s, input [31:0] a, input [31:0] b);
	assign s = a % b;
endmodule

module alu(in, r0, r1, r2, func, imm, alu_out);
	input			in;
	input	[5:0]	r0, r1, r2;
	input	[9:0]	func;
	input	[31:0]	imm;

	output			alu_out;

	reg		[31:0]	r0_, r1_, r2_;
	wire	[31:0]	res [15:0];
	wire	[31:0]	pc [3:0];

	reg				out;

	assign alu_out = out;

	jie  jie (pc[`FUNC_JIE],  `PC, r0_, r1_, r2_);
	jil  jil (pc[`FUNC_JIL],  `PC, r0_, r1_, r2_);
	jier jier(pc[`FUNC_JIER], `PC, r0_, r1_, r2_);
	jilr jijr(pc[`FUNC_JILR], `PC, r0_, r1_, r2_);

	or_  or_ (res[`FUNC_OR  - 4], r1_, r2_);
	and_ and_(res[`FUNC_AND - 4], r1_, r2_);
	xor_ xor_(res[`FUNC_XOR - 4], r1_, r2_);
	nor_ nor_(res[`FUNC_NOR - 4], r1_, r2_);
	sub  sub (res[`FUNC_SUB - 4], r1_, r2_);
	add  add (res[`FUNC_ADD - 4], r1_, r2_);
	mul  mul (res[`FUNC_MUL - 4], r1_, r2_);
	div  div (res[`FUNC_DIV - 4], r1_, r2_);
	mod  mod (res[`FUNC_MOD - 4], r1_, r2_);
	sll  sll (res[`FUNC_SLL - 4], r1_, r2_);
	sla  sla (res[`FUNC_SLA - 4], r1_, r2_);
	srl  srl (res[`FUNC_SRL - 4], r1_, r2_);
	sra  sra (res[`FUNC_SRA - 4], r1_, r2_);

	add  addi(res[`FUNC_ADDI - 4], r1_, imm);

	integer i;

	always @ (in) begin
		r0_ = regf.r[r0];
		r1_ = regf.r[r1];
		r2_ = regf.r[r2];

		#1;

		if (func < 4)
			`PC = pc[func];
		else if (func != `FUNC_NOP) begin
			regf.r[r0] = res[func-4];

`ifdef TRACE
			$display("");
			$display("imm = %0d func = %0d", imm, func);
			for (i = 4; i < 18; i++)
				$display("res[%0d] = %0d", i, res[i - 4]);
			$display("R[%0d] = %x %x %x", r0, regf.r[r0],
							res[func-4], res[`FUNC_ADDI-4]);
			$display("r0  = %0d r1  = %0d", r0,  r1);
			$display("r0_ = %0d r1_ = %0d imm = %0d", r0_, r1_, imm);
			$display("");
`endif
		end

		out = in;
	end

endmodule

module regf();
	reg		[31:0]	r [63:0];
endmodule

module dec(in, ir, op, r0, r1, r2, imm, func, dec_out);
	input	[31:0]	ir;
	input			in;

	output 	[3:0]	op;
	output	[5:0]	r0, r1, r2;
	output	[9:0]	func;
	output	[31:0]	imm;
	output			dec_out;

	reg	[3:0]	op_;
	reg	[5:0]	r0_, r1_, r2_;
	reg	[9:0]	func_;
	reg	[31:0]	imm_;

	reg			out;

	assign op = op_;
	assign r0 = r0_;
	assign r1 = r1_;
	assign r2 = r2_;
	assign func = func_;
	assign imm = imm_;

	assign dec_out = out;

	always @ (in) begin
		op_ = ir[31:28];
		r0_ = ir[27:22];
		r1_ = ir[21:16];

		case (op)
			`OP_RTYPE: begin
				r2_ = ir[15:10];
				func_ = ir[9:0];
			end
			`OP_ADDIU: begin
				imm_ = zext16(ir[15:0]);
				func_ = `FUNC_ADDI;
			end
			`OP_LBU: begin
				imm_ = zext16(ir[15:0]);
				func_ = `FUNC_ADDI;
			end
			`OP_LHU: begin
				imm_ = zext16(ir[15:0]);
				func_ = `FUNC_ADDI;
			end
			default: begin
				imm_ = sext16(ir[15:0]);
				func_ = `FUNC_ADDI;
			end
		endcase

		out = in;
	end

endmodule

module load(in, op, r0, r1_in, r1_out, imm_in, imm_out, func_in, func_out, load_out);
	input			in;
	input	[3:0]	op;
	input	[9:0]	func_in;
	input	[5:0]	r0, r1_in;

	input	[31:0]	imm_in;
	
	output	[5:0]	r1_out;
	output	[31:0]	imm_out;
	output			load_out;
	output	[9:0]	func_out;

	reg		[5:0]	r1;
	reg		[31:0]	imm;
	reg		[9:0]	func;
	reg				out;


	assign imm_out = imm;
	assign func_out = func;
	assign load_out = out;
	assign r1_out = r1;

	always @ (in) begin
		case (op)
			`OP_LB: begin
				func = `FUNC_ADDI;
				imm = sext8(readb(regf.r[r1_in] + imm_in));
				r1 = `ZERO;
			end
			`OP_LBU: begin
				func = `FUNC_ADDI;
				imm = zext8(readb(regf.r[r1_in] + imm_in));
				r1 = `ZERO;
			end
			`OP_LH: begin
				func = `FUNC_ADDI;
				imm = sext16(readh(regf.r[r1_in] + imm_in));
				r1 = `ZERO;
			end
			`OP_LHU: begin
				func = `FUNC_ADDI;
				imm = zext16(readh(regf.r[r1_in] + imm_in));
				r1 = `ZERO;
			end
			`OP_LW: begin
				func = `FUNC_ADDI;
				imm = readw(regf.r[r1_in] + imm_in);
				r1 = `ZERO;
			end
			`OP_ADDI: begin
				func = func_in;
				imm = imm_in;
				r1 = r1_in;
			end
			`OP_ADDIU: begin
				func = func_in;
				imm = imm_in;
				r1 = r1_in;
			end
			`OP_RTYPE: begin
				func = func_in;
				imm = imm_in;
				r1 = r1_in;
			end
			default: begin
				func = `FUNC_NOP;
				imm = imm_in;
				r1 = r1_in;
			end
		endcase

		out = in;
	end
endmodule

module store(in, op, r0, r1, imm, store_out);
	input		in;
	input	[3:0]	op;
	input	[5:0]	r0, r1;
	input	[31:0]	imm;

	output		store_out;

	reg		out;

	assign store_out = out;

	always @ (in) begin
		case (op)
			`OP_STB:	writeb(regf.r[r1] + imm, regf.r[r0][7:0]);
			`OP_STH:	writeh(regf.r[r1] + imm, regf.r[r0][15:0]);
			`OP_STW:	writeh(regf.r[r1] + imm, regf.r[r0]);
		endcase
		out = in;
	end
endmodule

module syscall(in, op, r0, r1, imm, sys_out);
	input			in;
	input	[3:0]	op;
	input	[5:0]	r0, r1;
	input	[31:0]	imm;

	output			sys_out;

	reg				out;

	assign sys_out = out;

	always @ (in) begin
		if (op == `OP_SYSCALL) begin
			case (imm)
				0: cpu.run = 0;
				1: begin
					$display("Can't get stdin for now!");
					cpu.run = 0;
				end
				2: $write("%0d", regf.r[r0]);
				3: $write("%c",  regf.r[r0][7:0]);
			endcase
		end
		out = in;
	end
endmodule

module cpu();
	parameter	MEMSIZE	= (1 << 10);

	reg		[7:0]	MEM[0:MEMSIZE-1];

	reg		[31:0]	ir;

	wire	[3:0]	op;
	wire	[5:0]	r0, r1[1:0], r2;
	wire	[9:0]	func[1:0];
	wire	[31:0]	imm[1:0];

	reg				run;
	reg				clk;

	wire			out;

	wire			dec_out, load_out, alu_out, store_out;

	reg				num_sig;
	reg		[31:0]	num;

	reg				reg_w, addw;
	reg		[5:0]	reg_n;
	reg		[31:0]	reg_v;


	regf	regf	();

	dec		dec		(clk, ir, op, r0, r1[0], r2, imm[0], func[0], dec_out);
	load	load	(dec_out, op, r0, r1[0], r1[1], imm[0], imm[1], func[0], func[1], load_out);
	alu		alu		(load_out, r0, r1[1], r2, func[1], imm[1], alu_out);
	store	store	(alu_out, op, r0, r1[1], imm[1], store_out);
	syscall syscall	(store_out, op, r0, r1[1], imm[1], out);

	initial begin
		$readmemh("v.out", MEM);
		`PC = 32'd0;

		run = 1;
		clk = 0;
	end

	always @(out) begin
		if (run) begin
			`ZERO = 32'd0;
			ir = readw(`PC);
			`PC = `PC + 4;
			clk = ~clk;
`ifdef TRACE
			print_trace;
`endif
		end
	end


	function [31:0] zext8;
		input [7:0] data;
		
		zext8[31:0] = { { (32 - 8) { 1'b0 } }, data };
	endfunction

	function [31:0] sext8;
		input [7:0] data;
		
		sext8[31:0] = { { (32 - 8) { data[7] } }, data };
	endfunction

	function [31:0] zext16;
		input [15:0] data;
		
		zext16[31:0] = { { (32 - 16) { 1'b0 } }, data };
	endfunction

	function [31:0] sext16;
		input [15:0] data;
		
		sext16[31:0] = { { (32 - 16) { data[15] } }, data };
	endfunction

	task writeb;
		input [31:0] addr;
		input [7:0] data;

		begin
	 		MEM[addr] = data;
		end
	endtask

	task writeh;
		input [31:0] addr;
		input [15:0] data;

		begin
	 		{MEM[addr], MEM[addr+1]} = data;
  		end
  	endtask

	task writew;
		input [31:0] addr;
		input [31:0] data;

		begin
			{MEM[addr], MEM[addr+1], MEM[addr+2], MEM[addr+3]} = data;
		end
	endtask

	function [7:0] readb;
		input [31:0] addr;

		readb[7:0] = MEM[addr];
	endfunction

	function [15:0] readh;
		input [31:0] addr;

		readh[15:0] = { MEM[addr], MEM[addr+1] };
	endfunction

	function [31:0] readw;
		input [31:0] addr;

		readw[31:0] = {MEM[addr], MEM[addr+1], MEM[addr+2], MEM[addr+3]};
	endfunction

	task print_trace;
		integer i;
		integer j;
		integer k;
		begin
			begin
				$display("PC=%h\tOPCODE=%d\tIR=%x",
						`PC, op, ir);

				k = 0;
				for (i = 0; i < 64; i = i + 4)
				begin
					$write("R[%02d]: ", k);
					for (j = 0; j <= 3; j = j + 1)
					begin
						$write(" %h", regf.r[k]);
						k = k + 1;
					end
					$write("\n");
				end
				$write("\n");
			end
		end
	endtask // print_trace

endmodule

