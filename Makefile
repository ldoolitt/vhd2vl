#!/usr/bin/make

VERILOG  = iverilog -Wall -y . -t null
EXAMPLES = $(wildcard examples/*.vhd)
VHDLS    = $(notdir $(EXAMPLES))
VHDLS   := $(filter-out todo.vhd,$(VHDLS))

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

verilogcheck:
	@cd translated_examples; for f in *.v; do echo "Checking: $$f"; $(VERILOG) $$f; done

todo: src/vhd2vl
	src/vhd2vl --quiet examples/todo.vhd temp/todo.v

clean:
	make -C src clean
	@make -C examples clean
	rm -fr temp
