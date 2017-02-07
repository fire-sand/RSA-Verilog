//-------------------------------------------------------------------
//-- leds_on_tb.v
//-- Testbench
//-------------------------------------------------------------------
//-- BQ March 2016. Written by Juan Gonzalez (Obijuan)
//-------------------------------------------------------------------
`default_nettype none
`timescale 1 ns / 100 ps

module serial_to_parallel_tb();

//-- Simulation time: 1us (10 * 1ns)
// parameter DURATION = 10;
parameter BITLEN = 16;
parameter N = 16;
parameter BITLENdiv4log2 = 2;
parameter LOG_BITLEN = 4;
parameter ABITS = 8, DBITS = 16;



//-- Clock signal. It is not used in this simulation
reg clk = 0;
always #10 clk = ~clk; // invert clock every 10 ns

// inputs to test are reg type
reg rx_valid;
reg [7:0] rx_byte;

// outputs of test are wire type
wire tx_valid;

// wires to connect bram
wire [ABITS-1:0] wr_addr;
wire [DBITS-1:0] wr_data;
wire  wr_en;

// connected to stp and bram
wire [ABITS-1:0] wr_addr2;
wire [DBITS-1:0] wr_data2;
wire wr_en2;

wire [ABITS-1:0] rd_addr;
wire [DBITS-1:0] rd_data;

reg rst = 0;

wire [BITLEN-1:0] e;
wire [LOG_BITLEN-1:0] e_idx;
wire [BITLEN-1:0] n;
wire [LOG_BITLEN:0] mp_count;
wire stop;
wire [BITLEN-1:0] ans;


wire e_stop;


reg is_transmitting;
wire [7:0] tx_byte;
wire transmit;

//Instantiate the unit to test
serial_to_parallel #(
    .N(BITLEN),
    .Ndiv4log2(BITLENdiv4log2),
    .Nlog2(LOG_BITLEN),
    .ABITS(ABITS),
    .DBITS(DBITS)
  ) stp (
    .clk(clk),
    .rst(rst),
    .rx_valid(rx_valid),
    .rx_byte(rx_byte),
    .tx_e_idx(e_idx),
    .tx_mp_count(mp_count),
    .tx_e(e),
    .tx_bytes(n),
    .tx_valid(tx_valid),
    .wr_addr(wr_addr2),
    .wr_data(wr_data2),
    .wr_en(wr_en2)
  );

bram #(
    .ABITS(ABITS),
    .DBITS(DBITS)

  ) br (
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

mon_exp #(
    .BITLEN(BITLEN),
    .LOG_BITLEN(LOG_BITLEN),
    .ABITS(ABITS),
    .DBITS(DBITS)
  ) mp (
    .clk(clk),
    .start(tx_valid),
    .e(e), // ^ e
    .e_idx(e_idx),
    .n(n),  // mod n
    .mp_count(mp_count),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .wr_data(wr_data),
    .wr_addr(wr_addr),
    .wr_en(wr_en),
    .stop(e_stop),
    .ans(ans)
  );


 parallel_to_serial #(
    .N(BITLEN),
    .Ndiv4log2(BITLENdiv4log2)
  ) pts (
    .clk(clk),
    .rx_valid(e_stop),
    .rx_bytes(ans),
    .is_transmitting(is_transmitting),
    .tx_byte(tx_byte),
    .tx_valid(transmit)
  );

initial begin
  $display("<< Starting Simulation >>");
  clk = 1'b0; // time 0
  rx_valid = 0;
  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'd10;
  $display("loading 10 into the register");
  $display ("output: %x, tx_valid %b", n, tx_valid);

  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'd8;
  $display("loading 8 into the register");
  $display ("output: %x, tx_valid %b", n, tx_valid);

  // X_bar
  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'h01;
  $display("loading CC into the register");
  $display ("output: %x, tx_valid %b", n, tx_valid);

  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'hb3;
  $display("loading CC into the register");
  $display ("output: %x, tx_valid %b", n, tx_valid);


  // M_bar
  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'h02;
  $display("loading DDinto the register");
  $display ("output: %x, tx_valid %b", n, tx_valid);

  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'h3b;
  $display("loading DDinto the register");
  $display ("output: %x, tx_valid %b", n, tx_valid);

  // B
  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'h01;
  $display("loading DDinto the register");
  $display ("output: %x, tx_valid %b", n, tx_valid);

  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'h2c;
  $display("loading DDinto the register");
  $display ("output: %x, tx_valid %b", n, tx_valid);

  // M
  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'h02;
  $display("loading DDinto the register");
  $display ("output: %x, tx_valid %b", n, tx_valid);

  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'h4d;
  $display("loading DDinto the register");
  $display ("output: %x, tx_valid %b", n, tx_valid);

  // @(negedge clk);
  // rx_valid = 1;
  // $display("Output should be valid now");
  // $display ("output: %x, tx_valid %b", n, tx_valid);

  // @(negedge clk);
  // $display("Output should done now");
  // $display ("output: %x, tx_valid %b", n, tx_valid);


  @(posedge tx_valid);
  $display ("output: %x, tx_valid %b", n, tx_valid);
  $display("rd_data: %x", rd_data);
  $display("e_idx %0x", e_idx);
  $display("mp_count %0x", mp_count);
  $display("e %0x", e);
  $display("n %0x", n);
  rx_valid = 0;

  @(posedge transmit);
  $display("tx_byte: %0x", tx_byte);

  @(negedge clk);
  is_transmitting = 1;

  @(negedge clk);
  is_transmitting = 0;

  @(posedge transmit);
  $display("tx_byte: %0x", tx_byte);

  //-- File were to store the simulation results
  // $dumpfile("leds_on_tb.vcd");
  // $dumpvars(0, leds_on_tb);
  $display("<< End of simulation >>");
  $finish;
end

endmodule
