// no timescale needed

module counters(
input wire sysclk,
input wire foo_card,
input wire wfoo0_baz,
input wire wfoo0_blrb,
input wire wfoo0_zz1pb,
input wire [31:0] wfoo0_turn,
input wire debct_baz,
input wire debct_blrb,
input wire debct_zz1pb,
input wire debct_bar,
input wire [31:0] debct_turn,
input wire Z0_bar,
input wire Z0_baz,
input wire Z0_blrb,
input wire Z0_zz1pb,
input wire [31:0] Z0_turn,
input wire Y1_bar,
input wire Y1_baz,
input wire Y1_blrb,
input wire Y1_zz1pb,
input wire [31:0] Y1_turn,
input wire X2_bar,
input wire X2_baz,
input wire X2_blrb,
input wire X2_zz1pb,
input wire [31:0] X2_turn,
input wire W3_bar,
input wire W3_baz,
input wire W3_blrb,
input wire W3_zz1pb,
input wire [31:0] W3_turn,
output wire Z0_cwm,
output wire [31:0] Z0,
output wire Y1_cwm,
output wire [31:0] Y1,
output wire X2_cwm,
output wire [31:0] X2,
output wire W3_cwm,
output wire [31:0] W3,
output reg wfoo0_cwm,
output wire [31:0] wfoo0_llwln,
output wire debct_cwm,
output reg debct_pull,
output wire [31:0] debct,
output wire wdfilecardA2P
);

