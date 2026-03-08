// no timescale needed

module agg_risk(
input wire a,
input wire b,
output reg y
);





  // Concatenation selector uses op='c' and must be wrapped in Verilog.
  // If not wrapped, this becomes "case(a,b)".
  always @(*) begin
    case({a,b})
      2'b00 : y <= 1'b0;
      2'b01 : y <= 1'b1;
      2'b10 : y <= 1'b0;
      default : y <= 1'b1;
    endcase
  end


endmodule
