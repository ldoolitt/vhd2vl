// File bigfile.vhd translated with vhd2vl v2.4 VHDL to Verilog RTL translator
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

// CONNECTIVITY DEFINITION
// no timescale needed

module bigfile(
sysclk,
g_zaq_in,
g_aux,
scanb,
g_wrb,
g_rdb,
g_noop_clr,
swe_ed,
swe_lv,
din,
g_dout_w0x0f,
n9_bit_write,
reset,
alu_u,
debct_ping,
g_sys_in,
g_zaq_in_rst_hold,
g_zaq_hhh_enb,
g_zaq_out,
g_dout,
g_zaq_ctl,
g_zaq_qaz_hb,
g_zaq_qaz_lb,
gwerth,
g_noop,
g_vector,
swe_qaz1
);

// from external pins
input sysclk;
input [31:0] g_zaq_in;
input [31:0] g_aux;
input scanb;
input g_wrb;
input g_rdb;
input [31:0] g_noop_clr;
input swe_ed;
input swe_lv;
input [63:0] din;
input [4:0] g_dout_w0x0f;
input n9_bit_write;
// from reset_gen block
input reset;
input [31:0] alu_u;
input debct_ping;
output [31:0] g_sys_in;
output [31:0] g_zaq_in_rst_hold;
output [31:0] g_zaq_hhh_enb;
output [31:0] g_zaq_out;
output [31:0] g_dout;
output [31:0] g_zaq_ctl;
output [31:0] g_zaq_qaz_hb;
output [31:0] g_zaq_qaz_lb;
output [31:0] gwerth;
output [31:0] g_noop;
output [8 * 32 - 1:0] g_vector;
output [31:0] swe_qaz1;

wire sysclk;
wire [31:0] g_zaq_in;
wire [31:0] g_aux;
wire scanb;
wire g_wrb;
wire g_rdb;
wire [31:0] g_noop_clr;
wire swe_ed;
wire swe_lv;
wire [63:0] din;
wire [4:0] g_dout_w0x0f;
wire n9_bit_write;
wire reset;
wire [31:0] alu_u;
wire debct_ping;
wire [31:0] g_sys_in;
wire [31:0] g_zaq_in_rst_hold;
wire [31:0] g_zaq_hhh_enb;
wire [31:0] g_zaq_out;
wire [31:0] g_dout;
wire [31:0] g_zaq_ctl;
wire [31:0] g_zaq_qaz_hb;
wire [31:0] g_zaq_qaz_lb;
reg [31:0] gwerth;
wire [31:0] g_noop;
reg [8 * 32 - 1:0] g_vector;
reg [31:0] swe_qaz1;


