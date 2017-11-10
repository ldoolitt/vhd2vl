// no timescale needed

module signextend(
input wire [15:0] i,
output wire [31:0] o
);





  assign o[31:24] = {8{1'b0}};
  assign o[23:16] = {8{i[15]}};
  assign o[15:0] = i;

endmodule
