BIN=./bin

all: $(BIN) $(BIN)/disas $(BIN)/bbas $(BIN)/tohex $(BIN)/tobin $(BIN)/proc

$(BIN):
	mkdir -p $(BIN)

$(BIN)/disas:
	$(MAKE) -C disas
	cp disas/disas ./$(BIN)/

$(BIN)/bbas:
	$(MAKE) -C bbas
	cp bbas/bbas ./$(BIN)/

$(BIN)/tohex:
	$(MAKE) -C tohex
	cp tohex/tohex ./$(BIN)/

$(BIN)/tobin:
	$(MAKE) -C tobin
	cp tobin/tobin ./$(BIN)/

$(BIN)/proc:
	$(MAKE) -C proc
	cp proc/proc ./$(BIN)/

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
	cd ..
	cd proc && $(MAKE) clean

