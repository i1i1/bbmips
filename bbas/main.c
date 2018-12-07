#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <ctype.h>

#include "../dict/dict.h"
#include "instr.h"


#define BUFSIZE	512

#ifndef DEBUG
#	define	printf(...)		do { } while (0)
#endif

#define STREQ(a, b)		(strcmp((a), (b)) == 0)

#define error(...)	do { \
						snprintf(_buf, BUFSIZE, __VA_ARGS__); \
						_error(_buf); \
					} while (0)
#define warn(...)	do { \
						snprintf(_buf, BUFSIZE, __VA_ARGS__); \
						_warn(_buf); \
					} while (0)


enum segment {
	SEG_NONE,
	SEG_DATA,
	SEG_TEXT,
};

struct link {
	enum segment seg;
	uint32_t addr;
};


char _buf[512];

int line;
char *fname;


void
_error(char *msg)
{
	fprintf(stderr, "%s:%d: error: %s\n", fname, line, msg);
	exit(1);
}

void
_warn(char *msg)
{
	fprintf(stderr, "%s:%d: warning: %s\n", fname, line, msg);
}

int
agetc(FILE *fp)
{
	int ret;

	ret = getc(fp);

	if (ret == '\n') {
		line++;
		return ret;
	}

	if (ret != '#')
		return ret;

	while ((ret = getc(fp)) != EOF && ret != '\n')
		;

	line++;

	return ret;
}

void
aputc(int c, FILE *fp)
{
	if (fputc(c, fp) == EOF)
		error("Can't write to file");
}

/*
 * An ordinary djb2 implimentation
 */
size_t
hash(const char *s)
{
	size_t h = 5381;
	int c;

	while ((c = *s++) != '\0')
		h = ((h << 5) + h) + c; /* h = h * 33 + c */

	return h;
}

struct opcode *
parse_op(const char *s)
{
	int i;

	for (i = 0; ops[i].str != NULL; i++)
		if (STREQ(s, ops[i].str))
			return (struct opcode *)ops + i;

	return NULL;
}

/*
 * Function that reads non space characters to string.
 *
 * '(', ')', ',' character signifies the end of the `word`.
 * It is returned to file with ungetc.
 *
 * ':' character signifies the end of the `word`, but also
 * belongs to the `word`.
 */
char *
parse_word(FILE *fp)
{
	static char buf[BUFSIZE];
	char *stopsyms = ",()";
	char *endsyms = ":";
	int i;
	int c;

	i = 0;

	while ((c = agetc(fp)) != EOF && isspace(c))
		;

	do {
		if (isspace(c) || strchr(stopsyms, c) != NULL)
			break;
		buf[i++] = c;
		if (strchr(endsyms, c) != NULL)
			break;
		c = agetc(fp);
	} while (i < BUFSIZE - 1 && c != EOF);

	buf[i] = '\0';

	if (c == EOF || c == ',' || c == '(' || c == ')')
		ungetc(c, fp);

	if (c == EOF && i == 1)
		return NULL;

	return buf;
}

int
parse_seg(const char *s, enum segment *seg)
{
	if (STREQ(s, ".data")) {
		*seg = SEG_DATA;
		return 0;
	}
	if (STREQ(s, ".text")) {
		*seg = SEG_TEXT;
		return 0;
	}

	return 1;
}

int
getint(char c)
{
	if ('0' <= c && c <= '9')
		return c - '0';
	if ('A' <= c && c <= 'F')
		return c - 'A' + 10;
	if ('a' <= c && c <= 'f')
		return c - 'a' + 10;
	return 0;
}

int
parse_int(const char *str, int64_t *res)
{
	int n;
	int base, sign;
	char *s;

	sign = 1;
	s = (char *)str;
	n = strlen(s);

	if (n == 0)
		return 1;

	if (s[0] == '-' || s[0] == '+') {
		if (s[0] == '-')
			sign = -1;
		s++;
		n = strlen(s);
	}

	if (n == 0)
		return 1;

	if (n == 1) {
		if (isdigit(s[0])) {
			*res = s[0] - '0';
			*res *= sign;
			return 0;
		} else
			return 1;
	}

	if (n == 2) {
		/* Check if octal number */
		if (s[0] == '0') {
			if ('0' <= s[1] && s[1] <= '7') {
				*res = s[0] - '0';
				*res *= sign;
				return 0;
			} else
				return 1;
		}

		/* Ordinary decimal number */
		if (isdigit(s[0]) && isdigit(s[0])) {
			*res = (s[0] - '0') * 10 + (s[1] - '0');
			*res *= sign;
			return 0;
		} else
			return 1;
	}

	base = 10;
	*res = 0;

	/* Check for non decimal bases */
	if (*s == '0') {
		base = 8;
		s++;

		/* Hex number */
		if (*s == 'x' || *s == 'X') {
			base = 16;
			s++;
		}
	}

	do {
		int d;

		d = getint(*s);

		if (!isxdigit(*s) || d >= base)
			return 1;

		*res = (*res) * base + d;
		s++;
	} while (*s);

	*res *= sign;

	return 0;
}

