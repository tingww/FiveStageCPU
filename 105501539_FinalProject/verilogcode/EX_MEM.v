`timescale 1ns / 1ps
module EX_MEM(
nWBregwr,nWBregomem,nMEMwr, nconstant,nwriteREG,nALUout,clk,
WBregwr,WBregomem,MEMwr, constant,writeREG, ALUout,nreadDATA2,readDATA2);
input nWBregwr,nWBregomem,nMEMwr,clk;
input [7:0]nconstant,nALUout,nreadDATA2;
input [2:0]nwriteREG;

output reg WBregwr,WBregomem,MEMwr;
output reg [7:0]constant, ALUout,readDATA2;
output reg [2:0]writeREG;


always@(posedge clk)
begin
	WBregwr<=nWBregwr;
	WBregomem<=nWBregomem;
	MEMwr<=nMEMwr;
	ALUout<=nALUout;
	constant<=nconstant;
	writeREG<=nwriteREG;
	readDATA2<=nreadDATA2;
end

endmodule

