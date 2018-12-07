CC=gcc
CFLAGS=-Wall -Wextra
RM=rm -rf
OUT=bbas

all: $(OUT)

$(OUT): main.o instr.o ../dict/lib.o
	$(CC) $(CFLAGS) -o $(OUT) main.o instr.o ../dict/lib.o

debug: CFLAGS+=-DDEBUG
debug: clean all

main.o: main.c instr.h
	$(CC) $(CFLAGS) -c main.c

instr.o: instr.c instr.h
	$(CC) $(CFLAGS) -c instr.c

../dict/lib.o:
	make -C ../dict/

test: all
	./$(OUT) ../test/square.s

clean:
	$(RM) *.o $(OUT)

