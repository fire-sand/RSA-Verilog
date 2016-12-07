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

  localparam IDLE = 0;
  localparam RECV = 1;
  localparam SEND = 2;
  localparam END = 3;

  input clk;
  input start;
  input [DBITS-1:0] rd_data;
  output reg  [ABITS-1:0] rd_addr;
  initial rd_addr = 0;
  output reg stop;
  output reg [BITLEN-1:0] out;

  reg [2:0] state = 0;

  always @(posedge clk) begin
    case (state)
      IDLE: begin
        if(start) begin
          rd_addr = 2;
          state = RECV;
        end
      end
      RECV: begin
        state <= SEND;
      end
      SEND: begin
        out <= rd_data;
        stop <= 1;
        state <= END;
      end
      END: begin
        stop <= 0;
        state <= IDLE;
      end
    endcase



  end

endmodule

