SHELL = /bin/bash
SCRIPTS = $(wildcard *.sh)

all:  run
.PHONY: all clean run

run: $(SCRIPTS:.sh=.run)

%.run: %.sh
	@echo "Running $< with ARG='$(ARG)'"
	@./$< $(ARG)

clean:
	rm -f 
	

