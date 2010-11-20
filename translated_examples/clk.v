// File clk.vhd translated with vhd2vl v2.4 VHDL to Verilog RTL translator
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

module clk(
reset,
preset,
qreset,
sysclk,
dsysclk,
esysclk,
ival
);

input reset, preset, qreset, sysclk, dsysclk, esysclk;
input [31:0] ival;

wire reset;
wire preset;
wire qreset;
wire sysclk;
wire dsysclk;
wire esysclk;
wire [31:0] ival;


reg [10 + 3:0] foo;
reg [2:0] baz;
reg [4:7 - 1] egg;

  always @(posedge reset or posedge sysclk) begin
    if((reset != 1'b 0)) begin
      foo <= {(((10 + 3))-((0))+1){1'b1}};
    end else begin
      foo <= ival[31:31 - ((10 + 3))];
    end
  end

  always @(negedge preset or negedge dsysclk) begin
    if((preset != 1'b 1)) begin
      baz <= {3{1'b0}};
    end else begin
      baz <= ival[2:0];
    end
  end

  always @(negedge qreset or negedge esysclk) begin
    if((qreset != 1'b 1)) begin
      egg <= {(((7 - 1))-((4))+1){1'b0}};
    end else begin
      egg <= ival[6:4];
    end
  end


endmodule
