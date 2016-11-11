`default_nettype none

`define BITLEN 1024
`define log_BITLEN 10
module mon_exp (
  clk,
  start,
  M_bar,
  x_bar,
  e,
  n,
  stop,
  exp
  );

  localparam  IDLE = 2'b0;
  localparam  CALC = 2'b1;
  localparam  CALC1 = 2'd2;
  localparam  CALC2 = 2'd3;

  input clk;
  input start;
  input [`BITLEN-1:0] M_bar;
  input [`BITLEN-1:0] x_bar;
  input [`BITLEN-1:0] e;
  input [`BITLEN-1:0] n;

  output reg [`BITLEN-1:0] exp;
  output reg stop;

  reg mp_start;
  wire mp_stop;
  reg [`BITLEN-1:0] mp_A;
  reg [`BITLEN-1:0] mp_B;
  reg [`BITLEN-1:0] mp_M;
  reg [1:0] state;
  initial state = IDLE;

  reg [`log_BITLEN-1:0] count;

  mon_prod mp (
    .clk(clk),
    .start(mp_start),
    .A(mp_A),
    .B(mp_B),
    .M(mp_M),
    .stop(stop),
    .P(exp)
    );

  always @(posedge clk) begin
    case (state)
      IDLE: begin
        if (start) begin
          count <= `log_BITLEN-1;
          mp_A <= x_bar;
          mp_B <= x_bar;
          mp_M <= n;
          state = e[0] ? CALC1 : CALC;
          e = e >> 1;
        end
      end
      CALC: begin
          // x_bar = Nat()._mon_pro(x_bar, x_bar, n_, n_nat)
          count <= count - 1;
          mp_A <= exp;
          mp_B <= exp;
          state <= e[0] ? CALC1: !(|count) ? CALC2 : CALC;
            // if ei === 1: then do the next round, else if we are done go to stop
            // else do another round of calculation
      end
      CALC1: begin
        // x_bar = Nat()._mon_pro(M_bar, x_bar, n_, n_nat)
        mp_A <= M_bar;
        mp_B <= exp;
        state <= !(|count) ? CALC2 : CALC;
      end

      CALC2: begin:
        stop <= 1'b1;
        state <= IDLE;
    endcase
  end
endmodule
