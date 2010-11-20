// File counters.vhd translated with vhd2vl v2.4 VHDL to Verilog RTL translator
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

module counters(
sysclk,
foo_card,
wfoo0_baz,
wfoo0_blrb,
wfoo0_zz1pb,
wfoo0_turn,
debct_baz,
debct_blrb,
debct_zz1pb,
debct_bar,
debct_turn,
Z0_bar,
Z0_baz,
Z0_blrb,
Z0_zz1pb,
Z0_turn,
Y1_bar,
Y1_baz,
Y1_blrb,
Y1_zz1pb,
Y1_turn,
X2_bar,
X2_baz,
X2_blrb,
X2_zz1pb,
X2_turn,
W3_bar,
W3_baz,
W3_blrb,
W3_zz1pb,
W3_turn,
Z0_cwm,
Z0,
Y1_cwm,
Y1,
X2_cwm,
X2,
W3_cwm,
W3,
wfoo0_cwm,
wfoo0_llwln,
debct_cwm,
debct_pull,
debct,
wdfilecardA2P
);

input sysclk;
input foo_card;
input wfoo0_baz;
input wfoo0_blrb;
input wfoo0_zz1pb;
input [31:0] wfoo0_turn;
input debct_baz;
input debct_blrb;
input debct_zz1pb;
input debct_bar;
input [31:0] debct_turn;
input Z0_bar;
input Z0_baz;
input Z0_blrb;
input Z0_zz1pb;
input [31:0] Z0_turn;
input Y1_bar;
input Y1_baz;
input Y1_blrb;
input Y1_zz1pb;
input [31:0] Y1_turn;
input X2_bar;
input X2_baz;
input X2_blrb;
input X2_zz1pb;
input [31:0] X2_turn;
input W3_bar;
input W3_baz;
input W3_blrb;
input W3_zz1pb;
input [31:0] W3_turn;
// to engine block
output Z0_cwm;
output [31:0] Z0;
output Y1_cwm;
output [31:0] Y1;
output X2_cwm;
output [31:0] X2;
output W3_cwm;
output [31:0] W3;
output wfoo0_cwm;
output [31:0] wfoo0_llwln;
output debct_cwm;
output debct_pull;
output [31:0] debct;
output wdfilecardA2P;

wire sysclk;
wire foo_card;
wire wfoo0_baz;
wire wfoo0_blrb;
wire wfoo0_zz1pb;
wire [31:0] wfoo0_turn;
wire debct_baz;
wire debct_blrb;
wire debct_zz1pb;
wire debct_bar;
wire [31:0] debct_turn;
wire Z0_bar;
wire Z0_baz;
wire Z0_blrb;
wire Z0_zz1pb;
wire [31:0] Z0_turn;
wire Y1_bar;
wire Y1_baz;
wire Y1_blrb;
wire Y1_zz1pb;
wire [31:0] Y1_turn;
wire X2_bar;
wire X2_baz;
wire X2_blrb;
wire X2_zz1pb;
wire [31:0] X2_turn;
wire W3_bar;
wire W3_baz;
wire W3_blrb;
wire W3_zz1pb;
wire [31:0] W3_turn;
wire Z0_cwm;
wire [31:0] Z0;
wire Y1_cwm;
wire [31:0] Y1;
wire X2_cwm;
wire [31:0] X2;
wire W3_cwm;
wire [31:0] W3;
reg wfoo0_cwm;
wire [31:0] wfoo0_llwln;
wire debct_cwm;
reg debct_pull;
wire [31:0] debct;
wire wdfilecardA2P;


