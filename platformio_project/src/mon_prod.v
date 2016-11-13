`default_nettype none

`define BITLEN 1024
`define BETA 2
`define BETALEN 1

`define B_REGLEN 16

module mon_prod (
  clk,
  start,
  A,
  B,
  M,
  mp_count,
  stop,
  P,
  );
  // B = 2 ^ p
  localparam  p = 2;
  localparam  IDLE = 2'b0;
  localparam  CALC = 2'b1;
  localparam  CALC1 = 2'd2;
  localparam  CALC2 = 2'd3;
  // width of the numbers being multiplied
  // parameter countWidth = 5;


  input clk;
  input start;
  input [`BITLEN-1:0] A;
  input [`BITLEN-1:0] B;
  input [`BITLEN-1:0] M;
  input [9:0] mp_count;

  output stop;
  output reg [`BITLEN + `BETALEN - 1:0] P;
  initial P = 1025'b0;

  wire [`BETALEN-1:0] B_cat;
  assign B_cat = {`BETALEN{1'b0}};
  wire [`BETALEN-1:0] a0;
  // wire [`BETALEN-1:0] m0;
  wire [`BETALEN-1:0] mu;

  reg [`B_REGLEN-1:0] B_reg;
  reg [1:0]state;
  initial B_reg = {`B_REGLEN{1'b1}};
  initial state = IDLE;

  // reg [`BETALEN-1:0] bt;
  reg [`BETALEN-1:0] p0;
  // reg [`BETALEN-1:0] qt;
  reg [9:0] count;

  assign a0 = A[`BETALEN-1:0];
  // assign m0 = M[`BETALEN-1:0];
  // assign mu = (m0 == 2'd3) ? 2'd1 :
  //             (m0 == 2'd1) ? 2'd3 :
  //             2'd0;
  assign mu = M[`BETALEN-1:0];

  assign stop = !(| count); // stop = 1 if all bits of B are 0


  reg [`BITLEN-1:0] big_mult;
  initial big_mult = `BITLEN'b0;
  reg [`BETALEN-1:0] small_mult;
  initial small_mult = `BETALEN'b0;
  wire [`BITLEN+`BETALEN-1:0] mult_out;

  shift_add_mult2 sam1 (
      .A(big_mult),
      .B(small_mult),
      .P(mult_out)
      );

  always @(posedge clk) begin
    // $display("mon_prod start: %d", start);
    // $display("start: A: %0d, B: %0d, M: %0d", A, B, M);
    case (state)
      IDLE: begin
        if (start) begin
          //$display("IDLE> A: %0d, B: %0d, M: %0d", A, B, M);
          B_reg <= B;
          state <= CALC;
          P <= 1025'b0;
          count <= mp_count; // should be `BITLEN if power of 2, otherwise next highest power of 2
        end
      end

      CALC: begin
        //$display("--Calc--");

        // To calculate A * bt for next cycle
        big_mult = A;
        small_mult = B_reg[`BETALEN-1:0];
        B_reg = {B_cat, B_reg[`B_REGLEN-1:`BETALEN]};
        // $display("smal_mult set to : %d", small_mult);

        state = CALC1;
      end

      CALC1: begin
        // $display("--Calc1--");

        // $display("big_mult: %0d", big_mult);
        // $display("small_mult: %0d", small_mult);

        // To calculate M * qt for next cycle
        // This is the new qt, only `BETA bit multiplication
        // $display("Mu: %0d, a0: %0d, small_mult %0d, P: %0d", mu, a0, small_mult, P[`BETALEN-1:0]);
        small_mult = (mu * (a0 * small_mult + P[`BETALEN-1:0]));
        big_mult = M;
        // $display("smal_mult set to : %d", small_mult);
        // mult_out is A * bt
        P = mult_out + P;

        state = CALC2;
      end

      CALC2: begin
        // $display("--Calc2--");

        // These are set in the previous cycle (CALC1)
        // $display("big_mult: %0d", big_mult);
        // $display("small_mult: %0d", small_mult);

        // mult_out is M * qt
        P = (P + mult_out) >> `BETALEN;
        // P = (A_bt + M_qt + {`BETALEN'd0, P}) >> `BETALEN; // TODO need to split up over multiple clocks
        // $display("P: %0d", P);

        count = count - 1;
        // $display("count: %0d", count);

        if (stop) begin
          // Can we avoid this subtraction?!
          P = (P < M) ? P : P - M;
          // $display("STOP: %d", P);
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

  // wire [`BITLEN-1:0] a_s0;
  // wire [`BITLEN:0] a_s1;

  // assign a_s0 = A & {`BITLEN{B[0]}};
  // assign a_s1 = (A & {`BITLEN{B[1]}}) << 1;

  // assign a_s0 = B[0] ? A : {`BITLEN{1'b0}};
  // assign a_s1 = B[1] ? (A << 1) :  {`BITLEN+1{1'b0}};

  assign P = A & {`BITLEN{B[0]}};
endmodule
