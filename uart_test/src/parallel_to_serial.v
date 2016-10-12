`default_nettype none
module serial_to_parallel (
  iCE_CLK,
	rx_valid,
	rx_byte,
	tx_bytes,
	tx_valid,
	);
  parameter N = 16;
  parameter Ndiv4log2 = 3;

	// IO
	input iCE_CLK;
	input rx_valid;
	input [7:0] rx_byte;
	output [N-1:0] tx_bytes;
	output tx_valid;

  reg [N-1:0] tx_bytes;
	reg tx_valid;

	//initial tx_bytes = N'b0;
  initial tx_valid = 1'b0;
	// internal wires
	reg[Ndiv4log2-1:0] count;
  initial count = 0;
	wire [N-1:0] shifted;
	wire [N-1:0] ored;
	// can always do this calculation
	assign shifted = tx_bytes << 4'd8;
	assign ored = shifted | rx_byte;
	// if it is valid then assign it to the register
	always @(posedge iCE_CLK) begin
    $display("N = %d", N);

    //$display("rd_valid: %x", rx_valid);
		if (rx_valid) begin
      // $display("rx_byte: %x", rx_byte);
      // $display("shifted: %x", shifted);
      // $display("ored: %x", ored);
      // $display("tx_bytes: %x", tx_bytes);
			tx_bytes = ored;
      // $display("tx_bytes: %x", tx_bytes);
      // $display("tx_bytes: %x", tx_bytes);
      // $display("tx_valid: %x", tx_valid);
			count = count + 1'b1;
      $display("count: %x", count);
      $display("count: %b", count);
      $display("count: %b", count[Ndiv4log2-1]);

			if (count[Ndiv4log2-1]) begin
				tx_valid = 1'b1;
				count = 0;
			end
		end
		if (tx_valid & ~rx_valid) begin
			tx_valid <= 1'b0;
		end
    // $display("tx_bytes: %x", tx_bytes);
    // $display("tx_valid: %x", tx_valid);
	end

endmodule //
