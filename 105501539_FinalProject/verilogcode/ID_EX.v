`timescale 1ns / 1ps
module ID_EX(
nWBregwr,nWBregomem,nMEMwr,nEXalusrc,nEXaluctrl, nreadDATA1,nreadDATA2, nconstant,nwriteREG3, 
WBregwr,WBregomem,MEMwr,EXalusrc,EXaluctrl, readDATA1,readDATA2, constant,writeREG3,clk
,nwriteREG2,writeREG2,REGdst,nREGdst,nMEMread,MEMread,
nID_EX_readREG1,ID_EX_readREG1,nID_EX_readREG2,ID_EX_readREG2);
input nWBregwr,nWBregomem,nMEMwr,nEXalusrc,clk,nREGdst,nMEMread;
input [2:0]nEXaluctrl;
input [7:0]nreadDATA1,nreadDATA2;
input [7:0]nconstant;
input [2:0]nwriteREG3,nwriteREG2,nID_EX_readREG1,nID_EX_readREG2;

output reg WBregwr,WBregomem,MEMwr,EXalusrc,REGdst,MEMread;
output reg [2:0]EXaluctrl;
output reg [7:0]readDATA1,readDATA2;
output reg [7:0]constant;
output reg [2:0]writeREG3,writeREG2,ID_EX_readREG1,ID_EX_readREG2;

always@(posedge clk)
begin
	WBregwr<=nWBregwr;
	WBregomem<=nWBregomem;
	MEMwr<=nMEMwr;
	EXalusrc<=nEXalusrc;
	EXaluctrl<=nEXaluctrl;
	readDATA1<=nreadDATA1;
	readDATA2<=nreadDATA2;
	constant<=nconstant;
	writeREG3<=nwriteREG3;
	writeREG2<=nwriteREG2;
	REGdst<=nREGdst;
	MEMread<=nMEMread;
	ID_EX_readREG1<=nID_EX_readREG1;
	ID_EX_readREG2<=nID_EX_readREG2;
end

endmodule

