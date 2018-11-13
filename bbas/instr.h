#ifndef _INSTR_H_
#define _INSTR_H_

#include <stdint.h>


enum optype {
	OP_REG,	/* 3 registers as arguments */
	OP_IMM,	/* 2 registers and number as arguments */
};

enum format {
	FMT_R_R_R, /* e.g. jie		$zero,	$zero,	$zero	*/
	FMT_R_R_N, /* e.g. addi		$t1,	$zero,	2 	*/
	FMT_R_N_R, /* e.g. lw		$t1,	5($t2)		*/
	FMT_N_R_R, /* e.g. syscall	0,	$zero,	$zero	*/
	FMT_R_L,   /* e.g. la           $t1,    label           */
};

struct opcode {
	char *str;
	unsigned int size;

	enum optype tp;
	enum format fmt;

	/*
	 * r2 is ignored if tp == OP_IMM
	 * n  is ignored if tp == OP_REG
	 *
	 * s is buffer for opcode write.
	 * len is the size of this buffer.
	 *
	 * Function returns non zero result if failed to write.
	 */
	int (*toop)(char *src, int len,
		unsigned r0, unsigned r1, unsigned r2,
		uint16_t n, uint32_t addr);
};

extern struct opcode ops[];

#endif /* _INSTR_H_ */

