#include <stdio.h>
#include <stdint.h>


char *
tobin(uint8_t n)
{
	int i;
	static char str[10];
	char *s;

	for (s = str, i = 7; i >= 4; i--) {
		*s++ = (((n >> i) & 1) ? '1' : '0');
	}

//	*s++ = '_';

	for (i = 3; i >= 0; i--) {
		*s++ = (((n >> i) & 1) ? '1' : '0');
	}

	*s = '\0';

	return (char *)str;
}

int
main(int argc, char *argv[])
{
	int i, c;
	FILE *fp;

	for (i = 1; i < argc; ++i) {
		fp = fopen(argv[i], "r");

		if (!fp) {
			fprintf(stderr, "Can't open file \"%s\"\n", argv[i]);
			return 1;
		}

		while ((c = fgetc(fp)) != EOF) {
			printf("%s\n", tobin(c));
		}
		fclose(fp);
	}

	return 0;
}

