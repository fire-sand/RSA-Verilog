`default_nettype none
module mon_prod (
  clk,
  start,
  A,
  B,
  M,
  len_bits,
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
  parameter countWidth = 4;


  input clk;
  input start;
  input [bitLen-1:0] A;
  input [bitLen-1:0] B;
  input [bitLen-1:0] M;

  output stop;
  output reg [bitLen-1:0] P;
  initial P[bitLen-1:0] = {bitLen{1'b0}};

  wire [p-1:0] B_cat;
  assign B_cat = {p{1'b0}};
  wire [p-1:0] a0;
  wire [p-1:0] m0;
  wire [p-1:0] mu;

  reg [bitLen-1:0] A_reg;
  reg [bitLen-1:0] B_reg;
  reg [bitLen-1:0] M_reg;
  reg state;
  initial B_reg = {bitLen{1'b1}};
  initial state = IDLE;

  reg [p-1:0] bt;
  reg [p-1:0] p0;
  reg [p-1:0] q0;
  reg [p-1:0] qt;
  reg [countWidth-1:0] count;
  initial count = len_bits;



  assign a0 = A[p-1:0];
  assign m0 = M[p-1:0];
  assign mu = (m0 == 2'd3) ? 2'd1 :
              (m0 == 2'd1) ? 2'd3 :
              2'd0;

  assign stop = !(| count); // stop = 1 if all bits of B are 0
  always @(posedge clk) begin

    case (state)
      IDLE: begin
        if (start) begin
          A_reg <= A;
          B_reg <= B;
          M_reg <= M;
          state <= CALC;
          count <= 3'd5;
        end
      end

      CALC: begin
        $display("--Calc--");
        bt = B_reg[1:0];
        $display("bt: %d", bt);
        B_reg = {B_cat, B_reg[bitLen-1:p]};
        p0 = P[p-1:0];
        $display("p0: %d", p0);
        qt = (mu * (a0 * bt + p0));
        $display("qt: %d", qt);
        P = (A * bt + P + qt * M) >> p; // TODO convert to shift add multiplier
        $display("P: %d", P);
        count = count - 1;
        $display("count: %d", count);
        if (stop) begin
          state <= IDLE;
        end
      end
    endcase
  end
endmodule //
