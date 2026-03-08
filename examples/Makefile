#!/usr/bin/make

TEMP = ../temp/vhdl

all:
ifneq ($(shell which ghdl),)
	@mkdir -p $(TEMP)
	@echo "##### Checking examples with GHDL ##############################"
	ghdl -a --std=08 --workdir=$(TEMP) signextend.vhd
	ghdl -a --std=08 -fsynopsys --workdir=$(TEMP) *.vhd
endif

clean:
	rm -fr $(TEMP)
