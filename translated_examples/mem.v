// no timescale needed

module mem(
input wire clk,
input wire rstn,
input wire en,
input wire cs,
input wire [addr_width - 1:0] addr,
input wire [bus_width - 1:0] din,
output wire [bus_width - 1:0] dout
);

parameter [31:0] addr_width=6;
parameter [31:0] bus_width=14;
// not implemented
// not implemented



reg [addr_width - 1:0] al = 8'h00;

reg [bus_width - 1:0] mem[255:0];

  assign dout = mem[al];
  always @(posedge clk) begin
    al <= addr;
    if(en == 1'b1) begin
      mem[addr] <= din;
    end
  end


endmodule
