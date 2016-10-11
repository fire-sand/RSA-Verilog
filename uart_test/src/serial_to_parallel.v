`default_nettype none
module serial_to_parallel (
  iCE_CLK,
	rx_valid,
	rx_byte,
	tx_bytes,
	tx_valid,
	);
	// IO
	input iCE_CLK;
	input rx_valid;
	input [7:0] rx_byte;
	output [15:0] tx_bytes;
	output tx_valid;

  reg [15:0] tx_bytes;
	reg tx_valid;

	initial tx_bytes = 16'b0;
  initial tx_valid = 1'b0;
	// internal wires
	reg[1:0] count;
  initial count = 2'b0;
	wire [15:0] shifted;
	wire [15:0] ored;
	// can always do this calculation
	assign shifted = tx_bytes << 4'd8;
	assign ored = shifted | rx_byte;
	// if it is valid then assign it to the register
	always @(posedge iCE_CLK) begin
    $display("rd_valid: %x", rx_valid);
		if (rx_valid) begin
      $display("rx_byte: %x", rx_byte);
      $display("shifted: %x", shifted);
      $display("ored: %x", ored);
      $display("tx_bytes: %x", tx_bytes);
			tx_bytes = ored;
      $display("tx_bytes: %x", tx_bytes);
      $display("tx_bytes: %x", tx_bytes);
      $display("tx_valid: %x", tx_valid);
			count = count + 1'b1;
      $display("count: %x", count);
			if (count == 2'b1) begin
				tx_valid = 1'b1;
				count = 2'b0;
			end
		end
		if (tx_valid & ~rx_valid) begin
			tx_valid <= 1'b0;
		end
    $display("tx_bytes: %x", tx_bytes);
    $display("tx_valid: %x", tx_valid);
	end

endmodule //
