// CONNECTIVITY DEFINITION
// no timescale needed

module bigfile(
input wire sysclk,
input wire [31:0] g_zaq_in,
input wire [31:0] g_aux,
input wire scanb,
input wire g_wrb,
input wire g_rdb,
input wire [31:0] g_noop_clr,
input wire swe_ed,
input wire swe_lv,
input wire [63:0] din,
input wire [4:0] g_dout_w0x0f,
input wire n9_bit_write,
input wire reset,
input wire [31:0] alu_u,
input wire debct_ping,
output wire [31:0] g_sys_in,
output wire [31:0] g_zaq_in_rst_hold,
output wire [31:0] g_zaq_hhh_enb,
output wire [31:0] g_zaq_out,
output wire [31:0] g_dout,
output wire [31:0] g_zaq_ctl,
output wire [31:0] g_zaq_qaz_hb,
output wire [31:0] g_zaq_qaz_lb,
output reg [31:0] gwerth,
output wire [31:0] g_noop,
output reg [8 * 32 - 1:0] g_vector,
output reg [31:0] swe_qaz1
);

// from external pins
// from reset_gen block



// IMPLEMENTATION
// constants 
parameter g_t_klim_w0x0f = 5'b00000;
parameter g_t_u_w0x0f = 5'b00001;
parameter g_t_l_w0x0f = 5'b00010;
parameter g_t_hhh_l_w0x0f = 5'b00011;
parameter g_t_jkl_sink_l_w0x0f = 5'b00100;
parameter g_secondary_t_l_w0x0f = 5'b00101;
parameter g_style_c_l_w0x0f = 5'b00110;
parameter g_e_z_w0x0f = 5'b00111;
parameter g_n_both_qbars_l_w0x0f = 5'b01000;
parameter g_style_vfr_w0x0f = 5'b01001;
parameter g_style_klim_w0x0f = 5'b01010;
parameter g_unklimed_style_vfr_w0x0f = 5'b01011;
parameter g_style_t_y_w0x0f = 5'b01100;
parameter g_n_l_w0x0f = 5'b01101;
parameter g_n_vfr_w0x0f = 5'b01110;
parameter g_e_n_r_w0x0f = 5'b01111;
parameter g_n_r_bne_w0x0f = 5'b10000;
parameter g_n_div_rebeq_w0x0f = 5'b10001;
parameter g_alu_l_w0x0f = 5'b10010;
parameter g_t_qaz_mult_low_w0x0f = 5'b10011;
parameter g_t_qaz_mult_high_w0x0f = 5'b10100;
parameter gwerthernal_style_u_w0x0f = 5'b10101;
parameter gwerthernal_style_l_w0x0f = 5'b10110;
parameter g_style_main_reset_hold_w0x0f = 5'b10111;  // comment
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
  assign g_zaq_ctl = scanb == 1'b1 ? g_zaq_ctl_i : 32'b00000000000000000000000000000000;
  //vnavigatoron
  assign g_zaq_hhh_enb =  ~((g_t_hhh_l_dout));
  assign g_zaq_qaz_hb = g_t_qaz_mult_high_dout;
  assign g_zaq_qaz_lb = g_t_qaz_mult_low_dout;
  // Dout
  assign g_dout_i = g_dout_w0x0f == g_t_klim_w0x0f ? g_t_klim_dout & g_style_klim_dout : g_dout_w0x0f == g_t_u_w0x0f ? g_t_u_dout & g_style_klim_dout : g_dout_w0x0f == g_t_l_w0x0f ? g_t_l_dout & g_style_klim_dout : g_dout_w0x0f == g_t_hhh_l_w0x0f ? g_t_hhh_l_dout & g_style_klim_dout : g_dout_w0x0f == g_t_jkl_sink_l_w0x0f ? g_t_jkl_sink_l_dout & g_style_klim_dout : g_dout_w0x0f == g_secondary_t_l_w0x0f ? g_secondary_t_l_dout & g_style_klim_dout : g_dout_w0x0f == g_style_c_l_w0x0f ? ({28'b0000000000000000000000000000,g_style_c_l_dout}) & g_style_klim_dout : g_dout_w0x0f == g_e_z_w0x0f ? g_e_z_dout : g_dout_w0x0f == g_n_both_qbars_l_w0x0f ? g_n_both_qbars_l_dout : g_dout_w0x0f == g_style_vfr_w0x0f ? g_style_vfr_dout & g_style_klim_dout : g_dout_w0x0f == g_style_klim_w0x0f ? g_style_klim_dout : g_dout_w0x0f == g_unklimed_style_vfr_w0x0f ? g_unklimed_style_vfr_dout : g_dout_w0x0f == g_style_t_y_w0x0f ? g_style_t_y_dout & g_style_klim_dout : g_dout_w0x0f == g_n_l_w0x0f ? g_n_l_dout : g_dout_w0x0f == g_n_vfr_w0x0f ? g_n_vfr_dout : g_dout_w0x0f == g_e_n_r_w0x0f ? g_e_n_r_dout : g_dout_w0x0f == g_n_r_bne_w0x0f ? {31'b0000000000000000000000000000000,g_n_r_bne_dout} : g_dout_w0x0f == g_n_div_rebeq_w0x0f ? g_n_div_rebeq_dout : g_dout_w0x0f == g_alu_l_w0x0f ? g_alu_l_dout & g_style_klim_dout : g_dout_w0x0f == g_t_qaz_mult_low_w0x0f ? g_t_qaz_mult_low_dout & g_style_klim_dout : g_dout_w0x0f == g_t_qaz_mult_high_w0x0f ? g_t_qaz_mult_high_dout & g_style_klim_dout : g_dout_w0x0f == gwerthernal_style_u_w0x0f ? gwerthernal_style_u_dout & g_style_klim_dout : g_dout_w0x0f == g_style_main_reset_hold_w0x0f ? g_style_main_reset_hold_dout & g_style_klim_dout : g_dout_w0x0f == gwerthernal_style_l_w0x0f ? gwerthernal_style_l_dout & g_style_klim_dout : 32'b00000000000000000000000000000000;
  assign g_dout = g_rdb == 1'b0 ? g_dout_i : {32{1'b1}};
  // this  can be used to use zzz1
  always @(posedge sysclk) begin
    if((scanb == 1'b1)) begin
      if((reset == 1'b1)) begin
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
  always @(posedge reset, posedge sysclk) begin : P2
    reg [4:0] g_dout_w0x0f_v;

    if((reset != 1'b0)) begin
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
      g_n_r_bne_dout <= 1'b0;
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
      if((g_wrb == 1'b0)) begin
        // because we now...
        for (i=0; i <= 1; i = i + 1) begin
          if((i == 0)) begin
            g_dout_w0x0f_v = g_dout_w0x0f;
          end
          else if((i == 1)) begin
            if((n9_bit_write == 1'b1)) begin
              // set
              g_dout_w0x0f_v = {g_dout_w0x0f[4:1],1'b1};
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
              if(((g_t_klim_dout[j] == 1'b0 && n9_bit_write == 1'b0) || (din[j] == 1'b0 && n9_bit_write == 1'b1))) begin
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
  always @(posedge reset, posedge sysclk) begin
    if((reset != 1'b0)) begin
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
  assign g_zaq_in_y_no_dout = scanb == 1'b1 ? (g_style_t_y_dout ^ g_zaq_in) : g_style_t_y_dout;
  //vnavigatoron
  assign g_sys_in_i = ({g_zaq_in_y_no_dout[31:4],(((g_style_c_l_dout[3:0] & q_g_zaq_in_cd)) | (( ~g_style_c_l_dout[3:0] & g_zaq_in_y_no_dout[3:0])))});
  assign g_sys_in_ii = ((g_sys_in_i &  ~gwerthernal_style_l_dout)) | ((gwerthernal_style_u_dout & gwerthernal_style_l_dout));
  assign g_sys_in = g_sys_in_ii;
  always @(posedge reset, posedge sysclk) begin
    if((reset != 1'b0)) begin
      q_g_zaq_in_cd <= {4{1'b0}};
      q_g_unzq <= {4{1'b1}};
    end else begin
      //  sample
      if((debct_ping == 1'b1)) begin
        //  taken
        for (i=0; i <= 3; i = i + 1) begin
          if((g_zaq_in_y[i] != q3_g_zaq_in[i])) begin
            q_g_unzq[i] <= 1'b1;
          end
          else begin
            if((q_g_unzq[i] == 1'b0)) begin
              q_g_zaq_in_cd[i] <= g_zaq_in_y[i];
            end
            else begin
              q_g_unzq[i] <= 1'b0;
            end
          end
        end
      end
      else begin
        for (i=0; i <= 3; i = i + 1) begin
          if((g_zaq_in_y[i] != q3_g_zaq_in[i])) begin
            q_g_unzq[i] <= 1'b1;
          end
        end
      end
    end
  end

  // generate lqqs 
  always @(posedge reset, posedge sysclk) begin
    if((reset != 1'b0)) begin
      q_g_style_vfr_dout <= {32{1'b0}};
    end else begin
      if((scanb == 1'b1)) begin
        q_g_style_vfr_dout <= g_style_vfr_dout;
        //vnavigatoroff
      end
      else begin
        // in scan 
        q_g_style_vfr_dout <= g_style_vfr_dout | ({g_zaq_out_i[31:17],1'b0,g_zaq_out_i[15:1],1'b0}) | g_zaq_ctl_i | g_sys_in_ii;
      end
      //vnavigatoron
    end
  end

  // generate
  assign g_n_active = (((((q_g_style_vfr_dout &  ~g_style_vfr_dout)) | (( ~q_g_style_vfr_dout & g_style_vfr_dout & g_n_both_qbars_l_dout))))) & g_n_l_dout;
  // check for lqq active and set lqq vfr register
  // also clear
  always @(posedge reset, posedge sysclk) begin
    if((reset != 1'b0)) begin
      g_n_vfr_dout <= {32{1'b0}};
      gwerth <= {32{1'b0}};
    end else begin
      for (i=0; i <= 31; i = i + 1) begin
        //  lqq
        //  vfr  matches
        if((g_n_active[i] == 1'b1)) begin
          gwerth[i] <= 1'b1;
          if((g_e_z_dout[i] == 1'b1)) begin
            //  lqq          
            g_n_vfr_dout[i] <= 1'b1;
          end
          else begin
            g_n_vfr_dout[i] <= q_g_style_vfr_dout[i];
          end
        end
        else begin
          //  clear
          if((g_e_z_dout[i] == 1'b0)) begin
            g_n_vfr_dout[i] <= q_g_style_vfr_dout[i];
            // default always assign
            // in both
            if((g_n_both_qbars_l_dout[i] == 1'b1 || g_style_vfr_dout[i] == 1'b1)) begin
              gwerth[i] <= 1'b0;
            end
          end
          else begin
            // write
            if((g_wrb == 1'b0 && g_dout_w0x0f == g_n_vfr_w0x0f && din[i] == 1'b1)) begin
              gwerth[i] <= 1'b0;
              g_n_vfr_dout[i] <= 1'b0;
            end
          end
        end
      end
    end
  end

  //--
  // Create the Lqq
  always @(g_n_r_bne_dout, g_e_n_r_dout) begin : P1
    reg [31:0] imod8, idiv8;

    for (i=0; i <= 31; i = i + 1) begin
      imod8 = i % 8;
      idiv8 = i / 8;
      if((g_n_r_bne_dout == 1'b0)) begin
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
  always @(swe_ed, swe_lv, g_e_z_dout) begin
    for (i=0; i <= 31; i = i + 1) begin
      if((g_e_z_dout[i] == 1'b1)) begin
        swe_qaz1[i] <= swe_ed;
      end
      else begin
        swe_qaz1[i] <= swe_lv;
      end
    end
  end


endmodule
