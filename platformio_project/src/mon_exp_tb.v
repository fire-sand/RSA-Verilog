`default_nettype none
`timescale 1 ns / 100 ps

module mon_exp_tb();

parameter bitLen = 64;
parameter countWidth = 5;
reg clk = 0;
always #100 clk = ~clk;


//inputs to test are reg type;
reg start;
reg [bitLen-1:0] M_bar;
reg [bitLen-1:0] x_bar;
reg [bitLen-1:0] n;
reg [bitLen-1:0] e;

// outputs are wire
wire stop;
wire [bitLen:0] ans;


mon_exp mp (
  .clk(clk),
  .start(start),
  .M_bar(M_bar), // M
  .x_bar(x_bar),  // M
  .e(e), // ^ e
  .n(n),  // mod n
  .stop(stop),
  .ans(ans)
  );

initial begin
  $display("<< Starting Simulation mon_exp >>");
  clk = 1'b0;


  @(negedge clk);
  M_bar = 26;
  x_bar = 157;
  n = 589;
  // M = 311;

  start = 1;


  @(negedge clk);
  $display("-- TB");
  $display("ans: %d\n", ans);
  $display("stop: %d\n", stop);

  @(posedge stop);
  $display("-- TB");
  $display("ans: %d\n", ans);
  $display("stop: %d\n", stop);

  $display("<< End of simulation >>");
  $finish;
end
endmodule
