#!/usr/bin/make

VHDLS  = $(wildcard examples/*.vhd)
VHDLS := $(notdir $(VHDLS))
VHDLS := $(filter-out todo.vhd,$(VHDLS))

all: diff

translate:
	@make -C src
	@make -C examples
	@mkdir -p temp/verilog
	@echo "##### Translating Examples #####################################"
	@cd examples; $(foreach VHDL,$(VHDLS), echo "Translating: $(VHDL)";\
	../src/vhd2vl --quiet $(VHDL) ../temp/verilog/$(basename $(VHDL)).v;)
	@make -C translated_examples

diff: translate
	@echo "##### Diff #####################################################"
	diff -u --exclude=Makefile translated_examples temp/verilog
	@echo "PASS"

todo:
	@make -C src
	src/vhd2vl --quiet examples/todo.vhd temp/todo.v

clean:
	make -C src clean
	rm -fr temp
