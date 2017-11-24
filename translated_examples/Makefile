#!/usr/bin/make

TEMP = ../temp/verilog

all:
ifneq ($(shell which iverilog),)
	@echo "##### Checking resulting Verilog files with iverilog ###########"
	-cd $(TEMP); iverilog -Wall -y . -t null *.v
endif

clean:
	rm -fr $(TEMP)
