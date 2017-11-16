// Nearly useless stub, it's here to support genericmap.vhd
// no timescale needed

module dsp(
input wire clk,
input wire rstn,
input wire en,
input wire start,
input wire [7:0] param,
input wire [2:0] addr,
input wire [bus_width - 1:0] din,
input wire we,
output wire [13:0] memdin,
output reg [bus_width - 1:0] dout,
output wire [5:0] memaddr,
output wire [13:0] memdout
);

parameter rst_val=1'b0;
parameter [31:0] thing_size=201;
parameter [31:0] bus_width=24;
// Inputs
// Outputs



wire foo;

  always @(clk) begin
    dout <= ((1));
  end


endmodule
