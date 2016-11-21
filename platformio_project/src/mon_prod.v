`default_nettype none

`define BITLEN 1024
`define BETA 2
`define BETALEN 1


/////// NOTE on storing data in memory
// x_bar - [0] low bits and [1] high bits
// M_bar - [2] low bits and [3] high bits
// m     - not stored in memory as it is always the same
// op_codes:
//    - OPXX = 0 , P = x_bar * x_bar mod m
//    - OPXM = 1, P = x_bar * M_bar mod m
//    - OPX1 = 2, P = x_bar * 1 mod m
//////

module mon_prod (
  clk,
  start,
  op_code,
  M,
  mp_count,
  rd_addr,
  rd_data,
  wr_data,
  wr_addr,
  wr_en,
  stop,
  P,
  );

  parameter ABITS = 8, DBITS = 512;
  // B = 2 ^ p
  localparam  p = 2;
  localparam  IDLE = 0;
  localparam  LOADA1 = 1;
  localparam  LOADA2 = 2;
  localparam  LOADB1 = 3;
  localparam  LOADB2 = 4;
  localparam  CALC = 5;
  localparam  CALC1 = 6;
  localparam  CALC2 = 7;
  localparam  STORE1 = 8;
  localparam  STORE2 = 9;

  localparam OPXX = 2'd0;
  localparam OPXM = 2'd1;
  localparam OPX1 = 2'd2;
  // width of the numbers being multiplied
  // parameter countWidth = 5;{{DBITS-1{1'b0}} rd_data}


  input clk;
  input start;
  input [1:0] op_code;
  input [`BITLEN-1:0] M;
  input [9:0] mp_count;
  input [DBITS-1:0] rd_data;

  output reg [ABITS-1:0] rd_addr;
  initial rd_addr = 0;
  output reg [DBITS-1:0] wr_data;
  output reg [ABITS-1:0] wr_addr;
  initial wr_addr = 0;
  output reg wr_en;
  initial wr_en = 0;
  output reg stop;
  output reg [`BITLEN + `BETALEN - 1:0] P;
  initial P = 1025'b0;



  wire [`BETALEN-1:0] B_cat;
  assign B_cat = {`BETALEN{1'b0}};
  wire [`BETALEN-1:0] a0;
  // wire [`BETALEN-1:0] m0;
  wire [`BETALEN-1:0] mu;

  reg [`BITLEN-1:0] A;
  reg [`BITLEN-1:0] B;
  reg [3:0]state;
  initial A = {`BITLEN{1'b1}};
  initial B = {`BITLEN{1'b1}};
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

  wire calc_end;
  assign calc_end = !(| count); // stop = 1 if count is 0


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
    //$display("\nnew clock\n");
    case (state)
      IDLE: begin
        if (start) begin
          // Load the low bits of A, either
          $display("OPxx?> %0d", op_code === OPXX);
          rd_addr <= 1; // there is a 2 clock cycle delay for read values, because of commiting of registers
          state <= LOADA1;
          stop <= 0;
          P <= 1025'b0;
          count <= mp_count; // should be `BITLEN if power of 2, otherwise next highest power of 2
        end
      end

      LOADA1: begin
        A[DBITS-1:0] <= rd_data;
        B[DBITS-1:0] <= rd_data;
        rd_addr <= 2;
        state <= LOADA2;
      end

      LOADA2: begin
        A[`BITLEN-1:DBITS] <= rd_data;
        B[`BITLEN-1:DBITS] <= (op_code == OPX1) ? {{511{1'b0}}, 1'b1} : rd_data; // TODO fix me
        rd_addr <= (op_code == OPXM) ? 3 : 0;
        state <= (op_code == OPXM) ? LOADB1: CALC;
        if(!(op_code == OPXM)) $display("Calc> A: %0d, B: %0d, M: %0d", A, B, M);
      end

      LOADB1: begin
        B <= {{DBITS-1{1'b0}}, rd_data};
        rd_addr <= 0;
        state <= LOADB2;
      end

      LOADB2: begin
        B <= {rd_data, B[DBITS-1:0]};
        rd_addr <= 0;
        state <= CALC;
        $display("Calc> A: %0d, B: %0d, M: %0d", A, B, M);

      end

      CALC: begin
        //$display("--Calc--");

        // To calculate A * bt for next cycle
        big_mult = A;
        small_mult = B[`BETALEN-1:0];
        B = {B_cat, B[`BITLEN-1:`BETALEN]};
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

        if (calc_end) begin
          // TODO need to fix this so the real stop does not go high until P is
          // done being stored in memory, the real stop can be if we in IDLE state
          // Can we avoid this subtraction?!
          // TODO make a new P_norm to be used only for writing back to mem
          P = (P < M) ? P : P - M;
          $display("CALC_END: %0d", P);
          state <= STORE1;
          wr_data <= P[DBITS-1:0];
          wr_en <= 1'b1;
          wr_addr <= 0;
          $display("wr_addr: %0d", wr_addr);
        end else begin
          state <= CALC;
        end
      end

      STORE1: begin
        wr_data <= P[`BITLEN-1:DBITS];
        wr_en <= 1'b1;
        wr_addr <= 1;
        $display("wr_addr: %0d", wr_addr);
        state <= STORE2;
      end

      STORE2: begin
        wr_en <= 1'b0;
        state <= IDLE;
        stop <= 1;
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
