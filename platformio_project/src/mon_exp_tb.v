`default_nettype none
`timescale 1 ns / 100 ps

module mon_exp_tb();

parameter bitLen = 1024;
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


mon_exp mp (
  .clk(clk),
  .start(start),
  .M_bar(M_bar), // M
  .x_bar(x_bar),  // M
  .e(e), // ^ e
  .e_idx(e_idx),
  .n(n),  // mod n
  .mp_count(mp_count),
  .stop(stop),
  .ans(ans)
  );

initial begin
  $display("<< Starting Simulation mon_exp >>");
  clk = 1'b0;


  @(negedge clk);
  M_bar = 571;
  x_bar = 435;
  e = 300;
  e_idx = 5;
  n = 589;
  mp_count = 10;
  // M = 311;

  start = 1;


  @(negedge clk);
  $display("-- TB");
  $display("ans: %0d\n", ans);
  $display("stop: %0d\n", stop);

  @(posedge stop);
  $display("-- TB");
  $display("ans: %0d\n", ans);
  $display("stop: %0d\n", stop);

  $display("<< End of simulation >>");
  $finish;
end
endmodule
