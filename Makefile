#!/usr/bin/make
# by RAM 2017

EXAMPLES = $(wildcard examples/*.vhd)
VHDLS    = $(notdir $(EXAMPLES))

all: vhdlcheck diff

# This rule is only helpful for a quick start;
# it doesn't understand the actual dependencies for rebuilds.
src/vhd2vl:
	make -C src

vhdlcheck:
	@make -C examples

translate: src/vhd2vl
	@mkdir -p temp/verilog
	@cd examples; $(foreach VHDL,$(VHDLS), echo "Translating: $(VHDL)";../src/vhd2vl --quiet $(VHDL) ../temp/verilog/$(basename $(VHDL)).v;)

diff: translate
	diff -u translated_examples temp/verilog
	@echo "PASS"

clean:
	make -C src clean
	@make -C examples clean
	rm -fr temp
