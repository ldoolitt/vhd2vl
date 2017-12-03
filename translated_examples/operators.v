// no timescale needed

module operators(
input wire clk_i
);

parameter [1:0] g_and=2'b11 & 2'b10;
parameter [1:0] g_or=2'b11 | 2'b10;
parameter [1:0] g_nand= ~(2'b11 & 2'b10);
parameter [1:0] g_nor= ~(2'b11 | 2'b10);
parameter [1:0] g_xor=2'b11 ^ 2'b10;
parameter [1:0] g_xnor= ~(2'b11 ^ 2'b10);



parameter c_and = 2'b11 & 2'b10;
parameter c_or = 2'b11 | 2'b10;
parameter c_nand =  ~(2'b11 & 2'b10);
parameter c_nor =  ~(2'b11 | 2'b10);
parameter c_xor = 2'b11 ^ 2'b10;
parameter c_xnor =  ~(2'b11 ^ 2'b10);
wire [1:0] s_op1;
wire [1:0] s_op2;
reg [1:0] s_res;

  always @(posedge clk_i) begin : P1
    reg [1:0] v_op1;
    reg [1:0] v_op2;
    reg [1:0] v_res;

    if((s_op1 == 2'b11 && s_op2 == 2'b00) || (s_op1 == 2'b11 || s_op2 == 2'b00) || (!(s_op1 == 2'b11 && s_op2 == 2'b00)) || (!(s_op1 == 2'b11 || s_op2 == 2'b00))) begin
      s_res <= s_op1 & s_op2;
      s_res <= s_op1 | s_op2;
      v_res =  ~(v_op1 & v_op2);
      v_res =  ~(v_op1 | v_op2);
      s_res <= s_op1 ^ s_op2;
      v_res =  ~(v_op1 ^ v_op2);
    end
  end


endmodule
