#!/usr/bin/make

TEMP = ../temp/verilog

all:
ifneq ($(shell which iverilog),)
	@mkdir -p $(TEMP)
	@echo "##### Checking resulting Verilog files with iVerilog ###########"
	@-cd $(TEMP); $(foreach VERILOG,$(wildcard *.v), echo "Checking: $(VERILOG)";\
	iverilog -Wall -y . -t null $(VERILOG);)
endif

clean:
	rm -fr $(TEMP)
