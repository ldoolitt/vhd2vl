// no timescale needed

module based(
sysclk
);

input sysclk;

wire sysclk;


wire [31:0] foo; wire [31:0] foo2; wire [31:0] foo8; wire [31:0] foo10; wire [31:0] foo11; wire [31:0] foo16;

  assign foo = 123;
  assign foo2 = 'B00101101110111;
  assign foo8 = 'O0177362;
  assign foo10 = 'D01234;
  assign foo11 = 11#01234#;
  assign foo16 = 'H12af;

endmodule
