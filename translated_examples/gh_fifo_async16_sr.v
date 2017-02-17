//-------------------------------------------------------------------
//	Filename:	gh_fifo_async16_sr.vhd
//
//			
//	Description:
//		an Asynchronous FIFO 
//              
//	Copyright (c) 2006 by George Huber 
//		an OpenCores.org Project
//		free to use, but see documentation for conditions 								 
//
//	Revision	History:
//	Revision	Date      	Author   	Comment
//	--------	----------	---------	-----------
//	1.0     	12/17/06  	h lefevre	Initial revision
//	
//------------------------------------------------------
// no timescale needed

module gh_fifo_async16_sr(
input wire clk_WR,
input wire clk_RD,
input wire rst,
input wire srst,
input wire WR,
input wire RD,
input wire [data_width - 1:0] D,
output wire [data_width - 1:0] Q,
output wire empty,
output wire full
);

parameter [31:0] data_width=8;
// size of data bus
// write clock
// read clock
// resets counters
// resets counters (sync with clk_WR)
// write control 
// read control




wire [data_width - 1:0] ram_mem[15:0];
wire iempty;
wire ifull;
wire add_WR_CE;
reg [4:0] add_WR;  // 4 bits are used to address MEM
reg [4:0] add_WR_GC;  // 5 bits are used to compare
wire [4:0] n_add_WR;  //   for empty, full flags
reg [4:0] add_WR_RS;  // synced to read clk
wire add_RD_CE;
reg [4:0] add_RD;
reg [4:0] add_RD_GC;
reg [4:0] add_RD_GCwc;
wire [4:0] n_add_RD;
reg [4:0] add_RD_WS;  // synced to write clk
reg srst_w;
reg isrst_w;
reg srst_r;
reg isrst_r;

  //------------------------------------------
  //----- memory -----------------------------
  //------------------------------------------
  always @(posedge clk_WR) begin
    if(((WR == 1'b1) && (ifull == 1'b0))) begin
      //ram_mem(to_integer(unsigned(add_WR(3 downto 0)))) <= D;
    end
  end

  //Q <= ram_mem(to_integer(unsigned(add_RD(3 downto 0))));
  //---------------------------------------
  //--- Write address counter -------------
  //---------------------------------------
  assign add_WR_CE = (ifull == 1'b1) ? 1'b0 : (WR == 1'b0) ? 1'b0 : 1'b1;
  assign n_add_WR = (((add_WR)) + 4'h1);
  always @(posedge clk_WR or posedge rst) begin
    if((rst == 1'b1)) begin
      add_WR <= {5{1'b0}};
      add_RD_WS <= 5'b11000;
      add_WR_GC <= {5{1'b0}};
    end else begin
      add_RD_WS <= add_RD_GCwc;
      if((srst_w == 1'b1)) begin
        add_WR <= {5{1'b0}};
        add_WR_GC <= {5{1'b0}};
      end
      else if((add_WR_CE == 1'b1)) begin
        add_WR <= n_add_WR;
        add_WR_GC[0] <= n_add_WR[0] ^ n_add_WR[1];
        add_WR_GC[1] <= n_add_WR[1] ^ n_add_WR[2];
        add_WR_GC[2] <= n_add_WR[2] ^ n_add_WR[3];
        add_WR_GC[3] <= n_add_WR[3] ^ n_add_WR[4];
        add_WR_GC[4] <= n_add_WR[4];
      end
      else begin
        add_WR <= add_WR;
        add_WR_GC <= add_WR_GC;
      end
    end
  end

  assign full = ifull;
  assign ifull = (iempty == 1'b1) ? 1'b0 : (add_RD_WS != add_WR_GC) ? 1'b0 : 1'b1;
  //---------------------------------------
  //--- Read address counter --------------
  //---------------------------------------
  assign add_RD_CE = (iempty == 1'b1) ? 1'b0 : (RD == 1'b0) ? 1'b0 : 1'b1;
  assign n_add_RD = (((add_RD)) + 4'h1);
  always @(posedge clk_RD or posedge rst) begin
    if((rst == 1'b1)) begin
      add_RD <= {5{1'b0}};
      add_WR_RS <= {5{1'b0}};
      add_RD_GC <= {5{1'b0}};
      add_RD_GCwc <= 5'b11000;
    end else begin
      add_WR_RS <= add_WR_GC;
      if((srst_r == 1'b1)) begin
        add_RD <= {5{1'b0}};
        add_RD_GC <= {5{1'b0}};
        add_RD_GCwc <= 5'b11000;
      end
      else if((add_RD_CE == 1'b1)) begin
        add_RD <= n_add_RD;
        add_RD_GC[0] <= n_add_RD[0] ^ n_add_RD[1];
        add_RD_GC[1] <= n_add_RD[1] ^ n_add_RD[2];
        add_RD_GC[2] <= n_add_RD[2] ^ n_add_RD[3];
        add_RD_GC[3] <= n_add_RD[3] ^ n_add_RD[4];
        add_RD_GC[4] <= n_add_RD[4];
        add_RD_GCwc[0] <= n_add_RD[0] ^ n_add_RD[1];
        add_RD_GCwc[1] <= n_add_RD[1] ^ n_add_RD[2];
        add_RD_GCwc[2] <= n_add_RD[2] ^ n_add_RD[3];
        add_RD_GCwc[3] <= n_add_RD[3] ^ (( ~n_add_RD[4]));
        add_RD_GCwc[4] <= ( ~n_add_RD[4]);
      end
      else begin
        add_RD <= add_RD;
        add_RD_GC <= add_RD_GC;
        add_RD_GCwc <= add_RD_GCwc;
      end
    end
  end

  assign empty = iempty;
  assign iempty = (add_WR_RS == add_RD_GC) ? 1'b1 : 1'b0;
  //--------------------------------
  //-	sync rest stuff --------------
  //- srst is sync with clk_WR -----
  //- srst_r is sync with clk_RD ---
  //--------------------------------
  always @(posedge clk_WR or posedge rst) begin
    if((rst == 1'b1)) begin
      srst_w <= 1'b0;
      isrst_r <= 1'b0;
    end else begin
      isrst_r <= srst_r;
      if((srst == 1'b1)) begin
        srst_w <= 1'b1;
      end
      else if((isrst_r == 1'b1)) begin
        srst_w <= 1'b0;
      end
    end
  end

  always @(posedge clk_RD or posedge rst) begin
    if((rst == 1'b1)) begin
      srst_r <= 1'b0;
      isrst_w <= 1'b0;
    end else begin
      isrst_w <= srst_w;
      if((isrst_w == 1'b1)) begin
        srst_r <= 1'b1;
      end
      else begin
        srst_r <= 1'b0;
      end
    end
  end


endmodule
