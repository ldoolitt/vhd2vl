# VHD2VL v3.0

Vhd2vl is designed to translate synthesizable VHDL into Verilog 1995 or 2001.
It does not support the full VHDL grammar - most of the testbench
related features have been left out. See the examples and
translated_examples directories for examples of what vhd2vl can do.

Vhd2vl does a pretty good job of translating, but you should ALWAYS
test the generated Verilog, ideally by using a formal verification
tool to compare it to the original VHDL!

A similar but more sophisticated effort is embedded in Icarus Verilog
as vhdlpp, mostly by Maciej Suminski. If hands-free use of VHDL in a
(Icarus) Verilog environment is the goal, that's probably a better tool.
If you want to convert a bit of VHDL to Verilog, and will then maintain
that Verilog as source, vhd2vl probably makes more sense, if for no other
reason than it conserves comments. It's good that both options exist!
You may find that your VHDL style is better accepted by one tool or the other.

The home page for (at least this version of) vhd2vl is
http://doolittle.icarus.com/~larry/vhd2vl/

## 1.0 HOW TO BUILD AND INSTALL vhd2vl:

To build, just type `make` in the src directory.

This version of vhd2vl has been tested with
*  Debian 7 (Wheezy): gcc-4.7.2, bison-2.5, flex-2.5.35, glibc-2.13
*  Debian 8 (Jessie): gcc-4.9.2 or clang-3.5.0, bison-3.0.2, flex-2.5.39, glibc-2.19
*  Debian 9 (Stretch): gcc-6.3.0 or clang-3.8.1, bison-3.0.4, flex-2.6.1, glibc-2.24

It is also verified to work with recent tinycc from its git mob.
This is portable C89/C99 code.  It can be expected to work with any
fairly recent version of the required tools.

To install, you can either type `make install` to copy the resulting src/vhd2vl
file to */usr/local/bin*, or copy it manually to someplace in your *$PATH*, like
*$HOME/bin*.

## 2.0 HOW TO USE vhd2vl:

```
vhd2vl VHDL_file.vhd > translated_file.v
```
or
```
vhd2vl VHDL_file.vhd translated_file.v
```
The two are equivalent when everything works. The latter has some
advantages when handling errors within a Makefile.

There are a few options available on the command line:
* `--debug` turn ON debugging within the yacc (bison) parser
* `--src 1995|2001` to specify module declaration style
* `--quiet` to avoid print vhd2vl header in translated_file.v
* `--version` to print vhd2vl version and info from git, if available

## 3.0 TROUBLESHOOTING:

If vhd2vl complains about a syntax error, this is usually due to a
VHDL construct that vhd2vl cannot translate. Try commenting out the
offending line, and running vhd2vl again. You can then edit the
Verilog output file and manually translate the offending line of VHDL.

Comments in the middle of statements sometimes confuse vhd2vl. This
is a "feature" of the logic that copies comments from VHDL to Verilog.
If vhd2vl complains about a syntax error caused by a comment, just
move that comment out of the middle of the statement and try again.

The grammar has rules that recognize common ways of writing clocked
processes. Your code might contain clocked processes that do not match
any of the templates in the grammar. This usually causes vhd2vl to
complain about a clock'event expression in a process. If this
happens, a minor rewrite of that process will let you work around the
problem.

To test a copy of vhd2vl for regressions against the example code shipped,
run `make` from this directory using a Bourne-style shell.  If you have
GHDL and/or iverilog installed, the example VHDL and Verilog code will be
compiled -- and therefore syntax-checked -- with those tools.

## 4.0 VHDL PACKAGES

Vhd2vl does not understand VHDL package files.  You might be able to work
around that limitation with the following strategy:

* Either by hand, or with a stupid script (I wrote mine in awk), break the
package file into individual VHDL files, each named after the entity.
* Use vhd2vl to convert each of those to Verilog.
Test to make sure the conversions went OK.
* Use iverilog's -y switch (or the eqivalent in your tool) to "find" those
files as needed.

## 5.0 MISSING FEATURES AND KNOWN INCORRECT OUTPUT:

String types: awkward, because Verilog strings need predefined length.

Attribute: easy to parse, but I'm not sure what Verilog construct
to turn it into. It smells like a parameter, not an (* attribute *).

Multiple actions in one process, as used in DDR logic?

Exit statement incompletely converted to disable statement.

Detection of indexed part select is limited.  While it can correctly convert
`data(index*8+WIDTH-1 downto index*8)` to `data[index*8+WIDTH-1 -: WIDTH-1+1]`
it gets tripped on slightly more complex cases.  The rule is that the
larger expression must take the form `smaller + offset` or `offset + smaller`.
Otherwise the output will be a direct transcription of the VHDL, which is not
standard-conforming unless both ends of the range are constant.

Conversion functions (resize, to_unsigned, conv_integer) are parsed, but
their semantics are ignored: resize(foo,n), to_unsigned(foo,n), and
conv_integer(foo) are treated as equivalent to foo.

VHDL is case insensitive, vhd2vl is case retentive, and Verilog is case
sensitive. If you're sloppy with case in the original VHDL, the
resulting Verilog will have compile-time warnings or errors. See
the comments about vhd2vl-2.1 in the changelog file.

Doesn't handle functions, procedures, or packages.  See above for a possible
way to handle packages.

Doesn't necessarily get clock edge sensitivities right if there is more
than one clock in the list.

Totally broken handling of text in generic mappings, as Xilinx is wont to
use for their primitives and wrappers.

Broken (invalid Verilog syntax for) initialization of process-scope variables.
