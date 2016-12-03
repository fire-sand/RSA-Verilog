/*
 * Copyright 2015 Forest Crossman
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

`include "cores/osdvu/uart.v"
//`default_nettype none

module top(
	clk,
	RS232_Rx_TTL,
	RS232_Tx_TTL,
	LED0,
	LED1,
	LED2,
	LED3,
	LED4
	);
	parameter N = 32;
	parameter Ndiv4log2 = 3;
	parameter bitLen = 64; //
  parameter log2BitLendiv4 = 4;

	input clk;
	input RS232_Rx_TTL;
	output RS232_Tx_TTL;
	output LED0;
	output LED1;
	output LED2;
	output LED3;
	output LED4;

	// UART wires
	wire reset = 0;
	wire transmit;
	wire [7:0] tx_byte;
	wire received;
	wire [7:0] rx_byte;
	wire is_receiving;
	wire is_transmitting;
	wire recv_error;

	// serial_to_parallel wires
	wire [N-1:0] stp_output_bus;
	wire stp_output_valid;


	assign LED4 = is_transmitting;
	//assign {LED3, LED2, LED1, LED0} = rx_byte[7:4];
	assign LED3 = is_transmitting;
	assign LED2 = transmit;

	uart #(
		.baud_rate(9600),                 // The baud rate in kilobits/s
		.sys_clk_freq(12000000)           // The master clock frequency
	)
	uart0(
		.clk(clk),                    // The master clock for this module
		.rst(reset),                      // Synchronous reset
		.rx(RS232_Rx_TTL),                // Incoming serial line
		.tx(RS232_Tx_TTL),                // Outgoing serial line
		.transmit(transmit),              // Signal to transmit
		.tx_byte(tx_byte),                // Byte to transmit
		.received(received),              // Indicated that a byte has been received
		.rx_byte(rx_byte),                // Byte received
		.is_receiving(is_receiving),      // Low when receive line is idle
		.is_transmitting(is_transmitting),// Low when transmit line is idle
		.recv_error(recv_error)           // Indicates error in receiving packet.
	);

	serial_to_parallel #(
		.N(N),
		.Ndiv4log2(Ndiv4log2),
	) stp (
	  .clk(clk),
		.rx_valid(received),
		.rx_byte(rx_byte),
		.tx_bytes(stp_output_bus),
		.tx_valid(stp_output_valid)
	);

	parallel_to_serial #(
		.N(N),
		.Ndiv4log2(Ndiv4log2),
	) pts (
	  .clk(clk),
		.rx_valid(stp_output_valid),
		.rx_bytes(stp_output_bus),
		.is_transmitting(is_transmitting),
		.tx_byte(tx_byte),
		.tx_valid(transmit)
	);


   //always @(posedge clk) begin
     //if (received) begin
       //tx_byte <= rx_byte;
       //transmit <= 1;
     //end else begin
       //transmit <= 0;
     //end
   //end
endmodule
