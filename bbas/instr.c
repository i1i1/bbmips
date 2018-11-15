#include "instr.h"

#define ZERO	0
#define AT	1
#define SP	62
#define PC	63


void
putop(char *src, uint32_t op)
{
	src[3] = op % 256;
	op /= 256;
	src[2] = op % 256;
	op /= 256;
	src[1] = op % 256;
	op /= 256;
	src[0] = op % 256;
}

#define OPCODE_REG(op, func, name) \
int \
name(char *src, int len, \
        unsigned r0, unsigned r1, unsigned r2, uint16_t n, \
        uint32_t addr) \
{                         \
	uint32_t res;         \
	(void) n;             \
	(void) addr;          \
                          \
	if (len < 4)          \
		return 0;         \
	len -= 4;             \
                          \
	res  = ((op) << 28);  \
	res |= ((r0) << 22);  \
	res |= ((r1) << 16);  \
	res |= ((r2) << 10);  \
	res |= (func);        \
                          \
    putop(src, res);      \
	return 4;             \
}

#define OPCODE_IMM(op, func, name) \
int \
name(char *src, int len, \
        unsigned r0, unsigned r1, unsigned r2, uint16_t n, \
        uint32_t addr) \
{                         \
	uint32_t res;         \
	(void) r2;            \
	(void) addr;          \
                          \
	if (len < 4)          \
		return 0;         \
	len -= 4;             \
                          \
	res  = ((op) << 28);  \
	res |= ((r0) << 22);  \
	res |= ((r1) << 16);  \
	res |= n;             \
                          \
    putop(src, res);      \
	return 4;             \
}

OPCODE_REG( 0, 0,  op_jie)
OPCODE_REG( 0, 1,  op_jil)
OPCODE_REG( 0, 2,  op_jier)
OPCODE_REG( 0, 3,  op_jilr)
OPCODE_REG( 0, 4,  op_or)
OPCODE_REG( 0, 5,  op_and)
OPCODE_REG( 0, 6,  op_xor)
OPCODE_REG( 0, 7,  op_nor)
OPCODE_REG( 0, 8,  op_sub)
OPCODE_REG( 0, 9,  op_add)
OPCODE_REG( 0, 10, op_mul)
OPCODE_REG( 0, 11, op_div)
OPCODE_REG( 0, 12, op_mod)
OPCODE_REG( 0, 13, op_sll)
OPCODE_REG( 0, 14, op_sla)
OPCODE_REG( 0, 15, op_srl)
OPCODE_REG( 0, 16, op_sra)

OPCODE_IMM( 1, 0,  op_addi)
//        ( 2, 0,  op_addiu)
OPCODE_IMM( 3, 0,  op_lb)
OPCODE_IMM( 4, 0,  op_lbu)
OPCODE_IMM( 5, 0,  op_lh)
OPCODE_IMM( 6, 0,  op_lhu)
OPCODE_IMM( 7, 0,  op_lw)
OPCODE_IMM( 8, 0,  op_stb)
OPCODE_IMM( 9, 0,  op_sth)
OPCODE_IMM(10, 0,  op_stw)
OPCODE_IMM(11, 0,  op_syscall)


#undef OPCODE_REG
#undef OPCODE_IMM

int
op_addiu(char *src, int len,
        unsigned r0, unsigned r1, unsigned r2, uint16_t n,
        uint32_t addr)
{
	uint32_t res;
	(void) r2;
	(void) addr;

	if (len < 4)
		return 0;
	len -= 4;

	res  = (2 << 28);
	res |= (r0 << 22);
	res |= (r1 << 16);
	res |= n;

	putop(src, res);
	return 4;
}

#define OP(x) do { \
	int d; \
	d = x; \
	len -= d; \
	src += d; \
} while (0)

