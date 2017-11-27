#!/usr/bin/make

all:
ifneq ($(shell which iverilog),)
	@echo "##### Checking resulting Verilog files with iverilog ###########"
	@$(foreach VERILOG,$(sort $(wildcard *.v)), echo "Checking: $(VERILOG)";\
	iverilog -Wall -y . -t null $(VERILOG);)
endif