int
parse_str(FILE *fp, char *s, int n)
{
	int c;

	while ((c = agetc(fp)) != EOF && isspace(c))
		;

	if (c == EOF)
		return EOF;

	if (c != '"')
		return 1;

#define PUTBUF(c)	\
do { \
	if (n != 1) { \
		*s++ = (c); \
		n--; \
	} \
} while (0)

	while ((c = agetc(fp)) != EOF && c != '"') {
		if (c != '\\') {
			PUTBUF(c);
			continue;
		}

		if ((c = agetc(fp)) == EOF)
			break;

		switch (c) {
		case 'a':
			PUTBUF('\a');
			break;
		case 'b':
			PUTBUF('\b');
			break;
		case 'f':
			PUTBUF('\f');
			break;
		case 'n':
			PUTBUF('\n');
			break;
		case 'r':
			PUTBUF('\r');
			break;
		case 't':
			PUTBUF('\t');
			break;
		case 'v':
			PUTBUF('\v');
			break;
		case '\\':
			PUTBUF('\\');
			break;
		case '\'':
			PUTBUF('\'');
			break;
		case '\"':
			PUTBUF('\"');
			break;
		case '?':
			PUTBUF('\?');
			break;
		default:
			warn("escape sequence '\%c' is treated like plain '%c'", c, c);
		}
	}

	if (c == EOF)
		return EOF;

	*s = '\0';
#undef PUTBUF
	return 0;
}

int
strtoreg(const char *src, unsigned *r)
{
	char *s;
	int l;

	s = (char *)src;
	l = strlen(s);

	if (l < 3 || *s != '$')
		return 1;

	s++;

	if (STREQ(s, "zero")) {
		*r = 0;
		return 0;
	}
	if (STREQ(s, "at")) {
		*r = 1;
		return 0;
	}
	if (STREQ(s, "ra")) {
		*r = 61;
		return 0;
	}
	if (STREQ(s, "sp")) {
		*r = 62;
		return 0;
	}
	if (STREQ(s, "pc")) {
		*r = 63;
		return 0;
	}

	char c;
	int num;

	c = *s;
	num = 0;

	while (*++s) {
		if (isdigit(*s) == 0)
			return 1;
		num *= 10;
		num += *s - '0';
	}

#define TOREG(from, to, base)	\
do { \
	if (!((from) <= num && num <= (to))) \
		return 1; \
	*r = (base) + num; \
	return 0; \
} while (0);

	switch (c) {
	case 'v': TOREG(0,  3,  2);
	case 'a': TOREG(0,  7,  6);
	case 't': TOREG(0, 23, 14);
	case 's': TOREG(0, 23, 38);
	default:  return 1;
	}
#undef TOREG
}

int
scanc(FILE *fp, char chr)
{
	int c;

	while ((c = agetc(fp)) != EOF && isspace(c))
		;

	if (c == EOF)
		error("Expected '%c' but got EOF", chr);

	if (chr != c)
		error("Expected '%c' but got '%c'", chr, c);

	return 0;
}

int
skip_args(FILE *fp, enum format fmt)
{
	const char *s;

#define SKIP_REG()		\
do { \
	unsigned r0; \
	s = parse_word(fp); \
	if (!s) \
		error("Expected register found EOF"); \
	if (strtoreg(s, &r0)) \
		error("Unknown register \"%s\"", s); \
} while (0)

#define SKIP_INT()		\
do { \
	int64_t _num; \
	s = parse_word(fp); \
	if (!s) \
		error("Expected number, but found EOF"); \
	if (parse_int(s, &_num)) \
		error("Expected number, but found  \"%s\"", s); \
} while (0)

#define SKIP_LABEL() \
do { \
	s = parse_word(fp); \
	if (!s) \
		error("Expected label found EOF"); \
} while (0)

	switch (fmt) {
	case FMT_R_R_R:
		SKIP_REG();
		scanc(fp, ',');
		SKIP_REG();
		scanc(fp, ',');
		SKIP_REG();
		break;
	case FMT_R_R_N:
		SKIP_REG();
		scanc(fp, ',');
		SKIP_REG();
		scanc(fp, ',');
		SKIP_INT();
		break;
	case FMT_R_N_R:
		SKIP_REG();
		scanc(fp, ',');
		SKIP_INT();
		scanc(fp, '(');
		SKIP_REG();
		scanc(fp, ')');
		break;
	case FMT_N_R_R:
		SKIP_INT();
		scanc(fp, ',');
		SKIP_REG();
		scanc(fp, ',');
		SKIP_REG();
		break;
	case FMT_R_L:
		SKIP_REG();
		scanc(fp, ',');
		SKIP_LABEL();
		break;
	default:
		error("Unknown format for command");
	}

#undef SKIP_REG
#undef SKIP_INT
#undef SKIP_LABEL

	return 0;
}

