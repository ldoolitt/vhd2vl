// no timescale needed

module whileloop(
input wire [31:0] A,
output reg [3:0] Z
);





  always @(A) begin : P1
    reg [31:0] I;

    Z <= 4'b0000;
    I = 0;
    while ((I <= 3)) begin
      if((A == I)) begin
        Z[I] <= 1'b1;
      end
      I = I + 1;
    end
  end


endmodule
