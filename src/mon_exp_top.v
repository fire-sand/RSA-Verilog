`default_nettype none
`timescale 1 ns / 100 ps

module mon_exp_top(
  input clk,
  input start,
  input [bitLen-1:0] n,
  input [bitLen-1:0] e,
  input [9:0] e_idx,
  input [9:0] mp_count,
  input [ABITS-1:0] wr_addr2,
  input [DBITS-1:0] wr_data2,
  input wr_en2,
  output stop,
  output [bitLen:0] ans
  );

parameter bitLen = 512;
parameter ABITS = 8, DBITS = 512;

// reg clk = 0;
// always #100 clk = ~clk;


//inputs to test are reg type;


// outputs are wire


// wires to connect mp and bram
wire [ABITS-1:0] wr_addr;
wire [DBITS-1:0] wr_data;
wire wr_en;



wire [ABITS-1:0] rd_addr;
wire [DBITS-1:0] rd_data;


mon_exp mp (
  .clk(clk),
  .start(start),
  .e(e), // ^ e
  .e_idx(e_idx),
  .M(n),  // mod n
  .mp_count(mp_count),
  .rd_addr(rd_addr),
  .rd_data(rd_data),
  .wr_data(wr_data),
  .wr_addr(wr_addr),
  .wr_en(wr_en),
  .stop(stop),
  .ans(ans)
  );

  bram br (
    .clk(clk),
    .WR_ADDR1(wr_addr),
    .WR_DATA1(wr_data),
    .WR_EN1(wr_en),
    .WR_ADDR2(wr_addr2),
    .WR_DATA2(wr_data2),
    .WR_EN2(wr_en2),
    .RD_ADDR(rd_addr),
    .RD_DATA(rd_data)
    );

endmodule
