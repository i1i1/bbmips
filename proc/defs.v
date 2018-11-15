`ifndef _DEFS_V_
`define _DEFS_V_

`define	MEM_SIZE	(1 << 11)

`define OP_RTYPE		4'h0
`define OP_ADDI			4'h1
`define OP_ADDIU		4'h2
`define OP_LB			4'h3
`define OP_LBU			4'h4
`define OP_LH			4'h5
`define OP_LHU			4'h6
`define OP_LW			4'h7
`define OP_STB			4'h8
`define OP_STH			4'h9
`define OP_STW			4'hA
`define OP_SYSCALL		4'hB

`define FUNC_JIE		10'h0
`define FUNC_JIL		10'h1
`define FUNC_JIER		10'h2
`define FUNC_JILR		10'h3
`define FUNC_OR			10'h4
`define FUNC_AND		10'h5
`define FUNC_XOR		10'h6
`define FUNC_NOR		10'h7
`define FUNC_SUB		10'h8
`define FUNC_ADD		10'h9
`define FUNC_MUL		10'hA
`define FUNC_DIV		10'hB
`define FUNC_MOD		10'hC
`define FUNC_SLL		10'hD
`define FUNC_SLA		10'hE
`define FUNC_SRL		10'hF
`define FUNC_SRA		10'h10

`define ALU_OR			4'h0
`define ALU_AND			4'h1
`define ALU_XOR			4'h2
`define ALU_NOR			4'h3
`define ALU_SUB			4'h4
`define ALU_ADD			4'h5
`define ALU_MUL			4'h6
`define ALU_DIV			4'h7
`define ALU_MOD			4'h8
`define ALU_SLL			4'h9
`define ALU_SLA			4'hA
`define ALU_SRL			4'hB
`define ALU_SRA			4'hC
`define ALU_SIE			4'hD
`define ALU_SIL			4'hE

`define REG_ZERO		6'd0
`define REG_PC			6'd63

`endif /* _DEFS_V_ */

