// no timescale needed

module gen(
input wire sysclk,
input wire reset,
input wire wrb,
input wire [bus_width:0] din,
output wire [bus_width:0] rdout
);

parameter [31:0] bus_width=15;
parameter [31:0] TOP_GP2=0;



reg [bus_width * 2:0] regSelect;

  //---------------------------------------------------
  // Reg    : GP 2
  // Active : 32
  // Type   : RW
  //---------------------------------------------------
  genvar bitnum;
  generate for (bitnum=0; bitnum <= bus_width; bitnum = bitnum + 1) begin: reg_gp2
      wbit1 wbit1_inst(
          .clk(sysclk),
      .wrb(wrb),
      .reset(reset),
      .enb(regSelect[TOP_GP2]),
      .din(din[bitnum]),
      .dout(rdout[bitnum]));

  end
  endgenerate
  always @(posedge sysclk) begin
    regSelect[1] <= 1'b1;
  end


endmodule
