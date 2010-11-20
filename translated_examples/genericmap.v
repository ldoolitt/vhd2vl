// File genericmap.vhd translated with vhd2vl v2.4 VHDL to Verilog RTL translator
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

module test(
clk,
rstn,
en,
start_dec,
addr,
din,
we,
pixel_in,
pix_req,
config,
bip,
a,
b,
c,
load,
pack,
base,
qtd,
dout,
pixel_out,
pixel_valid,
code,
complex,
eno
);

parameter rst_val=1'b 0;
parameter [31:0] thing_size=201;
parameter [31:0] bus_width=201 % 32;
input clk, rstn;
input en, start_dec;
input [2:0] addr;
input [25:0] din;
input we;
input [7:0] pixel_in;
input pix_req;
input config, bip;
input [7:0] a, b;
input [7:0] c, load;
input [6:0] pack;
input [2:0] base;
input [21:0] qtd;
// Outputs
output [25:0] dout;
output [7:0] pixel_out;
output pixel_valid;
output [9:0] code;
output [23:0] complex;
output eno;

wire clk;
wire rstn;
wire en;
wire start_dec;
wire [2:0] addr;
wire [25:0] din;
wire we;
wire [7:0] pixel_in;
wire pix_req;
wire config;
wire bip;
wire [7:0] a;
wire [7:0] b;
wire [7:0] c;
wire [7:0] load;
wire [6:0] pack;
wire [2:0] base;
wire [21:0] qtd;
wire [25:0] dout;
wire [7:0] pixel_out;
wire pixel_valid;
wire [9:0] code;
wire [23:0] complex;
wire eno;


wire [7:0] param;
wire selection;
wire start; wire enf;  // Start and enable signals
wire [13:0] memdin;
wire [5:0] memaddr;
wire [13:0] memdout;
wire [1:0] colour;

  dsp dsp_inst0(
      // Inputs
    .clk(clk),
    .rstn(rstn),
    // Outputs
    .dout(dout),
    .memaddr(memaddr),
    .memdout(memdout));

  dsp #(
      .rst_val(1'b 1),
    .bus_width(16))
  dsp_inst1(
      // Inputs
    .clk(clk),
    .rstn(rstn),
    // Outputs
    .dout(dout),
    .memaddr(memaddr),
    .memdout(memdout));


endmodule
