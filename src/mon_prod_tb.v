`default_nettype none
`timescale 1 ns / 100 ps

module mon_prod_tb();

parameter bitLen = 256;
parameter ABITS = 8, DBITS = 256;
localparam OPXX = 2'd0;
localparam OPXM = 2'd1;
localparam OPX1 = 2'd2;

reg clk = 0;
always #100 clk = ~clk;


//inputs to test are reg type;
reg start;
reg [1:0] op_code;
reg [bitLen-1:0] M;
reg [9:0] mp_count;

// outputs are wire
wire stop;
wire [bitLen:0] P;


// wires to connect mp and bram
wire [ABITS-1:0] wr_addr;
wire [DBITS-1:0] wr_data;
wire wr_en;

reg [ABITS-1:0] wr_addr2;
reg [DBITS-1:0] wr_data2;
reg wr_en2;

wire [ABITS-1:0] rd_addr;
wire [DBITS-1:0] rd_data;


mon_prod mp (
  .clk(clk),
  .start(start),
  .op_code(op_code),
  .M(M),
  .mp_count(mp_count),
  .rd_addr(rd_addr),
  .rd_data(rd_data),
  .wr_data(wr_data),
  .wr_addr(wr_addr),
  .wr_en(wr_en),
  .stop(stop),
  .P(P)
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
  $display("<< Starting Simulation >>");
  clk = 1'b0;


  @(negedge clk);
  // A = 216;
  // B = 123;
  // // M = 253;
  // M = 589;
  // mp_count = 10;
  // LOAD Low bits of A
  wr_en2 = 1;
  wr_addr2 = 0;
  wr_data2 = 1024'd435;
  start = 0;

  @(negedge clk);
  // high bits of A
  wr_en2 = 1;
  wr_addr2 = 1;
  wr_data2 = 1024'd0;
  M = 589;
  mp_count = 10;
  op_code = OPXM;

  @(negedge clk);
  // low bits of B
  wr_en2 = 1;
  wr_addr2 = 2;
  wr_data2 = 1024'd535;

  @(negedge clk);
  // high bits of B
  wr_en2 = 1;
  wr_addr2 = 3;
  wr_data2 = 1024'd0;

  @(negedge clk);
  wr_en2 = 0;
  M = 589;
  mp_count = 10;
  start = 1;



  @(negedge clk);
  $display("-- TB");
  $display("P: %0d\n", P);
  $display("stop: %d\n", stop);

  @(posedge stop);
  $display("-- TB");
  $display("P: %0d\n", P);
  $display("stop: %d\n", stop);

  /*@(negedge clk);*/
  //wr_en2 = 0;
  //M = 589;
  //mp_count = 10;
  //start = 1;

  //@(posedge stop);
  //$display("-- TB");
  //$display("P: %0d\n", P);
  /*$display("stop: %d\n", stop);*/

  $display("<< End of simulation >>");
  $finish;
end
endmodule
