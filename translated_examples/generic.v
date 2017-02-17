// no timescale needed

module test(
reset,
sysclk,
a,
b,
enf,
load,
qtd,
base
);

parameter [7:0] dog_width=8'b10101100;
parameter [31:0] bus_width=32;
input reset, sysclk;
input [bus_width:0] a, b, enf, load, qtd, base;

wire reset;
wire sysclk;
wire [bus_width:0] a;
wire [bus_width:0] b;
wire [bus_width:0] enf;
wire [bus_width:0] load;
wire [bus_width:0] qtd;
wire [bus_width:0] base;


wire [1 + 1:0] foo;
reg [9:0] code; wire [9:0] code1;
wire [324:401] egg;
wire [bus_width * 3 - 1:bus_width * 4] baz;
wire [31:0] complex;

  // Example of with statement
  always @(*) begin
    case(foo[2:0])
      3'b000,3'b110 : code[9:2] <= {3'b110,egg[325:329]};
      3'b101 : code[9:2] <= 8'b11100010;
      3'b010 : code[9:2] <= {8{1'b1}};
      3'b011 : code[9:2] <= {8{1'b0}};
      default : code[9:2] <= (((a)) + ((b)));
    endcase
  end

  assign code1[1:0] = a[6:5] ^ ({a[4],b[6]});
  assign foo = {(((1 + 1))-((0))+1){1'b0}};
  assign egg = {78{1'b0}};
  assign baz = {(((bus_width * 4))-((bus_width * 3 - 1))+1){1'b1}};
  assign complex = {enf,((3'b110 * ((load)))),qtd[3:0],base,5'b11001};

endmodule
