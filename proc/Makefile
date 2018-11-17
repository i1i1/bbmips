VC=iverilog
CFLAGS=-Wall
RM=rm -rf
OUT=proc

SRC=$(wildcard *.v)

all: $(OUT)

$(OUT): $(SRC)
	$(VC) $(CFLAGS) -o $(OUT) $(SRC)

clean:
	$(RM) *.o $(OUT)

