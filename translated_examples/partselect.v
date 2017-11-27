// no timescale needed

module partselect(
input wire clk_i
);




reg [31:0] big_sig;
reg [0:31] lit_sig;
wire [31:0] i = 8;

  always @(posedge clk_i) begin : P1
    reg [31:0] big_var;
    reg [0:31] lit_var;
    reg [31:0] j;

    big_sig[31:24] <= big_sig[7:0];
    big_var[31:24] = big_var[7:0];
    lit_sig[i * 3 +: 7 + 1] <= lit_sig[0:7];
    lit_var[j * 3 +: 8 + 1] = lit_var[j * 0 +: 8 + 1];
    //
    big_sig[i * 3 + 8 -: 8 + 1] <= big_sig[8:0];
    big_var[j * 3 + 8 -: 8 + 1] = big_var[j * 0 + 8 -: 8 + 1];
  end


endmodule
