// no timescale needed

module conv_integer_sink(
input wire [31:0] val_u,
input wire [31:0] val_i,
input wire [31:0] val_u4,
input wire [31:0] val_i4,
input wire [31:0] val_u_port,
input wire [31:0] val_i_port
);





    // keep empty, only for verifying expression conversion in port map

endmodule

module conv_integer_demo(
input wire [7:0] s,
output wire [31:0] u,
output wire [31:0] i
);




parameter s_test_neg = 8'hFF;
wire [3:0] sig_4 = 4'b1111;

  // conv_integer should be parsed as CONVFUNC_1 and preserved as expr
  assign u = $unsigned(s) + 1;
  assign i = $signed(s);
  // conv_integer in port map: constant/signal/port, signed/unsigned, various widths
  conv_integer_sink sink_inst(
    // constant (param_list): 8-bit
    .val_u({{24{1'b0}},$unsigned(s_test_neg)}),
    // expected 255
    .val_i({{24{s_test_neg[7]}},$signed(s_test_neg)}),
    // expected -1
    // signal (sig_list): 4-bit
    .val_u4({{28{1'b0}},$unsigned(sig_4)}),
    // expected 15
    .val_i4({{28{sig_4[3]}},$signed(sig_4)}),
    // expected -1
    // port (io_list): 8-bit
    .val_u_port({{24{1'b0}},$unsigned(s)}),
    .val_i_port({{24{s[7]}},$signed(s)}));


endmodule
