// no timescale needed

module genericmap(
input wire clk,
input wire rstn,
input wire en,
input wire start_dec,
input wire [2:0] addr,
input wire [25:0] din,
input wire we,
input wire [7:0] pixel_in,
input wire pix_req,
input wire bip,
input wire [7:0] a,
input wire [7:0] b,
input wire [7:0] c,
input wire [7:0] load,
input wire [6:0] pack,
input wire [2:0] base,
input wire [21:0] qtd,
output wire [25:0] dout,
output wire [7:0] pixel_out,
output wire pixel_valid,
output wire [9:0] code,
output wire [23:0] complex,
output wire eno
);

parameter rst_val=1'b0;
parameter [31:0] thing_size=201;
parameter [31:0] bus_width=201 % 32;
// Outputs



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
    .en(1'b1),
    .start(1'b0),
    .param(8'h42),
    .addr(3'b101),
    .din(24'h111111),
    .we(1'b0),
    // Outputs
    .dout(dout[23:0]),
    .memaddr(memaddr),
    .memdout(memdout));

  dsp #(
      .rst_val(1'b1),
    .bus_width(16))
  dsp_inst1(
      // Inputs
    .clk(clk),
    .rstn(rstn),
    .en(1'b1),
    .start(1'b0),
    .param(8'h42),
    .addr(3'b101),
    .din(16'h1111),
    .we(1'b0),
    // Outputs
    .dout(dout[15:0]),
    .memaddr(memaddr),
    .memdout(memdout));


endmodule
