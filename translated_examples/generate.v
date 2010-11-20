// File generate.vhd translated with vhd2vl v2.4 VHDL to Verilog RTL translator
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

module gen(
sysclk,
reset,
wrb,
din,
rdout
);

parameter [31:0] bus_width=15;
parameter [31:0] TOP_GP2=0;
input sysclk, reset, wrb;
input [bus_width:0] din;
output [bus_width:0] rdout;

wire sysclk;
wire reset;
wire wrb;
wire [bus_width:0] din;
wire [bus_width:0] rdout;


reg [bus_width * 2:0] regSelect;

  //---------------------------------------------------
  // Reg    : GP 2
  // Active : 32
  // Type   : RW
  //---------------------------------------------------
  genvar bitnum;
  generate for (bitnum=0; bitnum <= bus_width; bitnum = bitnum + 1) begin: reg_gp2
      wbit1 wbit1_inst(
          .clk(sysclk),
      .wrb(wrb),
      .reset(reset),
      .enb(regSelect[TOP_GP2]),
      .din(din[bitnum]),
      .dout(rdout[bitnum]));

  end
  endgenerate
  always @(posedge sysclk) begin
    regSelect[1] <= 1'b 1;
  end


endmodule
