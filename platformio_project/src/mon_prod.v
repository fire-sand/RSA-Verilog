`default_nettype none
module mon_pro (
  clk,
  start,
  A,
  B,
  M,
  stop,
  P,
  );
  // B = 2 ^ p
  localparam  Beta = 4;
  localparam  p = 2;
  localparam  IDLE = 1'b0;
  localparam  CALC = 1'b1;
  // width of the numbers being multiplied
  parameter bitLen = 64; //
  // n = ciel(bitLen / p)
  parameter n = 48;
  parameter bits_n = 6;


  input clk;
  input start;
  input [bitLen-1:0] A;
  input [bitLen-1:0] B;
  input [bitLen-1:0] M;

  output stop;
  output reg [bitLen-1:0] P;

  wire [p-1:0] B_cat;
  assign B_cat = {p{1'b0}};
  wire [p-1:0] a0;
  wire [p-1:0] m0;

  reg [bitLen-1:0] A_reg;
  reg [bitLen-1:0] B_reg;
  reg [bitLen-1:0] M_reg;
  reg state;

  wire [p-1:0] bt;
  wire [p-1:0] p0;
  wire [p-1:0] q0;


  wire [p-1:0] a0 ;
  assign a0 = A[p-1:0];
  wire [p-1:0] m0;
  assign m0 = M[p-1:0];



  assign stop = !(&B_reg); // stop = 1 if all bits of B are 0


  always @(posedge clk) begin
    case (state)
      IDLE: begin
        if (start) begin
          A_reg <= A;
          M_reg <= M;
          state <= CALC;
        end
      end

      CALC: begin
        bt <= B_reg[1:0];
        B_reg <= {B_cat, B_reg[bitLen-p-1:0]};
        p0 <= P[p-1:0]

        // TODO qt and P from python code

      end
    endcase
  end
endmodule //
