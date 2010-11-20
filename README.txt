VHD2VL v2.4 README.txt

Vhd2vl is designed to translate synthesizable VHDL into Verilog 2001.
It does not support the full VHDL grammar - most of the testbench
related features have been left out.  See the examples and
translated_examples directories for examples of what vhd2vl can do.

Vhd2vl does a pretty good job of translating, but you should ALWAYS
test the generated Verilog, ideally by using a formal verification
tool to compare it to the original VHDL!

The home page for (at least for this version of) vhd2vl is
  http://doolittle.icarus.com/~larry/vhd2vl/


1.0 HOW TO BUILD AND INSTALL vhd2vl:

To build, just type 'make' in the src directory.

This version of vhd2vl has been tested with GNU Bison 2.3, and
GNU Flex version 2.5.35.  No problems have been reported with other
fairly recent versions.

To install, copy the resulting src/vhd2vl file to someplace in
your $PATH, like $HOME/bin or /usr/local/bin.


2.0 HOW TO USE vhd2vl:

   vhd2vl VHDL_file.vhd > translated_file.v
or
   vhd2vl VHDL_file.vhd translated_file.v
The two are equivalent when everything works.  The latter has some
advantages when handling errors within a Makefile.

There are a few of options available on the command line:
  -d  turn on debugging within the yacc (bison) parser
  -g1995  (default) use traditional Verilog module declaration style
  -g2001  use Verilog-2001 module declaration style


3.0 TROUBLESHOOTING:

If vhd2vl complains about a syntax error, this is usually due to a
VHDL construct that vhd2vl cannot translate.  Try commenting out the
offending line, and running vhd2vl again.  You can then edit the
Verilog output file and manually translate the offending line of VHDL.

Comments in the middle of statements sometimes confuse vhd2vl.  This
is a "feature" of the logic that copies comments from VHDL to Verilog.
If vhd2vl complains about a syntax error caused by a comment, just
move that comment out of the middle of the statement and try again.

The grammar has rules that recognize common ways of writing clocked
processes. Your code might contain clocked processes that do not match
any of the templates in the grammar.  This usually causes VHD2VL to
complain about a clock'event expression in a process.  If this
happens, a minor rewrite of that process will let you work around the
problem.

If you need to look at the VHDL grammar, make puts a copy of it in
vhd2vl.output. If you need to change the grammar, then running vhd2vl
with the '-d' option will cause vhd2vl to trace how it is parsing the
input file.  See the bison documentation for more details.

To test a copy of vhdl for regressions against the example code shipped,
  mkdir test
  (cd examples && for f in *.vhd; do vhd2vl $f ../test/${f%%.vhd}.v; done)
  diff -u translated_examples test | less
from this directory using a Bourne-style shell.


4.0 MISSING FEATURES AND KNOWN INCORRECT OUTPUT:

String types: awkward, because Verilog strings need predefined length

Attribute: easy to parse, but I'm not sure what Verilog construct
  to turn it into.  It smells like a parameter, not an (* attribute *).

Multiple actions in one process, as used in DDR logic?

Exit statement incompletely converted to disable statement
  (see examples/bigfile.vhd)

Part select expression zz(31+k downto k) should convert to zz[31+k+:32]
  (see examples/for.vhd)

variables not handled right, show up as declarations within always blocks
  (see examples/for.vhd)

Conversion functions (resize, to_unsigned, conv_integer) are parsed, but
  their semantics are ignored: resize(foo,n), to_unsigned(foo,n), and
  conv_integer(foo) are treated as equivalent to (foo).

VHDL is case insensitive, vhd2vl is case retentive, and Verilog is case
  sensitive.  If you're sloppy with case in the original VHDL, the
  resulting Verilog will have compile-time warnings or errors.  See
  the comments about vhd2vl-2.1 in the changes file.

Doesn't necessarily get clock edge sensitivities right if there is more
  than one clock in the list

Totally broken handling of text in generic mappings, as Xilinx is wont to
  use for their primitives and wrappers
