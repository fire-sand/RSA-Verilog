`default_nettype none
module serial_to_parallel (
  clk,
  rst,
  rx_valid,
  rx_byte,
  tx_e_idx,
  tx_mp_count,
  tx_e,
  tx_bytes,
  tx_valid,
  wr_addr,
  wr_data,
  wr_en
  );
  parameter N = 32;
  parameter Ndiv4log2 = 3;
  parameter Nlog2 = 5;
  parameter ABITS = 8, DBITS = 32;


  // MAKE SURE ARGS ARE PASSED IN THIS ORDER!!!!!!!
  parameter RX_MP_COUNT = 0;
  parameter RX_E_IDX = 1;
  parameter RX_XBAR = 2;
  parameter RX_MBAR = 3;
  parameter RX_E = 4;
  parameter RX_N = 5;


  // IO
  input clk;
  input rst;
  input rx_valid;
  input [7:0] rx_byte;
  output reg [Nlog2-1:0] tx_e_idx;
  output reg [Nlog2-1:0] tx_mp_count;
  output reg [N-1:0] tx_e;
  output reg [N-1:0] tx_bytes = 0; // tx_n
  output reg tx_valid;
  output reg [DBITS-1:0] wr_data;
  output reg [ABITS-1:0] wr_addr;
  output reg wr_en;

  reg [2:0] state;
  initial state = RX_MP_COUNT;

  initial tx_valid = 1'b0;
  // internal wires
  reg[Ndiv4log2-1:0] count;
  initial count = 0;
  wire [N-1:0] shifted;
  wire [N-1:0] ored;
  // can always do this calculation
  // if it is valid then assign it to the register

  always @(posedge clk) begin
    if (rst && 0) begin
      state <= RX_MP_COUNT;
      tx_bytes <= {N{1'b0}};
      tx_valid <= 0;
      count <= 0;
      wr_en <= 0;
    end
    //$display("rd_valid: %x", rx_valid);
    if (rx_valid) begin
      //$display("rx_byte: %x", rx_byte);
      // $display("shifted: %x", shifted);
      //$display("ored: %x", ored);
      // $display("tx_bytes: %x", tx_bytes);
      tx_bytes = {tx_bytes[N-8:0], rx_byte};
      // $display("tx_bytes: %x", tx_bytes);
      // $display("tx_bytes: %x", tx_bytes);
      // $display("tx_valid: %x", tx_valid);
      count = count + 1'b1;
      //$display("count: %x", count);
      //$display("count: %b", count);
      //$display("count: %b", count[Ndiv4log2-1]);
      case (state)
        RX_MP_COUNT: begin
          $display("RX_MP_COUNT");
          tx_mp_count = rx_byte;
          state = RX_E_IDX;
          count = 0;
        end
        RX_E_IDX: begin
          $display("RX_E_IDX");
          tx_e_idx = rx_byte;
          state = RX_XBAR;
          count = 0;
        end
      endcase


      // $display("addr 0 should be %x", wr_data);
      if (count[Ndiv4log2-1]) begin
        count = 0;
        case (state)
          RX_XBAR: begin
            $display("RX_XBAR");
            wr_en <= 1;
            wr_addr <= 0;
            wr_data <= tx_bytes;
            // $display("addr 0 should be %x", tx_bytes);
            // $display("addr 0 should be %x", wr_data);
            state <= RX_MBAR;
          end
          RX_MBAR: begin
            $display("RX_MBAR");
            wr_en <= 1;
            wr_addr <= 2;
            wr_data <= tx_bytes;
            state <= RX_E;
          end
          RX_E: begin
            $display("RX_E");
            wr_en <= 0;
            tx_e <= tx_bytes;
            state <= RX_N;
          end

          RX_N: begin
            $display("%0x", tx_bytes);
            tx_valid = 1'b1;
            state <= RX_MP_COUNT;
          end
        endcase


      end
    end
    if (tx_valid & ~rx_valid) begin
      tx_valid <= 1'b0;
    end
    // $display("tx_bytes: %x", tx_bytes);
    // $display("tx_valid: %x", tx_valid);
  end

endmodule //
