// no timescale needed

module with_select_comb(
input wire [1:0] sel,
input wire [3:0] a,
input wire [3:0] b,
output wire [3:0] y
);




wire [3:0] sum4;

  assign sum4 = (a) + (b);
  // Verify WITH SELECT multi-choice (with '|' and others) stays combinational assign, avoiding reg/always conflict
  assign y = ((sel == 2'b00) || (sel == 2'b11)) ? a : ((sel == 2'b01)) ? b : sum4;

endmodule
