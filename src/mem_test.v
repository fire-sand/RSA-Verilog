`default_nettype none


module memtest (
  clk,
  start,
  rd_addr,
  rd_data,
  stop,
  out,
);

  parameter ABITS = 8, DBITS = 16;
  parameter BITLEN = 16;

  input clk;
  input start;
  input [DBITS-1:0] rd_data;
  output reg  [ABITS-1:0] rd_addr;
  initial rd_addr = 0;
  output reg stop;
  output reg [BITLEN-1:0] out;

  reg [2:0] count;

  always @(posedge clk) begin
    if(start) begin
      rd_addr = 0;
      count = 1;
    end
    if(count > 0) begin
      count = count + 1;
    end
    if (count === 3'd3) begin
      out = rd_data;
      stop = 1;
    end
    if (count === 3'd4) begin
      stop = 0;
      count = 0;
    end


  end

endmodule

