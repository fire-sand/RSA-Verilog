`default_nettype none
`timescale 1 ns / 100 ps

module shift_add_mult4_tb();

reg clk = 0;
always #10 clk = ~clk; // invert clock every 10ns

// inputs to test are reg type
reg [3:0] a;
reg [3:0] b;

// outputs are wire
wire [7:0] p;

shift_add_mult4 sam (
  .a(a),
  .b(b),
  .p(p)
);

initial begin
  $display("<< Starting Simulation >>");
  clk = 1'b0; // time 0

  @(negedge clk);
  a = 4'd8;
  b = 4'd8;

  @(posedge clk);
  if (p !== 8'd64) begin
    $display("p is %d, expected: %d", p, 8'd64);
  end

  @(negedge clk);
  a = 4'd3;
  b = 4'd3;

  @(posedge clk);
  if (p !== 8'd9) begin
    $display("p is %d, expected: %d", p, 8'd9);
  end

  @(negedge clk);
  a = 4'd0;
  b = 4'd3;

  @(posedge clk);
  if (p !== 8'd0) begin
    $display("p is %d, expected: %d", p, 8'd0);
  end

  @(negedge clk);
  a = 4'd15;
  b = 4'd15;

  @(posedge clk);
  if (p !== 8'd225) begin
    $display("p is %d, expected: %d", p, 8'd0);
  end


  $display("<< End of simulation >>");
  $finish;
end
endmodule
