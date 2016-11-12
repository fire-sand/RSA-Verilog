`default_nettype none

`define BITLEN 64
`define log_BITLEN 10
module mon_exp (
  clk,
  start,
  M_bar,
  x_bar,
  e,
  n,
  stop,
  ans
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

  output [`BITLEN-1:0] ans;
  output reg stop;
  initial stop = 1'b0;

  reg [`BITLEN-1:0] reg_e;
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
    .stop(mp_stop),
    .P(ans)
    );

  always @(posedge clk) begin
    case (state)
      IDLE: begin
      $display("exp IDLE");
        if (start) begin
          count <= `log_BITLEN-1;
          mp_A <= x_bar;
          mp_B <= x_bar;
          mp_M <= n;
          state = n[0] ? CALC1 : CALC;
          mp_start <= 1'b1;
        end
      end
      CALC: begin
          $display("exp CALC");
          if(mp_stop) begin
            // x_bar = Nat()._mon_pro(x_bar, x_bar, n_, n_nat)
            $display("x_bar * x_bar = %d", ans);
            count <= count - 1;
            mp_A <= ans;
            mp_B <= ans;
            mp_start <= 1;
            reg_e = reg_e >> 1;
            state = n[0] ? CALC1: !(|reg_e) ? CALC2 : CALC;
            $display("state: %d", state);
          end
            // if ei === 1: then do the next round, else if we are done go to stop
            // else do another round of calculation
      end
      CALC1: begin
        $display("exp CALC1");
        if(mp_stop) begin
          // x_bar = Nat()._mon_pro(M_bar, x_bar, n_, n_nat)
          $display("M_bar * x_bar = %d", ans);
          mp_A <= M_bar;
          mp_B <= ans;
          mp_start = 1;
          state <= !(|reg_e) ? CALC2 : CALC;
          $display("state: %d", state);
        end
      end

      CALC2: begin
        $display("exp CALC2");
        stop <= 1'b1;
        state <= IDLE;
      end
    endcase
  end
endmodule
