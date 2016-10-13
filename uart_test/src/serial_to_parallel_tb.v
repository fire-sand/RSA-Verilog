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
parameter N = 32;
parameter Ndiv4log2 = 3;



//-- Clock signal. It is not used in this simulation
reg clk = 0;
always #10 clk = ~clk; // invert clock every 10 ns

// inputs to test are reg type
reg rx_valid;
reg [7:0] rx_byte;

// outputs of test are wire type
wire [N-1:0] tx_bytes;
wire tx_valid;


//Instantiate the unit to test
serial_to_parallel #(
  .N(N),
  .Ndiv4log2(Ndiv4log2))
stp (
  .iCE_CLK(clk),
  .rx_valid(rx_valid),
  .rx_byte(rx_byte),
  .tx_bytes(tx_bytes),
  .tx_valid(tx_valid)
);


initial begin
  $display("<< Starting Simulation >>");
  clk = 1'b0; // time 0
  rx_valid = 0;

  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'hAA;
  $display("loading AA into the register");
  $display ("output: %x, tx_valid %b", tx_bytes, tx_valid);

  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'hBB;
  $display("loading BB into the register");
  $display ("output: %x, tx_valid %b", tx_bytes, tx_valid);

  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'hCC;
  $display("loading CC into the register");
  $display ("output: %x, tx_valid %b", tx_bytes, tx_valid);

  @(negedge clk);
  rx_valid = 1;
  rx_byte = 8'hDD;
  $display("loading DDinto the register");
  $display ("output: %x, tx_valid %b", tx_bytes, tx_valid);

  @(negedge clk);
  rx_valid = 0;
  $display("Output should be valid now");
  $display ("output: %x, tx_valid %b", tx_bytes, tx_valid);
  @(negedge clk);
  $display("Output should done now");
  $display ("output: %x, tx_valid %b", tx_bytes, tx_valid);


  //-- File were to store the simulation results
  // $dumpfile("leds_on_tb.vcd");
  // $dumpvars(0, leds_on_tb);
  $display("<< End of simulation >>");
  $finish;
end

endmodule
