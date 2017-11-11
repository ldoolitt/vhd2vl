// Project: VHDL to Verilog RTL translation 
// Revision: 1.0 
// Date of last Revision: February 27 2001 
// Designer: Vincenzo Liguori 
// vhd2vl test file
// This VHDL file exercises vhd2vl
// no timescale needed

module test(
input wire clk,
input wire rstn,
input wire en,
input wire start_dec,
input wire [2:0] addr,
input wire [25:0] din,
input wire we,
input wire [7:0] pixel_in,
input wire pix_req,
input wire config1,
input wire bip,
input wire [7:0] a,
input wire [7:0] b,
input wire [7:0] c,
input wire [7:0] load,
input wire [6:0] pack,
input wire [2:0] base,
input wire [21:0] qtd,
output wire [23:0] dout,
output reg [7:0] pixel_out,
output wire pixel_valid,
output reg [9:0] code,
output wire [9:0] code1,
output wire [23:0] complex,
output wire eno
);

// Inputs
// Outputs



// Components declarations are ignored by vhd2vl
// but they are still parsed
parameter [1:0]
  red = 0,
  green = 1,
  blue = 2,
  yellow = 3;

reg [1:0] status;
parameter PARAM1 = 8'b01101101;
parameter PARAM2 = 8'b11001101;
parameter PARAM3 = 8'b00010111;
wire [7:0] param;
reg selection;
reg start; wire enf;  // Start and enable signals
wire [13:0] memdin;
wire [5:0] memaddr;
wire [13:0] memdout;
reg [1:0] colour;

  assign param = config1 == 1'b1 ? PARAM1 : status == green ? PARAM2 : PARAM3;
  // Synchronously process
  always @(posedge clk) begin
    pixel_out <= pixel_in ^ 8'b11001100;
  end

  // Synchronous process
  always @(posedge clk) begin
    case(status)
    red : begin
      colour <= 2'b00;
    end
    green : begin
      colour <= 2'b01;
    end
    blue : begin
      colour <= 2'b10;
    end
    default : begin
      colour <= 2'b11;
    end
    endcase
  end

  // Synchronous process with asynch reset
  always @(posedge clk, posedge rstn) begin
    if(rstn == 1'b0) begin
      status <= red;
    end else begin
      case(status)
      red : begin
        if(pix_req == 1'b1) begin
          status <= green;
        end
      end
      green : begin
        if(a[3] == 1'b1) begin
          start <= start_dec;
          status <= blue;
        end
        else if(({b[5],a[3:2]}) == 3'b001) begin
          status <= yellow;
        end
      end
      blue : begin
        status <= yellow;
      end
      default : begin
        start <= 1'b0;
        status <= red;
      end
      endcase
    end
  end

  // Example of with statement
  always @(*) begin
    case(memaddr[2:0])
      3'b000,3'b110 : code[9:2] <= {3'b110,pack[6:2]};
      3'b101 : code[9:2] <= 8'b11100010;
      3'b010 : code[9:2] <= {8{1'b1}};
      3'b011 : code[9:2] <= {8{1'b0}};
      default : code[9:2] <= (((a)) + ((b)));
    endcase
  end

  assign code1[1:0] = a[6:5] ^ ({a[4],b[6]});
  // Asynch process
  always @(we, addr, config1, bip) begin
    if(we == 1'b1) begin
      if(addr[2:0] == 3'b100) begin
        selection <= 1'b1;
      end
      else if(({b,a}) == {a,b} && bip == 1'b0) begin
        selection <= config1;
      end
      else begin
        selection <= 1'b1;
      end
    end
    else begin
      selection <= 1'b0;
    end
  end

  // Components instantiation
  dsp dsp_inst(
      // Inputs
    .clk(clk),
    .rstn(rstn),
    .en(en),
    .start(start),
    .param(param),
    .addr(addr),
    .din(din[23:0]),
    .we(we),
    .memdin(memdin),
    // Outputs
    .dout(dout),
    .memaddr(memaddr),
    .memdout(memdout));

  mem dsp_mem(
      // Inputs
    .clk(clk),
    .rstn(rstn),
    .en(en),
    .cs(selection),
    .addr(memaddr),
    .din(memdout),
    // Outputs
    .dout(memdin));

  assign complex = {enf,((3'b110 * ((load)))),qtd[3:0],base,5'b11001};
  assign enf = c < 7'b1000111 ? 1'b1 : 1'b0;
  assign eno = enf;

endmodule
