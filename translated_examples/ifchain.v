// no timescale needed

module ifchain(
input wire clk,
input wire rstn
);





wire [3:0] a;
wire [3:0] b;
reg status;
reg [31:0] c[3:0];

  always @(posedge clk) begin
    if({b[1],a[3:2]} == 3'b001) begin
      status <= 1'b1;
      c[0] <= 32'hFFFFFFFF;
    end
  end


endmodule