reg [31:0] wfoo0_llwln_var;
reg [31:0] debct_var;
reg [31:0] Z0_var;
reg [31:0] Y1_var;
reg [31:0] X2_var;
reg [31:0] W3_var;
reg main_wfoo0_cwm;
reg do_q3p_Z0;
reg do_q3p_Y1;
reg do_q3p_X2;
reg do_q3p_W3;
reg do_q3p_wfoo0;
reg do_q3p_debct;
reg Z0_cwm_i;
reg Y1_cwm_i;
reg X2_cwm_i;
reg W3_cwm_i;
reg debct_cwm_i;
reg file_card_i;
reg do_file_card_i;
reg prev_do_file_card;

  //---
  // form the outputs
  assign wfoo0_llwln = (wfoo0_llwln_var);
  assign debct = (debct_var);
  assign Z0 = (Z0_var);
  assign Y1 = (Y1_var);
  assign X2 = (X2_var);
  assign W3 = (W3_var);
  assign Z0_cwm = Z0_cwm_i;
  assign Y1_cwm = Y1_cwm_i;
  assign X2_cwm = X2_cwm_i;
  assign W3_cwm = W3_cwm_i;
  assign debct_cwm = debct_cwm_i;
  assign wdfilecardA2P = do_file_card_i;
  always @(posedge foo_card or posedge sysclk) begin
    if(foo_card == 1'b 1) begin
      wfoo0_llwln_var <= {32{1'b0}};
      debct_var <= {32{1'b0}};
      Z0_var <= {32{1'b0}};
      Y1_var <= {32{1'b0}};
      X2_var <= {32{1'b0}};
      W3_var <= {32{1'b0}};
      wfoo0_cwm <= 1'b 0;
      debct_cwm_i <= 1'b 0;
      debct_pull <= 1'b 0;
      Z0_cwm_i <= 1'b 0;
      Y1_cwm_i <= 1'b 0;
      X2_cwm_i <= 1'b 0;
      W3_cwm_i <= 1'b 0;
      main_wfoo0_cwm <= 1'b 0;
      file_card_i <= 1'b 0;
      do_q3p_wfoo0 <= 1'b 0;
      do_file_card_i <= 1'b 0;
      prev_do_file_card <= 1'b 0;
      do_q3p_Z0 <= 1'b 0;
      do_q3p_Y1 <= 1'b 0;
      do_q3p_X2 <= 1'b 0;
      do_q3p_W3 <= 1'b 0;
      do_q3p_debct <= 1'b 0;
    end else begin
      // pull
      debct_pull <= 1'b 0;
      do_file_card_i <= 1'b 0;
      //--
      //  wfoo0
      if(wfoo0_baz == 1'b 1) begin
        wfoo0_llwln_var <= (wfoo0_turn);
        main_wfoo0_cwm <= 1'b 0;
        if(wfoo0_llwln_var == 32'b 00000000000000000000000000000000) begin
          do_q3p_wfoo0 <= 1'b 0;
        end
        else begin
          do_q3p_wfoo0 <= 1'b 1;
        end
      end
      else begin
        if(do_q3p_wfoo0 == 1'b 1 && wfoo0_blrb == 1'b 1) begin
          wfoo0_llwln_var <= wfoo0_llwln_var - 1;
          if((wfoo0_llwln_var == 32'b 00000000000000000000000000000000)) begin
            wfoo0_llwln_var <= (wfoo0_turn);
            if(main_wfoo0_cwm == 1'b 0) begin
              wfoo0_cwm <= 1'b 1;
              main_wfoo0_cwm <= 1'b 1;
            end
            else begin
              do_file_card_i <= 1'b 1;
              do_q3p_wfoo0 <= 1'b 0;
            end
          end
        end
      end
      if(wfoo0_zz1pb == 1'b 0) begin
        wfoo0_cwm <= 1'b 0;
      end
      if(Z0_baz == 1'b 1) begin
        // counter Baz
        Z0_var <= (Z0_turn);
        if(Z0_turn == 32'b 00000000000000000000000000000000) begin
          do_q3p_Z0 <= 1'b 0;
        end
        else begin
          do_q3p_Z0 <= 1'b 1;
        end
      end
      else begin
        if(do_q3p_Z0 == 1'b 1 && Z0_blrb == 1'b 1) begin
          if(Z0_bar == 1'b 0) begin
            if(Z0_cwm_i == 1'b 0) begin
              if(do_q3p_Z0 == 1'b 1) begin
                Z0_var <= Z0_var - 1;
                if((Z0_var == 32'b 00000000000000000000000000000001)) begin
                  Z0_cwm_i <= 1'b 1;
                  do_q3p_Z0 <= 1'b 0;
                end
              end
            end
          end
          else begin
            Z0_var <= Z0_var - 1;
            if((Z0_var == 32'b 00000000000000000000000000000000)) begin
              Z0_cwm_i <= 1'b 1;
              Z0_var <= (Z0_turn);
            end
          end
          // Z0_bar
        end
      end
      // Z0_blrb
      if(Z0_zz1pb == 1'b 0) begin
        Z0_cwm_i <= 1'b 0;
      end
      if(Y1_baz == 1'b 1) begin
        // counter Baz
        Y1_var <= (Y1_turn);
        if(Y1_turn == 32'b 00000000000000000000000000000000) begin
          do_q3p_Y1 <= 1'b 0;
        end
        else begin
          do_q3p_Y1 <= 1'b 1;
        end
      end
      else if(do_q3p_Y1 == 1'b 1 && Y1_blrb == 1'b 1) begin
        if(Y1_bar == 1'b 0) begin
          if(Y1_cwm_i == 1'b 0) begin
            if(do_q3p_Y1 == 1'b 1) begin
              Y1_var <= Y1_var - 1;
              if((Y1_var == 32'b 00000000000000000000000000000001)) begin
                Y1_cwm_i <= 1'b 1;
                do_q3p_Y1 <= 1'b 0;
              end
            end
          end
        end
        else begin
          Y1_var <= Y1_var - 1;
          if((Y1_var == 32'b 00000000000000000000000000000000)) begin
            Y1_cwm_i <= 1'b 1;
            Y1_var <= (Y1_turn);
          end
        end
        // Y1_bar
      end
      // Y1_blrb
      if(Y1_zz1pb == 1'b 0) begin
        Y1_cwm_i <= 1'b 0;
      end
      if(X2_baz == 1'b 1) begin
        // counter Baz
        X2_var <= (X2_turn);
        if(X2_turn == 32'b 00000000000000000000000000000000) begin
          do_q3p_X2 <= 1'b 0;
        end
        else begin
          do_q3p_X2 <= 1'b 1;
        end
      end
      else if(do_q3p_X2 == 1'b 1 && X2_blrb == 1'b 1) begin
        if(X2_bar == 1'b 0) begin
          if(X2_cwm_i == 1'b 0) begin
            if(do_q3p_X2 == 1'b 1) begin
              X2_var <= X2_var - 1;
              if((X2_var == 32'b 00000000000000000000000000000001)) begin
                X2_cwm_i <= 1'b 1;
                do_q3p_X2 <= 1'b 0;
              end
            end
          end
        end
        else begin
          X2_var <= X2_var - 1;
          if((X2_var == 32'b 00000000000000000000000000000000)) begin
            //{
            X2_cwm_i <= 1'b 1;
            X2_var <= (X2_turn);
          end
        end
        //X2_bar
      end
      // X2_blrb
      if(X2_zz1pb == 1'b 0) begin
        X2_cwm_i <= 1'b 0;
      end
      if(W3_baz == 1'b 1) begin
        // counter Baz
        W3_var <= (W3_turn);
        if(W3_turn == 32'b 00000000000000000000000000000000) begin
          do_q3p_W3 <= 1'b 0;
        end
        else begin
          do_q3p_W3 <= 1'b 1;
        end
      end
      else if(do_q3p_W3 == 1'b 1 && W3_blrb == 1'b 1) begin
        if(W3_bar == 1'b 0) begin
          if(W3_cwm_i == 1'b 0) begin
            if(do_q3p_W3 == 1'b 1) begin
              W3_var <= W3_var - 1;
              if((W3_var == 32'b 00000000000000000000000000000001)) begin
                W3_cwm_i <= 1'b 1;
                do_q3p_W3 <= 1'b 0;
              end
            end
          end
        end
        else begin
          W3_var <= W3_var - 1;
          if((W3_var == 32'b 00000000000000000000000000000000)) begin
            //{
            W3_cwm_i <= 1'b 1;
            W3_var <= (W3_turn);
          end
        end
        // W3_bar
      end
      // W3_blrb
      if(W3_zz1pb == 1'b 0) begin
        W3_cwm_i <= 1'b 0;
      end
      if(debct_baz == 1'b 1) begin
        // counter Baz
        debct_var <= (debct_turn);
        if(debct_turn == 32'b 00000000000000000000000000000000) begin
          do_q3p_debct <= 1'b 0;
        end
        else begin
          do_q3p_debct <= 1'b 1;
        end
      end
      else if(do_q3p_debct == 1'b 1 && debct_blrb == 1'b 1) begin
        if(debct_bar == 1'b 0) begin
          if(debct_cwm_i == 1'b 0) begin
            if(do_q3p_debct == 1'b 1) begin
              debct_var <= debct_var - 1;
              if((debct_var == 32'b 00000000000000000000000000000001)) begin
                debct_cwm_i <= 1'b 1;
                debct_pull <= 1'b 1;
                do_q3p_debct <= 1'b 0;
              end
            end
          end
        end
        else begin
          //-- T
          //  Continue
          debct_var <= debct_var - 1;
          // ending
          if((debct_var == 32'b 00000000000000000000000000000000)) begin
            //{
            debct_cwm_i <= 1'b 1;
            debct_pull <= 1'b 1;
            debct_var <= (debct_turn);
          end
        end
        // debct_bar
      end
      // debct_blrb
      // comment
      if(debct_zz1pb == 1'b 0) begin
        debct_cwm_i <= 1'b 0;
      end
    end
  end


endmodule
