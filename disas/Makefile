CC=gcc
CFLAGS=-Wall -Wextra
OUT=disas

all: $(OUT)

$(OUT): disassemble.c
	$(CC) $(CFLAGS) -o $(OUT) disassemble.c

clean:
	rm -rf $(OUT)

