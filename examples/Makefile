#!/usr/bin/make
# by RAM 2017

TEMP = ../temp/vhdl

all:
	@mkdir -p $(TEMP)
	ghdl -a --workdir=$(TEMP) *.vhd

clean:
	rm -fr $(TEMP)