int
parse_args(FILE *fp, uint32_t tbeg, uint32_t dbeg, dict *lnks,
            enum format fmt, unsigned *r0, unsigned *r1,
            unsigned *r2, uint16_t *n, uint32_t *addr)
{
	char *s;

#define PARSE_REG(reg)		\
do { \
	s = parse_word(fp); \
	if (!s) \
		error("Expected register found EOF"); \
	if (strtoreg(s, (reg))) \
		error("Unknown register \"%s\"", s); \
} while (0)

#define PARSE_INT(num)		\
do { \
	int64_t _num; \
	s = parse_word(fp); \
	if (!s) \
		error("Expected number, but found EOF"); \
	if (parse_int(s, &_num)) \
		error("Expected number, but found \"%s\"", s); \
	(num) = (uint16_t)_num; \
} while (0)

#define PARSE_LABEL(addr) \
do { \
	struct link *lp; \
	s = parse_word(fp); \
	if (!s) \
		error("Expected label found EOF"); \
	if (!(lp = dict_get(lnks, s))) \
			error("No such label \"%s\"", s); \
	*addr = lp->addr + (lp->seg == SEG_DATA ? dbeg : tbeg); \
} while (0)

	switch (fmt) {
	case FMT_R_R_R:
		PARSE_REG(r0);
		scanc(fp, ',');
		PARSE_REG(r1);
		scanc(fp, ',');
		PARSE_REG(r2);
		break;
	case FMT_R_R_N:
		PARSE_REG(r0);
		scanc(fp, ',');
		PARSE_REG(r1);
		scanc(fp, ',');
		PARSE_INT(*n);
		break;
	case FMT_R_N_R:
		PARSE_REG(r0);
		scanc(fp, ',');
		PARSE_INT(*n);
		scanc(fp, '(');
		PARSE_REG(r1);
		scanc(fp, ')');
		break;
	case FMT_N_R_R:
		PARSE_INT(*n);
		scanc(fp, ',');
		PARSE_REG(r0);
		scanc(fp, ',');
		PARSE_REG(r1);
		break;
	case FMT_R_L:
		PARSE_REG(r0);
		scanc(fp, ',');
		PARSE_LABEL(addr);
		break;
	default:
		error("Unknown format for command");
	}

#undef PARSE_REG
#undef PARSE_INT
#undef PARSE_LABEL

	return 0;
}

