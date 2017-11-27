// no timescale needed

module todo(
input wire clk_i,
input wire [7:0] data_i,
output wire [7:0] data_o
);





wire [31:0] mem[0:255];
wire [31:0] int;
wire [7:0] uns;

  //**************************************************************************
  // Wrong translations
  //**************************************************************************
  //
  always @(clk_i) begin : P1
  // iverilog: variable declaration assignments are only allowed at the module level.
    reg [31:0] i = 8;

    for (i=0; i <= 7; i = i + 1) begin
      if(i == 4) begin
        disable;  //VHD2VL: add block name here
        // iverilog: error: malformed statement
      end
    end
  end

    //**************************************************************************
  // Translations which abort with syntax error (uncomment to test)
  //**************************************************************************
  // Concatenation in port assignament fail
  //   uns <= "0000" & X"1"; -- It is supported
  //   dut1_i: signextend
  //      port map (
  //        i => "00000000" & X"11", -- But here fail
  //        o => open
  //      );
  // Unsupported type of instantiation
  //   dut2_i: entity work.signextend
  //   port map (
  //      i => (others => '0'),
  //      o => open
  //   );

endmodule
