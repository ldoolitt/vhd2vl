// no timescale needed

module expr(
input wire reset,
input wire sysclk,
input wire ival
);

parameter [31:0] SIZE=2 ** 8 - 1;



parameter SIZE_OF = 2 ** 8 - 1;
reg [13:0] foo;
wire [2:0] baz;
reg [22:0] bam;
wire [5:3] out_i;
wire [8:0] input_status;
wire enable; wire debug; wire aux; wire outy; wire dv; wire value;
wire [2 ** 3 - 1:0] expo;

  // drive input status
  assign input_status = {foo[9:4],(baz[2:0] & foo[3:0]) | ( ~baz[2:0] & bam[3:0])};
  // drive based on foo
  assign out_i[4] = (enable & (aux ^ outy)) | (debug & dv &  ~enable) | ( ~debug &  ~enable & value);
  // not drive
  always @(negedge reset, negedge sysclk) begin
    if((reset != 1'b0)) begin
      foo <= {14{1'b0}};
    end else begin
      foo[3 * (2 - 1)] <= baz[1 * (1 + 2) - 2];
      bam[13:0] <= foo;
    end
  end

  assign expo = 2 ** 4;

endmodule
