// File expr.vhd translated with vhd2vl v2.4 VHDL to Verilog RTL translator
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

module expr(
reset,
sysclk,
ival
);

input reset, sysclk, ival;

wire reset;
wire sysclk;
wire ival;


reg [13:0] foo;
wire [2:0] baz;
reg [22:0] bam;
wire [5:3] out_i;
wire [8:0] input_status;
wire enable; wire debug; wire aux; wire outy; wire dv; wire value;

  // drive input status
  assign input_status = {foo[9:4],((baz[3:0] & foo[3:0] | (( ~baz[3:0] & bam[3:0]))))};
  // drive based on foo
  assign out_i = ((enable & ((aux ^ outy)))) | ((debug & dv &  ~enable)) | (( ~debug &  ~enable & value));
  // not drive
  always @(negedge reset or negedge sysclk) begin
    if((reset != 1'b 0)) begin
      foo <= {14{1'b0}};
    end else begin
      foo[3 * ((2 - 1))] <= (4 * ((1 + 2)));
      bam[13:0] <= foo;
    end
  end


endmodule
