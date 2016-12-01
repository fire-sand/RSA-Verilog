`default_nettype none

module mon_exp (
  clk,
  start,
  e,
  e_idx,
  M, // modulus
  mp_count,
  op_code,
  rd_addr,
  rd_data,
  wr_data,
  wr_addr,
  wr_en,
  stop,
  ans
  );

  localparam  BITLEN = 512;
  localparam  LOG_BITLEN = 9;
  localparam  IDLE = 3'b0;
  localparam  CALC = 3'b1;
  localparam  CALC1 = 3'd2;
  localparam  CALC2 = 3'd3;
  localparam  END = 3'd4;

  localparam OPXX = 2'd0;
  localparam OPXM = 2'd1;
  localparam OPX1 = 2'd2;

  parameter ABITS = 8, DBITS = 512;

  input clk;
  input start;
  input [BITLEN-1:0] e;
  input [LOG_BITLEN-1:0] e_idx;
  input [BITLEN-1:0] M;
  input [LOG_BITLEN:0] mp_count;
  input [DBITS-1:0] rd_data;

  output reg [1:0] op_code;
  output [ABITS-1:0] rd_addr;
  output [DBITS-1:0] wr_data;
  output [ABITS-1:0] wr_addr;
  output wr_en;
  output [BITLEN-1:0] ans;
  output reg stop;
  initial stop = 1'b0;

  //reg [BITLEN-1:0] reg_e;
  reg mp_start;
  reg old_mp_start;
  initial mp_start = 0;
  initial old_mp_start = 0;
  wire mp_stop;
  reg old_mp_stop;
  reg [BITLEN-1:0] mp_M;
  reg [2:0] state;
  initial state = IDLE;

  reg [LOG_BITLEN-1:0] idx;

  mon_prod mp (
    .clk(clk),
    .start(mp_start),
    .op_code(op_code),
    .M(M),
    .mp_count(mp_count),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .wr_data(wr_data),
    .wr_addr(wr_addr),
    .wr_en(wr_en),
    .stop(mp_stop),
    .P(ans)
    );



  always @(posedge clk) begin
  // $display("mp_stop %d", mp_stop);
  // $display(state);
    if (old_mp_start && mp_start) begin
      mp_start = 0;
    end
    old_mp_start = mp_start;
    // $display("new");
    case (state)
      IDLE: begin
        if (start) begin
          //$display("exp IDLE: e_idx: %0d,  e: %0b", e_idx, e);

          //$display(" %0d * %0d mod %0d", x_bar, x_bar, n);
          op_code <= OPXX;
          idx = e_idx-1;
          state = e[e_idx] ? CALC1 : CALC;
          $display("e: %0b, idx: %0d", e, idx);
          $display("e[%0d] = %0d", e_idx, e[e_idx]);
          mp_start <= 1'b1;
        end
      end
      CALC: begin
          if(mp_stop && !old_mp_stop) begin
            // $display("exp CALC");
            // x_bar = Nat()._mon_pro(x_bar, x_bar, n_, n_nat)
            // $display("(%0d) * (%0d)  mod n = %0d", mp_A, mp_B, ans);
            //stop <= 1; // DEBUG TODO remove
            // count <= count - 1;
            op_code <= OPXX;
            // $display("%0d * %0d mod %0d", ans, ans, n);
            mp_start = 1;
          //  reg_e = reg_e >> 1;
            state = e[idx] ? CALC1: !(|idx) ? CALC2 : CALC;
            $display("e[%0d] = %0d", idx, e[idx]);
            // $display("HELLO state: %0d, e[idx]: %d, idx", state, e[idx], idx);
            idx = idx-1;

          end
            // if ei === 1: then do the next round, else if we are done go to stop
            // else do another round of calculation
      end
      CALC1: begin
        if(mp_stop && !old_mp_stop) begin
          // $display("exp CALC1");
          // x_bar = Nat()._mon_pro(M_bar, x_bar, n_, n_nat)
          // $display("(%0d) * (%0d) mod n = %0d", mp_A, mp_B, ans);
          op_code = OPXM;
          // $display("%0d * %0d mod %0d", M_bar, ans, n);

          mp_start = 1;
          state = !(|idx) ? CALC2 : CALC;
          // $display("state: %0d", state);
        end
      end

      CALC2: begin
        if(mp_stop && !old_mp_stop) begin
          op_code = OPX1;
          mp_start = 1;
          state = END;
          // $display("exp CALC2");
        end
      end

      END: begin
        if(mp_stop && !old_mp_stop) begin
          stop <= 1'b1;
          mp_start = 1'b0;
          // $display("END");
          state <= IDLE;
        end
      end
    endcase
    old_mp_stop = mp_stop;
  end
endmodule
