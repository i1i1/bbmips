#include <stdio.h>

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
			printf(" %02x", c);
		}
		fclose(fp);
	}
	printf("\n");

	return 0;
}

