// no timescale needed

module resize_demo(
input wire [3:0] u4,
output wire [7:0] y8,
output wire [1:0] y2
);





  assign y8 = {{(4){1'b0}},u4};
  // expect extension to 8 bits
  assign y2 = u4[1:0];
    // expect truncation to 2 bits

endmodule
