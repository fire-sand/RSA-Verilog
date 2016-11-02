`default_nettype none
module mon_prod (
  clk,
  start,
  A,
  B,
  M,
  num_words,
  stop,
  P,
  );
  // B = 2 ^ p
  localparam  Beta = 4;
  localparam  p = 2;
  localparam  IDLE = 2'b0;
  localparam  CALC = 2'b1;
  localparam  CALC2 = 2'd2;
  // width of the numbers being multiplied
  parameter bitLen = 1024; //
  parameter countWidth = 4;


  input clk;
  input start;
  input [bitLen-1:0] A;
  input [bitLen-1:0] B;
  input [bitLen-1:0] M;
  input [countWidth-1:0] num_words;

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
  reg [1:0]state;
  initial B_reg = {bitLen{1'b1}};
  initial state = IDLE;

  reg [p-1:0] bt;
  reg [p-1:0] p0;
  reg [p-1:0] q0;
  reg [p-1:0] qt;
  reg [p-1:0] qt_i;
  reg [countWidth-1:0] count;

  assign a0 = A[p-1:0];
  assign m0 = M[p-1:0];
  assign mu = (m0 == 2'd3) ? 2'd1 :
              (m0 == 2'd1) ? 2'd3 :
              2'd0;

  assign stop = !(| count); // stop = 1 if all bits of B are 0

  wire [bitLen+p-2:0] A_bt;
  shift_add_mult2 #(.bitLen(bitLen))
    sam1 (
      .A(A),
      .B(bt),
      .P(A_bt)
      );

  wire [bitLen+p-2:0] M_qt;
  shift_add_mult2 #(.bitLen(bitLen))
    sam2 (
      .A(M),
      .B(qt),
      .P(M_qt)
      );

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
        qt = (mu * (a0 * bt + p0)); // only 2 bit multiplicaiton
        $display("qt: %d", qt);
        state <= CALC2;
      end

      CALC2: begin
        $display("--Calc2--");
        $display("A_bt: %d", A_bt);
        $display("M_qt: %d", M_qt);
        P = (A_bt + P + M_qt) >> p; // TODO need to split up over multiple clocks
        $display("P: %d", P);
        count = count - 1;
        $display("count: %d", count);
        if (stop) begin
          state <= IDLE;
        end else begin
          state <= CALC;
        end
      end
    endcase
  end
endmodule

module shift_add_mult2(
  A,
  B,
  P,
  );
  localparam  Beta = 4;
  localparam  p = 2;
  parameter bitLen = 64;

  input [bitLen-1:0] A;
  input [p-1:0] B;

  output [bitLen+p-2:0] P;

  wire [bitLen+p-3:0] a_s0;
  wire [bitLen+p-2:0] a_s1;

  assign a_s0 = B[0] ? A : {bitLen{1'b0}};
  assign a_s1 = B[1] ? (A << 1) :  {bitLen+p-1{1'b0}};

  assign P = a_s0 + a_s1;
endmodule
