ghdl -c --workdir=work --std=08 conf.vhd ALU.vhd ./testbench/ALU_tb.vhd
ghdl -r --workdir=work --std=08 ALU_tb