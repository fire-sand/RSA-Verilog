//-------------------------------------------------------------------
//-- leds_on_tb.v
//-- Testbench
//-------------------------------------------------------------------
//-- BQ March 2016. Written by Juan Gonzalez (Obijuan)
//-------------------------------------------------------------------
`default_nettype none
`timescale 1 ns / 100 ps

module parallel_to_serial_tb();

//-- Simulation time: 1us (10 * 1ns)
// parameter DURATION = 10;
parameter N = 32;
parameter Ndiv4log2 = 3;



//-- Clock signal. It is not used in this simulation
reg clk = 0;
always #10 clk = ~clk; // invert clock every 10 ns

// inputs to test are reg type
reg rx_valid;
reg [N-1:0] rx_bytes;
reg is_transmitting;

// outputs of test are wire type
wire [7:0] tx_byte;
wire tx_valid;


//Instantiate the unit to test
parallel_to_serial #(
  .N(N),
  .Ndiv4log2(Ndiv4log2))
stp (
  .clk(clk),
  .rx_valid(rx_valid),
  .rx_bytes(rx_bytes),
  .is_transmitting(is_transmitting),
  .tx_byte(tx_byte),
  .tx_valid(tx_valid)
);


initial begin
  $display("<< Starting Simulation >>");
  clk = 1'b0; // time 0
  rx_valid = 0;
  is_transmitting = 0;


  // @(negedge clk);
  // rx_valid = 1;
  // rx_bytes = 32'hDDCCBBAA;
  //
  // @(negedge clk);
  // should be DD
  // $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  // is_transmitting = 0;
  //
  // @(negedge clk);
  // // since is_transmitting is high should not have advanced to next byte and
  // // tx_valid should be 0
  // $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  // is_transmitting = 0;
  //
  // @(negedge clk);
  // // should be CC
  // $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  //
  // @(negedge clk);
  // // should be BB
  // $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  //
  // @(negedge clk);
  // // should be AA
  // $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  //
  // @(negedge clk);
  // // should be tx_valid = 0 because we already went through all the btis
  // $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);

  $display("\n\n=================================\n\n");

  @(negedge clk);
  rx_valid = 1;
  rx_bytes = 32'hDDCCBBAA;

  @(negedge clk);
  // should be DD
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);

  @(negedge clk);
  // should be not valid
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);

  @(negedge clk);
  // should be not valid
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  is_transmitting = 1;

  @(negedge clk);
  // should be not valid
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  $display("falling edge now");
  is_transmitting = 0;

  @(negedge clk);
  // should be  CC
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  is_transmitting = 0;

  @(negedge clk);
  // should be not valid
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);

  @(negedge clk);
  // should be not valid
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  is_transmitting = 1;

  @(negedge clk);
  // should be not valid
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  $display("falling edge now");
  is_transmitting = 0;

  @(negedge clk);
  // should be  BB
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  is_transmitting = 0;
  @(negedge clk);
  // should be not valid
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);

  @(negedge clk);
  // should be not valid
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  is_transmitting = 1;

  @(negedge clk);
  // should be not valid
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  $display("falling edge now");
  is_transmitting = 0;

  @(negedge clk);
  // should be  AA
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);
  is_transmitting = 0;

  @(negedge clk);
  // should be  done
  $display(">>>>> tx_byte: %x tx_valid: %b", tx_byte, tx_valid);


  //-- File were to store the simulation results
  // $dumpfile("leds_on_tb.vcd");
  // $dumpvars(0, leds_on_tb);
  $display("<< End of simulation >>");
  $finish;
end

endmodule
