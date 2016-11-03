`default_nettype none

`define BITLEN 1024
`define BETA 4
`define BETALEN 2

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
  localparam  p = 2;
  localparam  IDLE = 2'b0;
  localparam  CALC = 2'b1;
  localparam  CALC2 = 2'd2;
  // width of the numbers being multiplied
  // parameter countWidth = 5;


  input clk;
  input start;
  input [`BITLEN-1:0] A;
  input [`BITLEN-1:0] B;
  input [`BITLEN-1:0] M;
  input [`BITLEN >> 2:0] num_words;

  output stop;
  output reg [`BITLEN-1:0] P;
  initial P[`BITLEN-1:0] = {`BITLEN{1'b0}};

  wire [`BETALEN-1:0] B_cat;
  assign B_cat = {`BETALEN{1'b0}};
  wire [`BETALEN-1:0] a0;
  wire [`BETALEN-1:0] m0;
  wire [`BETALEN-1:0] mu;

  reg [`BITLEN-1:0] B_reg;
  reg [1:0]state;
  initial B_reg = {`BITLEN{1'b1}};
  initial state = IDLE;

  reg [`BETALEN-1:0] bt;
  reg [`BETALEN-1:0] p0;
  reg [`BETALEN-1:0] q0;
  reg [`BETALEN-1:0] qt;
  reg [`BETALEN-1:0] qt_i;
  reg [`BITLEN >> 2:0] count;

  assign a0 = A[`BETALEN-1:0];
  assign m0 = M[`BETALEN-1:0];
  assign mu = (m0 == 2'd3) ? 2'd1 :
              (m0 == 2'd1) ? 2'd3 :
              2'd0;

  assign stop = !(| count); // stop = 1 if all bits of B are 0

  wire [`BITLEN+`BETALEN-1:0] A_bt;
  shift_add_mult2 sam1 (
      .A(A),
      .B(bt),
      .P(A_bt)
      );

  wire [`BITLEN+`BETALEN-1:0] M_qt;
  shift_add_mult2 sam2 (
      .A(M),
      .B(qt),
      .P(M_qt)
      );

  always @(posedge clk) begin

    case (state)
      IDLE: begin
        if (start) begin
          B_reg <= B;
          state <= CALC;
          count <= 8; // should be `BITLEN if power of 2, otherwise next highest power of 2
        end
      end

      CALC: begin
        $display("--Calc--");
        bt = B_reg[`BETALEN-1:0];
        $display("bt: %d", bt);
        B_reg = {B_cat, B_reg[`BITLEN-1:`BETALEN]};
        p0 = P[`BETALEN-1:0];
        $display("p0: %d", p0);
        qt = (mu * (a0 * bt + p0)); // only 2 bit multiplicaiton
        $display("qt: %d", qt);
        state <= CALC2;
      end

      CALC2: begin
        $display("--Calc2--");
        $display("A_bt: %d", A_bt);
        $display("M_qt: %d", M_qt);
        P = (A_bt + M_qt + {`BETALEN'd0, P}) >> `BETALEN; // TODO need to split up over multiple clocks
        $display("P: %d", P);
        count = count >> 1;
        $display("count: %d", count);
        if (stop) begin
          P = (P < M) ? P : P - M;
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

  input [`BITLEN-1:0] A;
  input [`BETALEN-1:0] B;

  output [`BITLEN+`BETALEN-1:0] P;

  wire [`BITLEN-1:0] a_s0;
  wire [`BITLEN:0] a_s1;

  assign a_s0 = A & {`BITLEN{B[0]}};
  assign a_s1 = (A & {`BITLEN{B[1]}}) << 1;

  // assign a_s0 = B[0] ? A : {`BITLEN{1'b0}};
  // assign a_s1 = B[1] ? (A << 1) :  {`BITLEN+1{1'b0}};

  assign P = a_s0 + a_s1;
endmodule
