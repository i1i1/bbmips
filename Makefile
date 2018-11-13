BIN=./bin

all: $(BIN) $(BIN)/disas $(BIN)/bbas $(BIN)/tohex

$(BIN):
	mkdir -p $(BIN)

$(BIN)/disas:
	cd disas && $(MAKE) && cp disas ../$(BIN)/

$(BIN)/bbas:
	cd bbas && $(MAKE) && cp bbas ../$(BIN)/

$(BIN)/tohex:
	cd tohex && $(MAKE) && cp tohex ../$(BIN)/

clean:
	rm -rf $(BIN)
	cd disas && $(MAKE) clean
	cd ..
	cd bbas && $(MAKE) clean
	cd ..
	cd tohex && $(MAKE) clean