int
getlinks(char *ifs, dict *lnks, uint32_t *tend, uint32_t *dend)
{
	FILE *fp;
	int c;
	char *s;
	int n;
	enum segment seg;

	line = 1;
	*tend = 0;
	*dend = 0;
	seg = SEG_NONE;
	fp = fopen(ifs, "r");

	if (!fp)
		return 1;

	for (;;) {
		s = parse_word(fp);
		n = (s == NULL) ? 0 : strlen(s);

		/* If EOF then finish */
		if (s == NULL)
			break;

		if (seg == SEG_NONE) {
			if (s[0] != '.')
				error("Expected .data or .text found \"%s\"", s);
			parse_seg(s, &seg);

			if (seg == SEG_NONE)
				error("Expected .data or .text found \"%s\"", s);

			continue;
		}

		/* If found reference */
		if (s[n - 1] == ':' && s[0] != '.') {
			struct link *lnk;

			s[n - 1] = '\0';

			if (dict_get(lnks, s))
				error("Already has label \"%s\"", s);

			if (!(lnk = malloc(sizeof(*lnk))))
				error("Memmory error");

			lnk->seg = seg;
			lnk->addr = (seg == SEG_DATA) ? (*dend) : (*tend);

			if (dict_set(lnks, s, lnk))
				error("Memmory error");

			continue;
		}

		if (seg == SEG_DATA) {
			if (s[0] != '.')
				error("Expected dot directive (e.g. .word), "
						"but found \"%s\"", s);

#define PARSE_INTS(delta, num) \
do { \
	do { \
		s = parse_word(fp); \
		*dend += (delta); \
		if (!s) \
			error("Expected number, but found EOF"); \
		if (parse_int(s, (num))) \
			error("Expected number, but found \"%s\"", s); \
	} while ((c = agetc(fp)) == ','); \
	ungetc(c, fp); \
} while (0)

			if (STREQ(s, ".text")) {
				seg = SEG_TEXT;
				continue;
			}

			if (STREQ(s, ".byte")) {
				int64_t num;

				PARSE_INTS(1, &num);

			} else if (STREQ(s, ".half")) {
				int64_t num;

				PARSE_INTS(2, &num);

			} else if (STREQ(s, ".word")) {
				int64_t num;

				PARSE_INTS(4, &num);

#undef PARSE_INTS
			} else if (STREQ(s, ".ascii")) {
				char str[BUFSIZE];

				do {
					if (parse_str(fp, str, BUFSIZE))
						error("Wrong format for string");

					*dend += strlen(str);

					/* scanning next non space symbol */
					while ((c = agetc(fp)) != EOF && isspace(c))
						;
				} while (c == ',');

				ungetc(c, fp);

			} else if (STREQ(s, ".asciiz")) {
				char str[BUFSIZE];

				do {
					if (parse_str(fp, str, BUFSIZE))
						error("Wrong format for string");

					*dend += strlen(str) + 1;

					/* scanning next non space symbol */
					while ((c = agetc(fp)) != EOF && isspace(c))
						;

				} while (c == ',');

				ungetc(c, fp);

			} else if (STREQ(s, ".space")) {
				int64_t num;

				s = parse_word(fp);

				if (!s)
					error("Expected number, but found EOF");

				if (parse_int(s, &num))
					error("Expected number, but found \"%s\"", s);

				if (num <= 0)
					error("Invalid number %ld", num);

				*dend += num;

			} else
				error("Unknown dot directive \"%s\"", s);

			continue;
		}

		if (seg == SEG_TEXT) {
			struct opcode *op;

			op = parse_op(s);

			if (!op)
				error("Unknown command \"%s\"", s);

			if (skip_args(fp, op->fmt))
				error("Wrong format for the \"%s\"", s);

			*tend += op->size;
			continue;
		}

		error("Shouldn't reach");
	}

	fclose(fp);

	return 0;
}

