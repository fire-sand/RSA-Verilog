`default_nettype none

`define BITLEN 1024
`define log_BITLEN 10
module mon_exp (
  clk,
  start,
  M_bar,
  x_bar,
  e,
  e_idx,
  n,
  mp_count,
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
  input [`log_BITLEN-1:0] e_idx;
  input [`BITLEN-1:0] n;
  input [9:0] mp_count;

  output [`BITLEN-1:0] ans;
  output reg stop;
  initial stop = 1'b0;

  //reg [`BITLEN-1:0] reg_e;
  reg mp_start;
  wire mp_stop;
  reg [`BITLEN-1:0] mp_A;
  reg [`BITLEN-1:0] mp_B;
  reg [`BITLEN-1:0] mp_M;
  reg [1:0] state;
  initial state = IDLE;

  reg [`log_BITLEN-1:0] idx;

  mon_prod mp (
    .clk(clk),
    .start(mp_start),
    .A(mp_A),
    .B(mp_B),
    .M(mp_M),
    .mp_count(mp_count),
    .stop(mp_stop),
    .P(ans)
    );

  always @(posedge clk) begin
  // $display("mp_stop %d", mp_stop);
  // $display(state);
    case (state)
          IDLE: begin
        if (start) begin
          $display("exp IDLE: e_idx: ", e_idx);
          $display(" %0d * %0d mod %0d", x_bar, x_bar, n);
          mp_A <= x_bar;
          mp_B <= x_bar;
          mp_M <= n;
          idx <= e_idx-1;
          state = e[e_idx] ? CALC1 : CALC;
          mp_start <= 1'b1;
        end
      end
      CALC: begin
          if(mp_stop) begin
            $display("exp CALC");
            // x_bar = Nat()._mon_pro(x_bar, x_bar, n_, n_nat)
            $display("M_bar * x_bar  mod n = %0d", ans);
            //stop <= 1; // DEBUG TODO remove
            // count <= count - 1;
            mp_A <= ans;
            mp_B <= ans;
            $display("%0d * %0d mod %0d", ans, ans, n);
            mp_start <= 1;
          //  reg_e = reg_e >> 1;
            state = e[idx] ? CALC1: !(|idx) ? CALC2 : CALC;
            idx = idx-1;
            $display("state: %0d", state);
          end
            // if ei === 1: then do the next round, else if we are done go to stop
            // else do another round of calculation
      end
      CALC1: begin
        if(mp_stop) begin
          $display("exp CALC1");
          // x_bar = Nat()._mon_pro(M_bar, x_bar, n_, n_nat)
          $display("x_bar * x_bar mod n = %0d", ans);
          mp_A <= M_bar;
          mp_B <= ans;
          $display("%0d * %0d mod %0d", M_bar, ans, n);

          mp_start = 1;
          state = !(|idx) ? CALC2 : CALC;
          $display("state: %0d", state);
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
