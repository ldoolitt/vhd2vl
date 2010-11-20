// File test.vhd translated with vhd2vl v2.4 VHDL to Verilog RTL translator
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

// Project: VHDL to Verilog RTL translation 
// Revision: 1.0 
// Date of last Revision: February 27 2001 
// Designer: Vincenzo Liguori 
// vhd2vl test file
// This VHDL file exercises vhd2vl
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
code1,
complex,
eno
);

// Inputs
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
output [9:0] code1;
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
reg [7:0] pixel_out;
wire pixel_valid;
reg [9:0] code;
wire [9:0] code1;
wire [23:0] complex;
wire eno;


// Components declarations are ignored by vhd2vl
// but they are still parsed
parameter [1:0]
  red = 0,
  green = 1,
  blue = 2,
  yellow = 3;

reg [1:0] status;
parameter PARAM1 = 8'b 01101101;
parameter PARAM2 = 8'b 11001101;
parameter PARAM3 = 8'b 00010111;
wire [7:0] param;
reg selection;
reg start; wire enf;  // Start and enable signals
wire [13:0] memdin;
wire [5:0] memaddr;
wire [13:0] memdout;
reg [1:0] colour;

  assign param = config == 1'b 1 ? PARAM1 : status == green ? PARAM2 : PARAM3;
  // Synchronously process
  always @(posedge clk) begin
    pixel_out <= pixel_in ^ 8'b 11001100;
  end

  // Synchronous process
  always @(posedge clk) begin
    case(status)
    red : begin
      colour <= 2'b 00;
    end
    green : begin
      colour <= 2'b 01;
    end
    blue : begin
      colour <= 2'b 10;
    end
    default : begin
      colour <= 2'b 11;
    end
    endcase
  end

  // Synchronous process with asynch reset
  always @(posedge clk or posedge rstn) begin
    if(rstn == 1'b 0) begin
      status <= red;
    end else begin
      case(status)
      red : begin
        if(pix_req == 1'b 1) begin
          status <= green;
        end
      end
      green : begin
        if(a[3] == 1'b 1) begin
          start <= start_dec;
          status <= blue;
        end
        else if(({b[5],a[3:2]}) == 3'b 001) begin
          status <= yellow;
        end
      end
      blue : begin
        status <= yellow;
      end
      default : begin
        start <= 1'b 0;
        status <= red;
      end
      endcase
    end
  end

  // Example of with statement
  always @(*) begin
    case(memaddr[2:0])
      3'b 000,3'b 110 : code[9:2] <= {3'b 110,pack[6:2]};
      3'b 101 : code[9:2] <= 8'b 11100010;
      3'b 010 : code[9:2] <= {8{1'b1}};
      3'b 011 : code[9:2] <= {8{1'b0}};
      default : code[9:2] <= a + b + 1'b 1;
    endcase
  end

  assign code1[1:0] = a[6:5] ^ ({a[4],b[6]});
  // Asynch process
  always @(we or addr or config or bip) begin
    if(we == 1'b 1) begin
      if(addr[2:0] == 3'b 100) begin
        selection <= 1'b 1;
      end
      else if(({b,a}) == {a,b} && bip == 1'b 0) begin
        selection <= config;
      end
      else begin
        selection <= 1'b 1;
      end
    end
    else begin
      selection <= 1'b 0;
    end
  end

  // Components instantiation
  dsp dsp_inst(
      // Inputs
    .clk(clk),
    .rstn(rstn),
    .en(en),
    .start(start),
    .param(param),
    .addr(addr),
    .din(din),
    .we(we),
    .memdin(memdin),
    // Outputs
    .dout(dout),
    .memaddr(memaddr),
    .memdout(memdout));

  mem dsp_mem(
      // Inputs
    .clk(clk),
    .rstn(rstn),
    .en(en),
    .cs(selection),
    .addr(memaddr),
    .din(memdout),
    // Outputs
    .dout(memdin));

  assign complex = {enf,(3'b 110 * load),qtd[3:0],base,5'b 11001};
  assign enf = a == (7'b 1101111 + load) && c < 7'b 1000111 ? 1'b 1 : 1'b 0;
  assign eno = enf;

endmodule