int
assemble(char *ifs, FILE *ts, FILE *ds, dict *lnks,
		uint32_t tbeg, uint32_t dbeg)
{
	FILE *fp;
	int c;
	char *s;
	int n;
	enum segment seg;

	line = 1;
	seg = SEG_NONE;
	fp = fopen(ifs, "r");

	if (!fp || !ds || !ts)
		return 1;

	for (;;) {
		s = parse_word(fp);
		n = (s == NULL) ? 0 : strlen(s);

		/* If EOF then finish */
		if (s == NULL)
			break;

		if (seg == SEG_NONE) {
			if (s[0] != '.')
				error("Expected .data or .text found \"%s\"", s);
			parse_seg(s, &seg);

			if (seg == SEG_NONE)
				error("Expected .data or .text found \"%s\"", s);

			continue;
		}

		/* If found reference */
		if (s[0] != '.' && s[n - 1] == ':') {
			s[n - 1] = '\0';

			if (!dict_get(lnks, s))
				error("No label \"%s\"", s);

			continue;
		}

		if (seg == SEG_DATA) {
			if (s[0] != '.')
				error("Expected dot directive (e.g. .word), "
						"but found \"%s\"", s);

#define PARSE_INT(num) \
do { \
	s = parse_word(fp); \
	if (!s) \
		error("Expected number, but found EOF"); \
	if (parse_int(s, (num))) \
		error("Expected number, but found \"%s\"", s); \
} while (0)

			if (STREQ(s, ".text")) {
				seg = SEG_TEXT;
				continue;
			}

			if (STREQ(s, ".byte")) {
				int64_t num;
				uint8_t tmp;

				do {
					PARSE_INT(&num);

					if (-128 > num || num >= 256)
						error("Too large or too small number %s", s);

					if (num < 0)
						tmp = 256 - num;
					else
						tmp = num;

					aputc(tmp, ds);

				} while ((c = agetc(fp)) == ',');

				ungetc(c, fp);
			} else if (STREQ(s, ".half")) {
				int64_t num;
				uint16_t tmp;

				do {
					PARSE_INT(&num);

					if (-(1 << 15) > num || num >= (1 << 16))
						error("Too large or too small number %s", s);

					if (num < 0)
						tmp = (1 << 16) - num;
					else
						tmp = num;

					aputc((tmp >> 8) % 256, ds);
					aputc(tmp % 256, ds);

				} while ((c = agetc(fp)) == ',');

				ungetc(c, fp);
			} else if (STREQ(s, ".word")) {
				int64_t num;
				uint16_t tmp;

				do {
					PARSE_INT(&num);

					if (-((int64_t)1 << 31) > num
							|| num >= ((int64_t)1 << 32))
						error("Too large or too small number %s", s);

					if (num < 0)
						tmp = ((int64_t)1 << 32) - num;
					else
						tmp = num;

					aputc((tmp >> 24) % 256, ds);
					aputc((tmp >> 16) % 256, ds);
					aputc((tmp >> 8) % 256, ds);
					aputc(tmp % 256, ds);

				} while ((c = agetc(fp)) == ',');

				ungetc(c, fp);
#undef PARSE_INT
			} else if (STREQ(s, ".ascii")) {
				char str[BUFSIZE];

				do {
					if (parse_str(fp, str, BUFSIZE))
						error("Wrong format for string");

					if (fputs(str, ds) == EOF)
						error("Error while writing to file");

					/* scanning next non space symbol */
					while ((c = agetc(fp)) != EOF && isspace(c))
						;
				} while (c == ',');

				ungetc(c, fp);

			} else if (STREQ(s, ".asciiz")) {
				char str[BUFSIZE];

				do {
					if (parse_str(fp, str, BUFSIZE))
						error("Wrong format for string");

					if (fputs(str, ds) == EOF)
						error("Error while writing to file");
					aputc('\0', ds);

					/* scanning next non space symbol */
					while ((c = agetc(fp)) != EOF && isspace(c))
						;

				} while (c == ',');

				ungetc(c, fp);

			} else if (STREQ(s, ".space")) {
				int64_t num;
				int i;

				s = parse_word(fp);

				if (!s)
					error("Expected number, but found EOF");

				if (parse_int(s, &num))
					error("Expected number, but found \"%s\"", s);

				if (num <= 0)
					error("Invalid number %ld", num);

				for (i = 0; i < num; i++)
					aputc(0, ds);
			} else
				error("Unknown dot directive \"%s\"", s);

			continue;
		}

		if (seg == SEG_TEXT) {
			struct opcode *op;
			unsigned r0, r1, r2;
			uint16_t n;
			uint32_t addr;
			int len;
			static char buf[BUFSIZE];

			op = parse_op(s);
			len = BUFSIZE;

			if (!op)
				error("Unknown command \"%s\"", s);

			if (parse_args(fp, tbeg, dbeg, lnks,
					op->fmt, &r0, &r1, &r2, &n, &addr))
				error("Wrong format for the \"%s\"", s);

			len = op->toop(buf, BUFSIZE, r0, r1, r2, n, addr);

			if (len == 0)
				error("Buffer overflow");

			int i;

			for (i = 0; i < len; i++)
				aputc(buf[i], ts);

			continue;
		}

		error("Shouldn't reach");
	}

	fclose(fp);

	return 0;
}

void
link(char *ofs, FILE *ts, FILE *ds)
{
	FILE *ofp;
	int c;

	ofp = fopen(ofs, "w");

	while ((c = getc(ts)) != EOF)
		aputc(c, ofp);

	while ((c = getc(ds)) != EOF)
		aputc(c, ofp);

	fclose(ofp);
}

int
main(int argc, char **argv)
{
	FILE *ts, *ds;
	char *ifs, *ofs;
	dict *lnks;
	uint32_t tend, dend;

	if (argc < 2)
		error("no input file");

	if (argc < 3) {
		ifs = argv[1];
		fname = argv[1];
	}

	ofs = "v.out";
	ds = tmpfile();
	ts = tmpfile();
	lnks = dict_init(1);

	if (!ds || !ts || !lnks)
		error("Memmory error");

	if (getlinks(ifs, lnks, &tend, &dend)) {
		dict_free(lnks);
		error("Couldn't get links from file \"%s\"", ifs);
	}

	if (assemble(ifs, ts, ds, lnks, 0, tend)) {
		dict_free(lnks);
		error("Couldn't assemble file \"%s\" to \"%s\"", ifs, ofs);
	}

	dict_free(lnks);

	rewind(ts);
	rewind(ds);

	link(ofs, ts, ds);

	fclose(ts);
	fclose(ds);

	return 0;
}

