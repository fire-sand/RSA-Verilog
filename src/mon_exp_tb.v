`default_nettype none
`timescale 1 ns / 100 ps

module mon_exp_tb();

parameter bitLen = 1024;
parameter ABITS = 8, DBITS = 512;

reg clk = 0;
always #100 clk = ~clk;


//inputs to test are reg type;
reg start;
reg [bitLen-1:0] M_bar;
reg [bitLen-1:0] x_bar;
reg [bitLen-1:0] n;
reg [bitLen-1:0] e;
reg [9:0] e_idx;
reg [9:0] mp_count;

// outputs are wire
wire stop;
wire [bitLen:0] ans;

// wires to connect mp and bram
wire [ABITS-1:0] wr_addr;
wire [DBITS-1:0] wr_data;
wire wr_en;

reg [ABITS-1:0] wr_addr2;
reg [DBITS-1:0] wr_data2;
reg wr_en2;

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

initial begin
  $display("<< Starting Simulation mon_exp >>");
  clk = 1'b0;


  @(negedge clk);
  e = 300;
  e_idx = 8;
  n = 589;
  mp_count = 10;
  // M = 311;

  wr_en2 = 1;
  wr_addr2 = 0;
  wr_data2 = 1024'd435;
  start = 0;

  @(negedge clk);
  // high bits of A
  wr_en2 = 1;
  wr_addr2 = 1;
  wr_data2 = 1024'd0;
  n = 589;
  mp_count = 10;

  @(negedge clk);
  // low bits of B
  wr_en2 = 1;
  wr_addr2 = 2;
  wr_data2 = 1024'd571;

  @(negedge clk);
  // high bits of B
  wr_en2 = 1;
  wr_addr2 = 3;
  wr_data2 = 1024'd0;

  @(negedge clk);
  wr_en2 = 0;
  start = 1;

  @(negedge clk);
  start = 0;


  // @(negedge clk);
  // $display("-- TB");
  // $display("ans: %0d\n", ans);
  // $display("stop: %0d\n", stop);

  @(posedge stop);
  $display("-- TB");
  $display("ans: %0d\n", ans);
  $display("stop: %0d\n", stop);
  $display("start: %0d\n", start);

  $display("<< End of simulation >>");
  $finish;
end
endmodule