// IMPLEMENTATION
// constants 
parameter g_t_klim_w0x0f = 5'b 00000;
parameter g_t_u_w0x0f = 5'b 00001;
parameter g_t_l_w0x0f = 5'b 00010;
parameter g_t_hhh_l_w0x0f = 5'b 00011;
parameter g_t_jkl_sink_l_w0x0f = 5'b 00100;
parameter g_secondary_t_l_w0x0f = 5'b 00101;
parameter g_style_c_l_w0x0f = 5'b 00110;
parameter g_e_z_w0x0f = 5'b 00111;
parameter g_n_both_qbars_l_w0x0f = 5'b 01000;
parameter g_style_vfr_w0x0f = 5'b 01001;
parameter g_style_klim_w0x0f = 5'b 01010;
parameter g_unklimed_style_vfr_w0x0f = 5'b 01011;
parameter g_style_t_y_w0x0f = 5'b 01100;
parameter g_n_l_w0x0f = 5'b 01101;
parameter g_n_vfr_w0x0f = 5'b 01110;
parameter g_e_n_r_w0x0f = 5'b 01111;
parameter g_n_r_bne_w0x0f = 5'b 10000;
parameter g_n_div_rebeq_w0x0f = 5'b 10001;
parameter g_alu_l_w0x0f = 5'b 10010;
parameter g_t_qaz_mult_low_w0x0f = 5'b 10011;
parameter g_t_qaz_mult_high_w0x0f = 5'b 10100;
parameter gwerthernal_style_u_w0x0f = 5'b 10101;
parameter gwerthernal_style_l_w0x0f = 5'b 10110;
parameter g_style_main_reset_hold_w0x0f = 5'b 10111;  // comment
reg [31:0] g_t_klim_dout;
reg [31:0] g_t_u_dout;
reg [31:0] g_t_l_dout;
reg [31:0] g_t_hhh_l_dout;
reg [31:0] g_t_jkl_sink_l_dout;
reg [31:0] g_secondary_t_l_dout;
reg [3:0] g_style_c_l_dout;  // not used
reg [31:0] g_e_z_dout;
reg [31:0] g_n_both_qbars_l_dout;
wire [31:0] g_style_vfr_dout;
reg [31:0] g_style_klim_dout;
wire [31:0] g_unklimed_style_vfr_dout;
reg [31:0] g_style_t_y_dout;
reg [31:0] g_n_l_dout;
reg [31:0] g_n_vfr_dout;
reg [31:0] g_e_n_r_dout;
reg g_n_r_bne_dout;
reg [31:0] g_n_div_rebeq_dout;
reg [31:0] g_alu_l_dout;
reg [31:0] g_t_qaz_mult_low_dout;
reg [31:0] g_t_qaz_mult_high_dout;
reg [31:0] gwerthernal_style_u_dout;
reg [31:0] gwerthernal_style_l_dout;
reg [31:0] g_style_main_reset_hold_dout;  // other
reg [31:0] q_g_zaq_in;
reg [31:0] q2_g_zaq_in;
reg [31:0] q3_g_zaq_in;
reg [3:0] q_g_zaq_in_cd;
reg [31:0] q_g_style_vfr_dout;
reg [3:0] q_g_unzq;  // i
wire [31:0] g_n_active;  // inter
wire [31:0] g_zaq_in_y;
wire [31:0] g_zaq_in_y_no_dout;
wire [31:0] g_zaq_out_i;
wire [31:0] g_zaq_ctl_i;
wire [31:0] g_sys_in_i;
wire [31:0] g_sys_in_ii;
wire [31:0] g_dout_i;

  // qaz out
  assign g_zaq_out_i = ((g_secondary_t_l_dout & ((g_aux ^ g_style_t_y_dout)))) | ((g_alu_l_dout & alu_u &  ~g_secondary_t_l_dout)) | (( ~g_alu_l_dout &  ~g_secondary_t_l_dout & g_t_u_dout));
  // Changed
  assign g_zaq_out = g_zaq_out_i &  ~g_t_jkl_sink_l_dout;
  // qaz 
  // JLB
  assign g_zaq_ctl_i =  ~((((g_t_l_dout &  ~g_t_jkl_sink_l_dout)) | ((g_t_l_dout & g_t_jkl_sink_l_dout &  ~g_zaq_out_i))));
  // mux
  //vnavigatoroff
  assign g_zaq_ctl = scanb == 1'b 1 ? g_zaq_ctl_i : 32'b 00000000000000000000000000000000;
  //vnavigatoron
  assign g_zaq_hhh_enb =  ~((g_t_hhh_l_dout));
  assign g_zaq_qaz_hb = g_t_qaz_mult_high_dout;
  assign g_zaq_qaz_lb = g_t_qaz_mult_low_dout;
  // Dout
  assign g_dout_i = g_dout_w0x0f == g_t_klim_w0x0f ? g_t_klim_dout & g_style_klim_dout : g_dout_w0x0f == g_t_u_w0x0f ? g_t_u_dout & g_style_klim_dout : g_dout_w0x0f == g_t_l_w0x0f ? g_t_l_dout & g_style_klim_dout : g_dout_w0x0f == g_t_hhh_l_w0x0f ? g_t_hhh_l_dout & g_style_klim_dout : g_dout_w0x0f == g_t_jkl_sink_l_w0x0f ? g_t_jkl_sink_l_dout & g_style_klim_dout : g_dout_w0x0f == g_secondary_t_l_w0x0f ? g_secondary_t_l_dout & g_style_klim_dout : g_dout_w0x0f == g_style_c_l_w0x0f ? ({28'b 0000000000000000000000000000,g_style_c_l_dout}) & g_style_klim_dout : g_dout_w0x0f == g_e_z_w0x0f ? g_e_z_dout : g_dout_w0x0f == g_n_both_qbars_l_w0x0f ? g_n_both_qbars_l_dout : g_dout_w0x0f == g_style_vfr_w0x0f ? g_style_vfr_dout & g_style_klim_dout : g_dout_w0x0f == g_style_klim_w0x0f ? g_style_klim_dout : g_dout_w0x0f == g_unklimed_style_vfr_w0x0f ? g_unklimed_style_vfr_dout : g_dout_w0x0f == g_style_t_y_w0x0f ? g_style_t_y_dout & g_style_klim_dout : g_dout_w0x0f == g_n_l_w0x0f ? g_n_l_dout : g_dout_w0x0f == g_n_vfr_w0x0f ? g_n_vfr_dout : g_dout_w0x0f == g_e_n_r_w0x0f ? g_e_n_r_dout : g_dout_w0x0f == g_n_r_bne_w0x0f ? {31'b 0000000000000000000000000000000,g_n_r_bne_dout} : g_dout_w0x0f == g_n_div_rebeq_w0x0f ? g_n_div_rebeq_dout : g_dout_w0x0f == g_alu_l_w0x0f ? g_alu_l_dout & g_style_klim_dout : g_dout_w0x0f == g_t_qaz_mult_low_w0x0f ? g_t_qaz_mult_low_dout & g_style_klim_dout : g_dout_w0x0f == g_t_qaz_mult_high_w0x0f ? g_t_qaz_mult_high_dout & g_style_klim_dout : g_dout_w0x0f == gwerthernal_style_u_w0x0f ? gwerthernal_style_u_dout & g_style_klim_dout : g_dout_w0x0f == g_style_main_reset_hold_w0x0f ? g_style_main_reset_hold_dout & g_style_klim_dout : g_dout_w0x0f == gwerthernal_style_l_w0x0f ? gwerthernal_style_l_dout & g_style_klim_dout : 32'b 00000000000000000000000000000000;
  assign g_dout = g_rdb == 1'b 0 ? g_dout_i : {32{1'b1}};
  // this  can be used to use zzz1
  always @(posedge sysclk) begin
    if((scanb == 1'b 1)) begin
      if((reset == 1'b 1)) begin
        g_style_main_reset_hold_dout <= g_zaq_in;
      end
      //vnavigatoroff
    end
    else begin
      g_style_main_reset_hold_dout <= q2_g_zaq_in;
    end
    //vnavigatoron
  end

  // qaz
  assign g_zaq_in_rst_hold = g_style_main_reset_hold_dout;
  // Din 
  always @(posedge reset or posedge sysclk) begin : P2
    reg [4:0] g_dout_w0x0f_v;

    if((reset != 1'b 0)) begin
      g_t_klim_dout <= {32{1'b0}};
      g_t_u_dout <= {32{1'b0}};
      g_t_l_dout <= {32{1'b0}};
      g_t_hhh_l_dout <= {32{1'b0}};
      g_t_jkl_sink_l_dout <= {32{1'b0}};
      g_secondary_t_l_dout <= {32{1'b0}};
      g_style_c_l_dout <= {4{1'b0}};
      g_e_z_dout <= {32{1'b0}};
      g_n_both_qbars_l_dout <= {32{1'b0}};
      g_style_klim_dout <= {32{1'b0}};
      g_style_t_y_dout <= {32{1'b0}};
      g_n_l_dout <= {32{1'b0}};
      g_e_n_r_dout <= {32{1'b0}};
      g_n_r_bne_dout <= 1'b 0;
      g_n_div_rebeq_dout <= {32{1'b1}};
      g_alu_l_dout <= {32{1'b0}};
      g_t_qaz_mult_low_dout <= {32{1'b1}};
      // NOTE Low
      g_t_qaz_mult_high_dout <= {32{1'b0}};
      gwerthernal_style_u_dout <= {32{1'b0}};
      gwerthernal_style_l_dout <= {32{1'b0}};
    end else begin
      // clear
      g_n_div_rebeq_dout <= g_n_div_rebeq_dout &  ~g_noop_clr;
      if((g_wrb == 1'b 0)) begin
        // because we now...
        for (i=0; i <= 1; i = i + 1) begin
          if((i == 0)) begin
            g_dout_w0x0f_v = g_dout_w0x0f;
          end
          else if((i == 1)) begin
            if((n9_bit_write == 1'b 1)) begin
              // set
              g_dout_w0x0f_v = {g_dout_w0x0f[4:1],1'b 1};
            end
            else begin
              disable;  //VHD2VL: add block name here
            end
            //vnavigatoroff
          end
          else begin
            // not possible but added for code coverage's sake
          end
          //vnavigatoron
          case(g_dout_w0x0f_v)
          g_t_klim_w0x0f : begin
            g_t_klim_dout <= din[i * 32 + 31:i * 32];
          end
          g_t_u_w0x0f : begin
            // output klim
            for (j=0; j <= 31; j = j + 1) begin
              if(((g_t_klim_dout[j] == 1'b 0 && n9_bit_write == 1'b 0) || (din[j] == 1'b 0 && n9_bit_write == 1'b 1))) begin
                g_t_u_dout[j] <= din[32 * i + j];
              end
            end
          end
          g_t_l_w0x0f : begin
            g_t_l_dout <= din[i * 32 + 31:i * 32];
          end
          g_t_hhh_l_w0x0f : begin
            g_t_hhh_l_dout <= din[i * 32 + 31:i * 32];
          end
          g_t_jkl_sink_l_w0x0f : begin
            g_t_jkl_sink_l_dout <= din[i * 32 + 31:i * 32];
          end
          g_secondary_t_l_w0x0f : begin
            g_secondary_t_l_dout <= din[i * 32 + 31:i * 32];
          end
          g_style_c_l_w0x0f : begin
            g_style_c_l_dout[3:0] <= din[3 + i * 32:i * 32];
          end
          g_e_z_w0x0f : begin
            g_e_z_dout <= din[i * 32 + 31:i * 32];
          end
          g_n_both_qbars_l_w0x0f : begin
            g_n_both_qbars_l_dout <= din[i * 32 + 31:i * 32];
          end
          g_style_vfr_w0x0f : begin
            // read-only register
          end
          g_style_klim_w0x0f : begin
            g_style_klim_dout <= din[i * 32 + 31:i * 32];
          end
          g_unklimed_style_vfr_w0x0f : begin
            // read-only register
          end
          g_style_t_y_w0x0f : begin
            g_style_t_y_dout <= din[i * 32 + 31:i * 32];
          end
          g_n_l_w0x0f : begin
            g_n_l_dout <= din[i * 32 + 31:i * 32];
          end
          g_n_vfr_w0x0f : begin
            // writes
          end
          g_e_n_r_w0x0f : begin
            g_e_n_r_dout <= din[i * 32 + 31:i * 32];
          end
          g_n_r_bne_w0x0f : begin
            g_n_r_bne_dout <= din[i * 32];
          end
          g_n_div_rebeq_w0x0f : begin
            g_n_div_rebeq_dout <= din[i * 32 + 31:i * 32] | g_n_div_rebeq_dout;
            // a '1' writes
          end
          g_alu_l_w0x0f : begin
            g_alu_l_dout <= din[i * 32 + 31:i * 32];
          end
          g_t_qaz_mult_low_w0x0f : begin
            g_t_qaz_mult_low_dout <= din[i * 32 + 31:i * 32];
          end
          g_t_qaz_mult_high_w0x0f : begin
            g_t_qaz_mult_high_dout <= din[i * 32 + 31:i * 32];
          end
          gwerthernal_style_u_w0x0f : begin
            gwerthernal_style_u_dout <= din[i * 32 + 31:i * 32];
          end
          gwerthernal_style_l_w0x0f : begin
            gwerthernal_style_l_dout <= din[i * 32 + 31:i * 32];
            //vnavigatoroff                                                          
          end
          default : begin
            //vnavigatoron                                                        
          end
          endcase
        end
      end
    end
  end

  // sample
  always @(posedge reset or posedge sysclk) begin
    if((reset != 1'b 0)) begin
      q_g_zaq_in <= {32{1'b0}};
      q2_g_zaq_in <= {32{1'b0}};
      q3_g_zaq_in <= {32{1'b0}};
    end else begin
      q_g_zaq_in <= g_zaq_in;
      q2_g_zaq_in <= q_g_zaq_in;
      q3_g_zaq_in <= g_zaq_in_y;
    end
  end

  //  vfr register
  assign g_unklimed_style_vfr_dout = q2_g_zaq_in;
  // switch
  assign g_zaq_in_y = g_style_t_y_dout ^ q2_g_zaq_in;
  // qaz
  assign g_style_vfr_dout = {g_zaq_in_y[31:4],(((g_style_c_l_dout[3:0] & q_g_zaq_in_cd)) | (( ~g_style_c_l_dout[3:0] & g_zaq_in_y[3:0])))};
  // in scan mode
  assign g_zaq_in_y_no_dout = scanb == 1'b 1 ? (g_style_t_y_dout ^ g_zaq_in) : g_style_t_y_dout;
  //vnavigatoron
  assign g_sys_in_i = ({g_zaq_in_y_no_dout[31:4],(((g_style_c_l_dout[3:0] & q_g_zaq_in_cd)) | (( ~g_style_c_l_dout[3:0] & g_zaq_in_y_no_dout[3:0])))});
  assign g_sys_in_ii = ((g_sys_in_i &  ~gwerthernal_style_l_dout)) | ((gwerthernal_style_u_dout & gwerthernal_style_l_dout));
  assign g_sys_in = g_sys_in_ii;
  always @(posedge reset or posedge sysclk) begin
    if((reset != 1'b 0)) begin
      q_g_zaq_in_cd <= {4{1'b0}};
      q_g_unzq <= {4{1'b1}};
    end else begin
      //  sample
      if((debct_ping == 1'b 1)) begin
        //  taken
        for (i=0; i <= 3; i = i + 1) begin
          if((g_zaq_in_y[i] != q3_g_zaq_in[i])) begin
            q_g_unzq[i] <= 1'b 1;
          end
          else begin
            if((q_g_unzq[i] == 1'b 0)) begin
              q_g_zaq_in_cd[i] <= g_zaq_in_y[i];
            end
            else begin
              q_g_unzq[i] <= 1'b 0;
            end
          end
        end
      end
      else begin
        for (i=0; i <= 3; i = i + 1) begin
          if((g_zaq_in_y[i] != q3_g_zaq_in[i])) begin
            q_g_unzq[i] <= 1'b 1;
          end
        end
      end
    end
  end

  // generate lqqs 
  always @(posedge reset or posedge sysclk) begin
    if((reset != 1'b 0)) begin
      q_g_style_vfr_dout <= {32{1'b0}};
    end else begin
      if((scanb == 1'b 1)) begin
        q_g_style_vfr_dout <= g_style_vfr_dout;
        //vnavigatoroff
      end
      else begin
        // in scan 
        q_g_style_vfr_dout <= g_style_vfr_dout | ({g_zaq_out_i[31:17],1'b 0,g_zaq_out_i[15:1],1'b 0}) | g_zaq_ctl_i | g_sys_in_ii;
      end
      //vnavigatoron
    end
  end

  // generate
  assign g_n_active = (((((q_g_style_vfr_dout &  ~g_style_vfr_dout)) | (( ~q_g_style_vfr_dout & g_style_vfr_dout & g_n_both_qbars_l_dout))))) & g_n_l_dout;
  // check for lqq active and set lqq vfr register
  // also clear
  always @(posedge reset or posedge sysclk) begin
    if((reset != 1'b 0)) begin
      g_n_vfr_dout <= {32{1'b0}};
      gwerth <= {32{1'b0}};
    end else begin
      for (i=0; i <= 31; i = i + 1) begin
        //  lqq
        //  vfr  matches
        if((g_n_active[i] == 1'b 1)) begin
          gwerth[i] <= 1'b 1;
          if((g_e_z_dout[i] == 1'b 1)) begin
            //  lqq          
            g_n_vfr_dout[i] <= 1'b 1;
          end
          else begin
            g_n_vfr_dout[i] <= q_g_style_vfr_dout[i];
          end
        end
        else begin
          //  clear
          if((g_e_z_dout[i] == 1'b 0)) begin
            g_n_vfr_dout[i] <= q_g_style_vfr_dout[i];
            // default always assign
            // in both
            if((g_n_both_qbars_l_dout[i] == 1'b 1 || g_style_vfr_dout[i] == 1'b 1)) begin
              gwerth[i] <= 1'b 0;
            end
          end
          else begin
            // write
            if((g_wrb == 1'b 0 && g_dout_w0x0f == g_n_vfr_w0x0f && din[i] == 1'b 1)) begin
              gwerth[i] <= 1'b 0;
              g_n_vfr_dout[i] <= 1'b 0;
            end
          end
        end
      end
    end
  end

  //--
  // Create the Lqq
  always @(g_n_r_bne_dout or g_e_n_r_dout) begin : P1
    reg [31:0] imod8, idiv8;

    for (i=0; i <= 31; i = i + 1) begin
      imod8 = i % 8;
      idiv8 = i / 8;
      if((g_n_r_bne_dout == 1'b 0)) begin
        // non-unique
        g_vector[8 * i + 7:8 * i] <= g_e_n_r_dout[8 * idiv8 + 7:8 * idiv8];
      end
      else begin
        // unique
        if((imod8 == 0)) begin
          g_vector[8 * i + 7:8 * i] <= g_e_n_r_dout[8 * idiv8 + 7:8 * idiv8];
        end
        else begin
          g_vector[8 * i + 7:8 * i] <= (((g_e_n_r_dout[8 * idiv8 + 7:8 * idiv8])) + ((imod8)));
        end
      end
    end
  end

  //--
  // Qaz
  assign g_noop = g_n_div_rebeq_dout;
  always @(swe_ed or swe_lv or g_e_z_dout) begin
    for (i=0; i <= 31; i = i + 1) begin
      if((g_e_z_dout[i] == 1'b 1)) begin
        swe_qaz1[i] <= swe_ed;
      end
      else begin
        swe_qaz1[i] <= swe_lv;
      end
    end
  end


endmodule
