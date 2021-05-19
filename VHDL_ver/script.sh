ghdl -c --workdir=work --std=08 *.vhd ./testbench/*.vhd
ghdl -r --workdir=work --std=08 fifo_tb --vcd=fifo_tb.vcd