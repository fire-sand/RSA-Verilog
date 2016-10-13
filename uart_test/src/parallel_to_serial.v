`default_nettype none
module parallel_to_serial (
  iCE_CLK,
	rx_valid,
	rx_bytes,
  is_transmitting,
	tx_byte,
	tx_valid,
  );
  //TODO add a transmitting so that this module cant be interrupted while
  // transmitting, right now it is just undefined behavior

  parameter N = 16;
  parameter Ndiv4log2 = 2;

	// IO
	input iCE_CLK;
	input rx_valid;
	input [N-1:0] rx_bytes;
  input is_transmitting;
	output [7:0] tx_byte;
	output tx_valid;

  // output registers
	reg tx_valid;
  reg [7:0]tx_byte;
  reg [Ndiv4log2-1:0] count;
  initial count = 0;

  //local data
  reg [N-1:0] save_bytes;
  wire [7:0] last_byte;
  assign last_byte = save_bytes[N-1:N-8];
  reg stall;
  initial stall = 0;
	//initial tx_bytes = N'b0;
  initial tx_valid = 1'b1;
	always @(posedge iCE_CLK) begin
    // recieved new data to chunk out
  	if (rx_valid && count == 0) begin
      count <= 1;
      save_bytes <= rx_bytes << 4'd8;
      tx_byte <= rx_bytes[N-1:N-8];
      tx_valid <= 1'b1;
      stall <= 1'b1;
    end
    //start chunking the data if we are not already transmitting something
    else if (!is_transmitting && !count[Ndiv4log2-1] && count != 0 && stall == 0)begin
      tx_byte <= last_byte;
      tx_valid <= 1'b1;
      save_bytes <= save_bytes << 4'd8;
      count <= count + 1'b1;
      stall = 1'b1;
  	end else begin
      tx_valid <= 1'b0;
      if(count[Ndiv4log2-1]) begin
        count = 0;
      end
    end
    $display("count: %b", count);
  end

  always @(negedge is_transmitting) begin
    $display("no more stalling");
    stall = 1'b0;
  end
endmodule
