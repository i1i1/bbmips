
CC=gcc
CFLAGS=-Wall -Wextra
RM=rm -rf
OUT=bbas

all: $(OUT)

$(OUT): main.o instr.o vector/vector.o
	$(CC) $(CFLAGS) -o $(OUT) main.o instr.o vector/vector.o

debug: CFLAGS+=-DDEBUG
debug: clean all

main.o: main.c instr.h vector/vector.h
	$(CC) $(CFLAGS) -c main.c

instr.o: instr.c instr.h
	$(CC) $(CFLAGS) -c instr.c

vector/vector.o:
	cd vector && make

test: all
	./$(OUT) ../test/square.s

clean:
	$(RM) *.o $(OUT)
	cd vector && make clean