int
op_la(char *src, int len,
        unsigned r0, unsigned r1, unsigned r2, uint16_t n,
        uint32_t addr)
{
	(void) r1;
	(void) r2;
	(void) n;

	if (len < 16)
		return 0;

	/*
	 * addi $r0,	$zero,	addr >> 16
	 * addi	$at,	$zero,	16
	 * sll	$r0,	$r0,	$at
	 * addi $r0,	$zero,	addr % (1 << 16)
	 */

	OP(op_addiu(src, len, r0, ZERO, 0, addr >> 16, 0));
	OP(op_addi(src, len, AT, ZERO, 0, 16, 0));
	OP(op_sll(src, len, r0, r0, AT, 0, 0));
	OP(op_addiu(src, len, r0, ZERO, 0,addr % (1 << 16), 0));

	return 16;
}

int
op_jal(char *src, int len,
        unsigned r0, unsigned r1, unsigned r2, uint16_t n,
        uint32_t addr)
{
	(void) r1;
	(void) r2;
	(void) n;

	if (len < 28)
		return 0;

	/*
	 * la	$r0,	addr
	 * add	$at,	$r0,	$zer0
	 * addi $r0,	$pc,	4
	 * jie	$at,	$zero,	$zero
	 */

	OP(op_la(src, len, r0, 0, 0, 0, addr));
	OP(op_add(src, len, AT, r0, ZERO, 0, 0));
	OP(op_addi(src, len, r0, PC, 0, 4, 0));
	OP(op_jie(src, len, AT, ZERO, ZERO, 0, 0));

	return 28;
}

#define OPCODE(str_, size_, toop_, fmt_) \
{ \
	.str  = (str_),  \
	.size = (size_), \
	.toop = (toop_), \
	.fmt  = (fmt_),  \
},

struct opcode ops[] = {
	OPCODE("jie",   4, op_jie,   FMT_R_R_R)
	OPCODE("jil",   4, op_jil,   FMT_R_R_R)
	OPCODE("jier",  4, op_jier,  FMT_R_R_R)
	OPCODE("jilr",  4, op_jilr,  FMT_R_R_R)
	OPCODE("or",    4, op_or,    FMT_R_R_R)
	OPCODE("and",   4, op_and,   FMT_R_R_R)
	OPCODE("xor",   4, op_xor,   FMT_R_R_R)
	OPCODE("nor",   4, op_nor,   FMT_R_R_R)
	OPCODE("sub",   4, op_sub,   FMT_R_R_R)
	OPCODE("add",   4, op_add,   FMT_R_R_R)
	OPCODE("mul",   4, op_mul,   FMT_R_R_R)
	OPCODE("div",   4, op_div,   FMT_R_R_R)
	OPCODE("mod",   4, op_mod,   FMT_R_R_R)
	OPCODE("sll",   4, op_sll,   FMT_R_R_R)
	OPCODE("sla",   4, op_sla,   FMT_R_R_R)
	OPCODE("srl",   4, op_srl,   FMT_R_R_R)
	OPCODE("sra",   4, op_sra,   FMT_R_R_R)
	OPCODE("addi",  4, op_addi,  FMT_R_R_N)
	OPCODE("addiu", 4, op_addiu, FMT_R_R_N)
	OPCODE("lb",    4, op_lb,    FMT_R_N_R)
	OPCODE("lbu",   4, op_lbu,   FMT_R_N_R)
	OPCODE("lh",    4, op_lh,    FMT_R_N_R)
	OPCODE("lhu",   4, op_lhu,   FMT_R_N_R)
	OPCODE("lw",    4, op_lw,    FMT_R_N_R)
	OPCODE("stb",   4, op_stb,   FMT_R_N_R)
	OPCODE("sth",   4, op_sth,   FMT_R_N_R)
	OPCODE("stw",   4, op_stw,   FMT_R_N_R)

	OPCODE("syscall", 4, op_syscall, FMT_N_R_R)

	/* Pseudo instructions */
	OPCODE("la",	16,	op_la,	FMT_R_L)
	OPCODE("jal",	28,	op_jal,	FMT_R_L)

	OPCODE((void *)0, 4, (void *)0, FMT_N_R_R)
};

#undef OPCODE

