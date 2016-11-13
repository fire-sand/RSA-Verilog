serial_to_parallel:
	iverilog -o .pioenvs/icestick/serial_to_prallel_tb.out src/serial_to_parallel.v src/serial_to_parallel_tb.v
	.pioenvs/icestick/serial_to_prallel_tb.out

parallel_to_serial:
	iverilog -o .pioenvs/icestick/parallel_to_serial_tb.out src/parallel_to_serial.v src/parallel_to_serial_tb.v
	.pioenvs/icestick/parallel_to_serial_tb.out

shift_add_mult5:
	iverilog -o .pioenvs/icestick/shift_add_mult4_tb.out src/shift_add_mult4.v src/shift_add_mult4_tb.v
	.pioenvs/icestick/shift_add_mult4_tb.out

shift_add_mult4_lut:
	yosys -p "synth_ice40 -blif ./test.blif" src/shift_add_mult4.v
	rm ./test.blif

mon_prod:
	rm -f .pioenvs/icestick/mon_prod_tb.out
	iverilog -o .pioenvs/icestick/mon_prod_tb.out src/mon_prod.v src/mon_prod_tb.v
	.pioenvs/icestick/mon_prod_tb.out

mon_prod_lut:
	yosys -p "synth_ice41 -abc2 -blif ./test.blif" src/mon_prod.v

mon_exp:
	rm -f .pioenvs/icestick/mon_exp_tb.out
	iverilog -o .pioenvs/icestick/mon_exp_tb.out src/mon_prod.v src/mon_exp.v src/mon_exp_tb.v
	.pioenvs/icestick/mon_exp_tb.out