// to engine block



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
  assign wfoo0_llwln = wfoo0_llwln_var;
  assign debct = debct_var;
  assign Z0 = Z0_var;
  assign Y1 = Y1_var;
  assign X2 = X2_var;
  assign W3 = W3_var;
  assign Z0_cwm = Z0_cwm_i;
  assign Y1_cwm = Y1_cwm_i;
  assign X2_cwm = X2_cwm_i;
  assign W3_cwm = W3_cwm_i;
  assign debct_cwm = debct_cwm_i;
  assign wdfilecardA2P = do_file_card_i;
  always @(posedge foo_card, posedge sysclk) begin
    if(foo_card == 1'b1) begin
      wfoo0_llwln_var <= {32{1'b0}};
      debct_var <= {32{1'b0}};
      Z0_var <= {32{1'b0}};
      Y1_var <= {32{1'b0}};
      X2_var <= {32{1'b0}};
      W3_var <= {32{1'b0}};
      wfoo0_cwm <= 1'b0;
      debct_cwm_i <= 1'b0;
      debct_pull <= 1'b0;
      Z0_cwm_i <= 1'b0;
      Y1_cwm_i <= 1'b0;
      X2_cwm_i <= 1'b0;
      W3_cwm_i <= 1'b0;
      main_wfoo0_cwm <= 1'b0;
      file_card_i <= 1'b0;
      do_q3p_wfoo0 <= 1'b0;
      do_file_card_i <= 1'b0;
      prev_do_file_card <= 1'b0;
      do_q3p_Z0 <= 1'b0;
      do_q3p_Y1 <= 1'b0;
      do_q3p_X2 <= 1'b0;
      do_q3p_W3 <= 1'b0;
      do_q3p_debct <= 1'b0;
    end else begin
      // pull
      debct_pull <= 1'b0;
      do_file_card_i <= 1'b0;
      //--
      //  wfoo0
      if(wfoo0_baz == 1'b1) begin
        wfoo0_llwln_var <= wfoo0_turn;
        main_wfoo0_cwm <= 1'b0;
        if(wfoo0_llwln_var == 32'b00000000000000000000000000000000) begin
          do_q3p_wfoo0 <= 1'b0;
        end
        else begin
          do_q3p_wfoo0 <= 1'b1;
        end
      end
      else begin
        if(do_q3p_wfoo0 == 1'b1 && wfoo0_blrb == 1'b1) begin
          wfoo0_llwln_var <= wfoo0_llwln_var - 1;
          if((wfoo0_llwln_var == 32'b00000000000000000000000000000000)) begin
            wfoo0_llwln_var <= wfoo0_turn;
            if(main_wfoo0_cwm == 1'b0) begin
              wfoo0_cwm <= 1'b1;
              main_wfoo0_cwm <= 1'b1;
            end
            else begin
              do_file_card_i <= 1'b1;
              do_q3p_wfoo0 <= 1'b0;
            end
          end
        end
      end
      if(wfoo0_zz1pb == 1'b0) begin
        wfoo0_cwm <= 1'b0;
      end
      if(Z0_baz == 1'b1) begin
        // counter Baz
        Z0_var <= Z0_turn;
        if(Z0_turn == 32'b00000000000000000000000000000000) begin
          do_q3p_Z0 <= 1'b0;
        end
        else begin
          do_q3p_Z0 <= 1'b1;
        end
      end
      else begin
        if(do_q3p_Z0 == 1'b1 && Z0_blrb == 1'b1) begin
          if(Z0_bar == 1'b0) begin
            if(Z0_cwm_i == 1'b0) begin
              if(do_q3p_Z0 == 1'b1) begin
                Z0_var <= Z0_var - 1;
                if((Z0_var == 32'b00000000000000000000000000000001)) begin
                  Z0_cwm_i <= 1'b1;
                  do_q3p_Z0 <= 1'b0;
                end
              end
            end
          end
          else begin
            Z0_var <= Z0_var - 1;
            if((Z0_var == 32'b00000000000000000000000000000000)) begin
              Z0_cwm_i <= 1'b1;
              Z0_var <= Z0_turn;
            end
          end
          // Z0_bar
        end
      end
      // Z0_blrb
      if(Z0_zz1pb == 1'b0) begin
        Z0_cwm_i <= 1'b0;
      end
      if(Y1_baz == 1'b1) begin
        // counter Baz
        Y1_var <= Y1_turn;
        if(Y1_turn == 32'b00000000000000000000000000000000) begin
          do_q3p_Y1 <= 1'b0;
        end
        else begin
          do_q3p_Y1 <= 1'b1;
        end
      end
      else if(do_q3p_Y1 == 1'b1 && Y1_blrb == 1'b1) begin
        if(Y1_bar == 1'b0) begin
          if(Y1_cwm_i == 1'b0) begin
            if(do_q3p_Y1 == 1'b1) begin
              Y1_var <= Y1_var - 1;
              if((Y1_var == 32'b00000000000000000000000000000001)) begin
                Y1_cwm_i <= 1'b1;
                do_q3p_Y1 <= 1'b0;
              end
            end
          end
        end
        else begin
          Y1_var <= Y1_var - 1;
          if((Y1_var == 32'b00000000000000000000000000000000)) begin
            Y1_cwm_i <= 1'b1;
            Y1_var <= Y1_turn;
          end
        end
        // Y1_bar
      end
      // Y1_blrb
      if(Y1_zz1pb == 1'b0) begin
        Y1_cwm_i <= 1'b0;
      end
      if(X2_baz == 1'b1) begin
        // counter Baz
        X2_var <= X2_turn;
        if(X2_turn == 32'b00000000000000000000000000000000) begin
          do_q3p_X2 <= 1'b0;
        end
        else begin
          do_q3p_X2 <= 1'b1;
        end
      end
      else if(do_q3p_X2 == 1'b1 && X2_blrb == 1'b1) begin
        if(X2_bar == 1'b0) begin
          if(X2_cwm_i == 1'b0) begin
            if(do_q3p_X2 == 1'b1) begin
              X2_var <= X2_var - 1;
              if((X2_var == 32'b00000000000000000000000000000001)) begin
                X2_cwm_i <= 1'b1;
                do_q3p_X2 <= 1'b0;
              end
            end
          end
        end
        else begin
          X2_var <= X2_var - 1;
          if((X2_var == 32'b00000000000000000000000000000000)) begin
            //{
            X2_cwm_i <= 1'b1;
            X2_var <= X2_turn;
          end
        end
        //X2_bar
      end
      // X2_blrb
      if(X2_zz1pb == 1'b0) begin
        X2_cwm_i <= 1'b0;
      end
      if(W3_baz == 1'b1) begin
        // counter Baz
        W3_var <= W3_turn;
        if(W3_turn == 32'b00000000000000000000000000000000) begin
          do_q3p_W3 <= 1'b0;
        end
        else begin
          do_q3p_W3 <= 1'b1;
        end
      end
      else if(do_q3p_W3 == 1'b1 && W3_blrb == 1'b1) begin
        if(W3_bar == 1'b0) begin
          if(W3_cwm_i == 1'b0) begin
            if(do_q3p_W3 == 1'b1) begin
              W3_var <= W3_var - 1;
              if((W3_var == 32'b00000000000000000000000000000001)) begin
                W3_cwm_i <= 1'b1;
                do_q3p_W3 <= 1'b0;
              end
            end
          end
        end
        else begin
          W3_var <= W3_var - 1;
          if((W3_var == 32'b00000000000000000000000000000000)) begin
            //{
            W3_cwm_i <= 1'b1;
            W3_var <= W3_turn;
          end
        end
        // W3_bar
      end
      // W3_blrb
      if(W3_zz1pb == 1'b0) begin
        W3_cwm_i <= 1'b0;
      end
      if(debct_baz == 1'b1) begin
        // counter Baz
        debct_var <= debct_turn;
        if(debct_turn == 32'b00000000000000000000000000000000) begin
          do_q3p_debct <= 1'b0;
        end
        else begin
          do_q3p_debct <= 1'b1;
        end
      end
      else if(do_q3p_debct == 1'b1 && debct_blrb == 1'b1) begin
        if(debct_bar == 1'b0) begin
          if(debct_cwm_i == 1'b0) begin
            if(do_q3p_debct == 1'b1) begin
              debct_var <= debct_var - 1;
              if((debct_var == 32'b00000000000000000000000000000001)) begin
                debct_cwm_i <= 1'b1;
                debct_pull <= 1'b1;
                do_q3p_debct <= 1'b0;
              end
            end
          end
        end
        else begin
          //-- T
          //  Continue
          debct_var <= debct_var - 1;
          // ending
          if((debct_var == 32'b00000000000000000000000000000000)) begin
            //{
            debct_cwm_i <= 1'b1;
            debct_pull <= 1'b1;
            debct_var <= debct_turn;
          end
        end
        // debct_bar
      end
      // debct_blrb
      // comment
      if(debct_zz1pb == 1'b0) begin
        debct_cwm_i <= 1'b0;
      end
    end
  end


endmodule
