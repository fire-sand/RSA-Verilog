`default_nettype none
module top(
  clk,
  RS232_Rx,
  RS232_Tx,
  LED1,
  LED2,
  LED3,
  LED4
  );

  //TODO add a transmitting so that this module cant be interrupted while
  // transmitting, right now it is just undefined behavior
  //
  //parameter BITLEN = 512;
  //parameter BITLENdiv4log2 = 7;
  //parameter LOG_BITLEN = 9;
  //parameter ABITS = 8, DBITS = BITLEN;

  parameter BITLEN = 256;
  parameter BITLENdiv4log2 = 6;
  parameter LOG_BITLEN = 8;
  parameter ABITS = 8, DBITS = BITLEN;

  //parameter BITLEN = 16;
  //parameter BITLENdiv4log2 = 2;
  //parameter LOG_BITLEN = 4;
  //parameter ABITS = 8, DBITS = BITLEN;

  //parameter BITLEN = 32;
  //parameter BITLENdiv4log2 = 3;
  //parameter LOG_BITLEN = 5;
  //parameter ABITS = 8, DBITS = BITLEN;

  input clk;
  wire rst = 0;
  input RS232_Rx;
  output RS232_Tx;
  output LED1;
  output LED2;
  output LED3;
  output LED4;

  // UART wires
  wire transmit;
  wire [7:0] tx_byte;
  wire received;
  wire [7:0] rx_byte;
  wire is_receiving;
  wire is_transmitting;
  wire recv_error;

  // serial_to_parallel wires
  wire [BITLEN-1:0] stp_output_bus;
  wire stp_output_valid;


  assign LED1 = is_receiving;
  assign LED2 = is_receiving;
  assign LED4 = is_transmitting;
  assign LED3 = is_transmitting;

  // wires to connect bram
  wire [ABITS-1:0] wr_addr1;
  wire [DBITS-1:0] wr_data1;
  wire wr_en1;

  wire [ABITS-1:0] wr_addr2;
  wire [DBITS-1:0] wr_data2;
  wire wr_en2;

  wire [ABITS-1:0] rd_addr;
  wire [DBITS-1:0] rd_data;

  // mon_exp wires
  wire [BITLEN-1:0] e;
  wire [LOG_BITLEN-1:0] e_idx;
  wire [BITLEN-1:0] n;
  wire [LOG_BITLEN:0] mp_count;
  wire stop;
  wire [BITLEN-1:0] ans;

  uart #(
    .baud_rate(9600),                 // The baud rate in kilobits/s
    .sys_clk_freq(12000000)           // The master clock frequency
  )
  uart(
    .clk(clk),                        // The master clock for this module
    .rst(rst),                        // Synchronous reset
    .rx(RS232_Rx),                    // Incoming serial line
    .tx(RS232_Tx),                    // Outgoing serial line
    .transmit(transmit),              // Signal to transmit
    .tx_byte(tx_byte),                // Byte to transmit
    .received(received),              // Indicated that a byte has been received
    .rx_byte(rx_byte),                // Byte received
    .is_receiving(is_receiving),      // Low when receive line is idle
    .is_transmitting(is_transmitting),// Low when transmit line is idle
    .recv_error(recv_error)           // Indicates error in receiving packet.
  );

  bram #(
    .ABITS(ABITS),
    .DBITS(DBITS)
  ) br (
    .clk(clk),
    .WR_ADDR1(wr_addr1),
    .WR_DATA1(wr_data1),
    .WR_EN1(wr_en1),
    .WR_ADDR2(wr_addr2),
    .WR_DATA2(wr_data2),
    .WR_EN2(wr_en2),
    .RD_ADDR(rd_addr),
    .RD_DATA(rd_data)
  );

  mon_exp #(
    .BITLEN(BITLEN),
    .LOG_BITLEN(LOG_BITLEN),
    .ABITS(ABITS),
    .DBITS(DBITS),
  )mp (
    .clk(clk),
    .start(stp_output_valid),
    .e(e), // ^ e
    .e_idx(e_idx),
    .n(n),  // mod n
    .mp_count(mp_count),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .wr_data(wr_data1),
    .wr_addr(wr_addr1),
    .wr_en(wr_en1),
    .stop(stop),
    .ans(ans)
  );

  serial_to_parallel #(
    .N(BITLEN),
    .Ndiv4log2(BITLENdiv4log2),
    .Nlog2(LOG_BITLEN),
    .ABITS(ABITS),
    .DBITS(DBITS)
  ) stp (
    .clk(clk),
    .rst(rst),
    .rx_valid(received),
    .rx_byte(rx_byte),
    .tx_e_idx(e_idx),
    .tx_mp_count(mp_count),
    .tx_e(e),
    .tx_bytes(n),
    .tx_valid(stp_output_valid),
    .wr_addr(wr_addr2),
    .wr_data(wr_data2),
    .wr_en(wr_en2)
  );

  parallel_to_serial #(
    .N(BITLEN),
    .Ndiv4log2(BITLENdiv4log2),
  ) pts (
    .clk(clk),
    .rx_valid(stop),
    .rx_bytes(ans),
    .is_transmitting(is_transmitting),
    .tx_byte(tx_byte),
    .tx_valid(transmit)
  );

endmodule
