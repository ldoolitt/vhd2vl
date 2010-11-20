// File based.vhd translated with vhd2vl v2.4 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 1995

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002, 2005, 2008-2010 Larry Doolittle - LBNL
//     http://doolittle.icarus.com/~larry/vhd2vl/
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

// no timescale needed

module based(
sysclk
);

input sysclk;

wire sysclk;


wire [31:0] foo; wire [31:0] foo2; wire [31:0] foo8; wire [31:0] foo10; wire [31:0] foo11; wire [31:0] foo16;

  assign foo = 123;
  assign foo2 = 'B00101101110111;
  assign foo8 = 'O0177362;
  assign foo10 = 'D01234;
  assign foo11 = 11#01234#;
  assign foo16 = 'H12af;

endmodule
