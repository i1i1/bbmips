`include "defs.v"

module rom(i_addr, o_data);
	input	[31:0]	i_addr;
	output	[31:0]	o_data;

	reg		[7:0]	mem[0:`MEM_SIZE - 1];

	initial
			$readmemh("v.out", mem);

	assign o_data = { mem[i_addr],
					  mem[i_addr+1],
					  mem[i_addr+2],
					  mem[i_addr+3] };

endmodule

