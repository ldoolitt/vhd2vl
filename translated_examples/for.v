// File for.vhd translated with vhd2vl v2.4 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 1995

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002, 2005, 2008-2010 Larry Doolittle - LBNL
//     http://doolittle.icarus.com/~larry/vhd2vl/
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

// no timescale needed

module forp(
reset,
sysclk
);

input reset, sysclk;

wire reset;
wire sysclk;


reg selection;
reg [6:0] egg_timer;

  always @(posedge reset or posedge sysclk) begin : P1
    reg [31:0] timer_var = 0;
    reg [31:0] a, i, j, k;
    reg [31:0] zz5;
    reg [511:0] zz;

    if(reset == 1'b 1) begin
      selection <= 1'b 1;
      timer_var = 2;
      egg_timer <= {7{1'b0}};
    end else begin
      //  pulse only lasts for once cycle
      selection <= 1'b 0;
      egg_timer <= {7{1'b1}};
      for (i=0; i <= j * k; i = i + 1) begin
        a = a + i;
        for (k=a - 9; k >=  -14; k = k - 1) begin
          zz5 = zz[31 + k:k];
        end
        // k
      end
      // i
    end
  end


endmodule
