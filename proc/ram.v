`include "defs.v"

module ram(i_clk, i_addr, i_insize, i_insign, i_outsize, i_data, o_data);
	input	[31:0]	i_addr, i_data;
	input	[2:0]	i_insize, i_outsize;
	input			i_clk, i_insign;

	output	[31:0]	o_data;

	reg		[7:0]	mem[0:`MEM_SIZE - 1];

	wire			sign;

	assign sign = i_insign & mem[i_addr][7];

	assign o_data = ((i_insize == 3'd4) ? ({ mem[i_addr], mem[i_addr+1],
											  mem[i_addr+2], mem[i_addr+3] }) :
						((i_insize == 3'd2) ? { { 16 { sign } }, mem[i_addr], mem[i_addr+1] } :
							((i_insize == 3'd1) ? { { 24 { sign } }, mem[i_addr] } : 32'd0)));

	initial
			$readmemb("b.out", mem);

	always @ (posedge i_clk) begin
		if (i_outsize == 3'd4)
				{ mem[i_addr],
				  mem[i_addr+1],
				  mem[i_addr+2],
				  mem[i_addr+3] } <= i_data;
		else if (i_outsize == 3'd2)
				{ mem[i_addr], mem[i_addr+1] } <= i_data[15:0];
		else if (i_outsize == 3'd1)
				mem[i_addr] <= i_data[7:0];
	end

endmodule

