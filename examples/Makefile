#!/usr/bin/make

TEMP = ../temp/vhdl

all:
ifneq ($(shell which ghdl),)
	@mkdir -p $(TEMP)
	@echo "##### Checking examples with GHDL ##############################"
	ghdl -a --workdir=$(TEMP) signextend.vhd
	ghdl -a --workdir=$(TEMP) *.vhd
endif

clean:
	rm -fr $(TEMP)
