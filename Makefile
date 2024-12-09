#!/usr/bin/make

TEMP     = temp

EXCLUDE  = $(shell cat examples/exclude)
EXCLUDE := $(basename $(EXCLUDE))
EXCLUDE := $(addsuffix .vhd,$(EXCLUDE))

VHDLS    = $(sort $(wildcard examples/*.vhd))
VHDLS   := $(notdir $(VHDLS))

DIFFOPT  = --exclude=Makefile

ifndef WIP
VHDLS   := $(filter-out $(EXCLUDE),$(VHDLS))
DIFFOPT := $(DIFFOPT) --exclude-from=examples/exclude
endif

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
BINARY   = src/vhd2vl

all: $(BINARY)

build $(BINARY):
	make -C src

install: $(BINARY)
	cp $< $(BINDIR)

test: $(BINARY)
	@make -C examples
	@rm -fr $(TEMP)/verilog && mkdir -p $(TEMP)/verilog
	@echo "##### Translating Examples #####################################"
	@cd examples; $(foreach VHDL,$(VHDLS), echo "Translating: $(VHDL)";\
	../$(BINARY) --quiet $(VHDL) ../$(TEMP)/verilog/$(basename $(VHDL)).v;)
	@make -C translated_examples
	@echo "##### Diff #####################################################"
	diff -u $(DIFFOPT) translated_examples $(TEMP)/verilog
	@echo "PASS"

clean:
	make -C src clean
	rm -fr $(TEMP)
