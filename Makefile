BIN=./bin

all: $(BIN) $(BIN)/disas $(BIN)/bbas $(BIN)/tohex $(BIN)/tobin $(BIN)/proc

$(BIN):
	mkdir -p $(BIN)

$(BIN)/disas:
	cd disas && $(MAKE) && cp disas ../$(BIN)/

$(BIN)/bbas:
	cd bbas && $(MAKE) && cp bbas ../$(BIN)/

$(BIN)/tohex:
	cd tohex && $(MAKE) && cp tohex ../$(BIN)/

$(BIN)/tobin:
	cd tobin && $(MAKE) && cp tobin ../$(BIN)/

$(BIN)/proc:
	cd proc && $(MAKE) && cp proc ../$(BIN)/

test: all
	./bin/bbas ./test/$(shell ls test/ | shuf | head -1)
	./bin/tohex v.out > v1.out
	mv v1.out v.out
	./bin/proc

clean:
	rm -rf $(BIN)/*
	cd disas && $(MAKE) clean
	cd ..
	cd bbas && $(MAKE) clean
	cd ..
	cd tohex && $(MAKE) clean
	cd ..
	cd tobin && $(MAKE) clean

