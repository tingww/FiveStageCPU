`timescale 1ns / 1ps
module HDU(ID_EX_writeREG2,ID_EXE_MEMread,
	readREG1,readREG2,PCstall,IF_IDstall,CTRLmux);
input [2:0] readREG1,readREG2,ID_EX_writeREG2;
input ID_EXE_MEMread;
output reg PCstall,IF_IDstall,CTRLmux;

always@(*)
begin
	if(ID_EXE_MEMread && (ID_EX_writeREG2==readREG1 || ID_EX_writeREG2==readREG2) )
	begin
		PCstall=1'b1;
		IF_IDstall=1'b1;
		CTRLmux=1'b1;
	end
	else begin
		PCstall=1'b0;
		IF_IDstall=1'b0;
		CTRLmux=1'b0;
	end
end

endmodule

