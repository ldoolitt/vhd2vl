#!/usr/bin/make

IVERILOG = iverilog
V_FILES = $(sort $(wildcard *.v))
all: $(V_FILES:%.v=%_check)

%_check: %.v
	$(IVERILOG) -Wall -y . -t null $<
