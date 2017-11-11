// Nearly useless stub, it's here to support generate.vhd
// no timescale needed

module wbit1(
input wire clk,
input wire wrb,
input wire reset,
input wire enb,
input wire din,
output reg dout
);




wire foo;

  always @(clk) begin
    dout <= 1'b1;
  end


endmodule
