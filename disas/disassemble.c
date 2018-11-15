#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define OPCODE_REG(func, s) \
case (func): \
	r2 = (n >> 10) & 63;   \
	fprintf(ofp, "%08x:\t%s\t%s,\t%s,\t%s\n", i, (s), reg[r0], \
			reg[r1], reg[r2]); \
	break;

#define OPCODE_IMM(op, s) \
case (op): \
	tmp = (int16_t)(n % (1 << 16)); \
	fprintf(ofp, "%08x:\t%s\t%s,\t%s,\t%d\n", i, (s), reg[r0], \
			reg[r1], tmp); \
	break;

#define OPCODE_IMM_MEM(op, s) \
case (op): \
	tmp = (int16_t)(n % (1 << 16)); \
	fprintf(ofp, "%08x:\t%s\t%s,\t%d(%s)\n", i, (s), reg[r0], \
			tmp, reg[r1]); \
	break;


char *reg[] = {
	"$zero",
	"$at",
	"$v0",
	"$v1",
	"$v2",
	"$v3",
	"$a0",
	"$a1",
	"$a2",
	"$a3",
	"$a4",
	"$a5",
	"$a6",
	"$a7",
	"$t0",
	"$t1",
	"$t2",
	"$t3",
	"$t4",
	"$t5",
	"$t6",
	"$t7",
	"$t8",
	"$t9",
	"$t10",
	"$t11",
	"$t12",
	"$t13",
	"$t14",
	"$t15",
	"$t16",
	"$t17",
	"$t18",
	"$t19",
	"$t20",
	"$t21",
	"$t22",
	"$t23",
	"$s0",
	"$s1",
	"$s2",
	"$s3",
	"$s4",
	"$s5",
	"$s6",
	"$s7",
	"$s8",
	"$s9",
	"$s10",
	"$s11",
	"$s12",
	"$s13",
	"$s14",
	"$s15",
	"$s16",
	"$s17",
	"$s18",
	"$s19",
	"$s20",
	"$s21",
	"$s22",
	"$ra",
	"$sp",
	"$pc",
};

void
error(char *s)
{
	fprintf(stderr, "error: %s\n", s);
	exit(1);
}

uint32_t
getop(FILE *fp)
{
	int i, c;
	uint32_t ret;

	for (i = 0; i < 4; i++) {
		if ((c = getc(fp)) == EOF) {
			if (i == 0)
				exit(0);
			else
				error("Unfinished opcode");
		}
		ret = ret * 0x100 + c;
	}

	return ret;
}

int
main(int argc, char **argv)
{
	FILE *fp, *ofp;
	int i;
	uint32_t n;

	if (argc < 2 || strcmp(argv[1], "-") == 0)
		fp = stdin;
	else
		fp = fopen(argv[1], "r");

	if (!fp)
		error("Error while openning input file");

	ofp = stdout;
	i = n = 0;
	int tmp;

	while ((n = getop(fp))) {
		int r0, r1, r2;

		r0 = (n >> 22) & 63;
		r1 = (n >> 16) & 63;

		switch (n >> 28) {
		case 0:
			switch (n % (1 << 10)) {
			OPCODE_REG(0,  "jie")
			OPCODE_REG(1,  "jil")
			OPCODE_REG(2,  "jier")
			OPCODE_REG(3,  "jilr")
			OPCODE_REG(4,  "or")
			OPCODE_REG(5,  "and")
			OPCODE_REG(6,  "xor")
			OPCODE_REG(7,  "nor")
			OPCODE_REG(8,  "sub")
			OPCODE_REG(9,  "add")
			OPCODE_REG(10, "mul")
			OPCODE_REG(11, "div")
			OPCODE_REG(12, "mod")
			OPCODE_REG(13, "sll")
			OPCODE_REG(14, "sla")
			OPCODE_REG(15, "srl")
			OPCODE_REG(16, "sra")
				default:
					error("Unknown opcode");
			}
			break;

		OPCODE_IMM(1, "addi")
		case 2:
			tmp = n % (1 << 16);
			fprintf(ofp, "%08x:\t%s\t%s,\t%s,\t%d\n",
				i, "addiu", reg[r0], reg[r1], tmp);
			break;
		OPCODE_IMM_MEM( 3, "lb")
		OPCODE_IMM_MEM( 4, "lbu")
		OPCODE_IMM_MEM( 5, "lh")
		OPCODE_IMM_MEM( 6, "lhu")
		OPCODE_IMM_MEM( 7, "lw")
		OPCODE_IMM_MEM( 8, "stb")
		OPCODE_IMM_MEM( 9, "sth")
		OPCODE_IMM_MEM(10, "stw")

		case 11:
			tmp = n % (1 << 16);
			fprintf(ofp, "%08x:\t%s\t%d,\t%s,\t%s\n", i, "syscall",
					(int)tmp, reg[r0], reg[r1]);
			break;
		case 15:
			exit(0);
		default:
			fclose(ofp);
			error("Unknown opcode");
		}
		i += 4;
	}

	return 0;
}

