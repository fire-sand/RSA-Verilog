`default_nettype none
`timescale 1 ns / 100 ps

module mon_prod_tb();

parameter bitLen = 64;
parameter countWidth = 5;


reg clk = 0;
always #100 clk = ~clk;


//inputs to test are reg type;
reg start;
reg [bitLen-1:0] A;
reg [bitLen-1:0] B;
reg [bitLen-1:0] M;
reg

// outputs are wire
wire stop;
wire [bitLen-1:0] P;


mon_prod #(
  .bitLen(bitLen)
  ) mp (
  .clk(clk),
  .start(start),
  .A(A),
  .B(B),
  .M(M),
  .stop(stop),
  .P(P)
  );

initial begin
  $display("<< Starting Simulation >>");
  clk = 1'b0;


  @(negedge clk);
  A = 216;
  B = 123;
  M = 311;
  start = 1;


  @(negedge clk);
  $display("-- TB");
  $display("P: %d\n", P);
  $display("stop: %d\n", stop);

  // @(negedge clk);
  // $display("-- TB");
  // $display("P: %d\n", P);
  // $display("stop: %d\n", stop);
  //
  // @(negedge clk);
  // $display("-- TB");
  // $display("P: %d\n", P);
  // $display("stop: %d\n", stop);
  //
  // @(negedge clk);
  // $display("-- TB");
  // $display("P: %d\n", P);
  // $display("stop: %d\n", stop);
  //
  // @(negedge clk);
  // $display("-- TB");
  // $display("P: %d\n", P);
  // $display("stop: %d\n", stop);
  //
  // @(negedge clk);
  // $display("-- TB");
  // $display("P: %d\n", P);
  // $display("stop: %d\n", stop);

  @(posedge stop);
  $display("-- TB");
  $display("P: %d\n", P);
  $display("stop: %d\n", stop);

  $display("<< End of simulation >>");
  $finish;
end
endmodule
