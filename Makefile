BIN=./bin

all: $(BIN) $(BIN)/disas $(BIN)/bbas $(BIN)/tohex

$(BIN):
	mkdir -p $(BIN)

$(BIN)/disas:
	cd disas && $(MAKE) && cp disas ../$(BIN)/

$(BIN)/bbas:
	cd as && $(MAKE) && cp bbas ../$(BIN)/

$(BIN)/tohex:
	cd tohex && $(MAKE) && cp tohex ../$(BIN)/

clean:
	rm -rf $(BIN)
	cd disas && $(MAKE) clean
	cd ..
	cd as && $(MAKE) clean
	cd ..
	cd tohex && $(MAKE) clean

