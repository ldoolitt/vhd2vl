// no timescale needed

module forp(
input wire reset,
input wire sysclk
);




reg selection;
reg [6:0] egg_timer;

  always @(posedge reset or posedge sysclk) begin : P1
    reg [31:0] timer_var = 0;
    reg [31:0] a, i, j, k;
    reg [31:0] zz5;
    reg [511:0] zz;

    if(reset == 1'b1) begin
      selection <= 1'b1;
      timer_var = 2;
      egg_timer <= {7{1'b0}};
    end else begin
      //  pulse only lasts for once cycle
      selection <= 1'b0;
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
