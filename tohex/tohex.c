#include <stdio.h>

int
main(int argc, char *argv[]) {
    int i;
    FILE *fp;

    for (i = 1; i < argc; ++i) {
        fp = fopen(argv[i], "r");

        if (fp) {
            int c;

            while ((c = fgetc(fp)) != EOF) {
                printf(" %02x", c);
            }
            fclose(fp);

        } else {
		fprintf(stderr, "Can't open file \"%s\"\n", argv[i]);
		return 1;
	}
    }
    printf("\n");

    return 0;
}

