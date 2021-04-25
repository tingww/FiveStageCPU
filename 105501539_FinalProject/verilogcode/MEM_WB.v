`timescale 1ns / 1ps
module MEM_WB(
nWBregwr,nWBregomem, nreadDATA, nALUout,nwriteREG,clk,
WBregwr,WBregomem, readDATA, ALUout ,writeREG);
input nWBregwr,nWBregomem,clk;
input [7:0] nreadDATA, nALUout;
input [2:0] nwriteREG;
output reg [7:0] readDATA,ALUout;
output reg [2:0] writeREG;
output reg WBregwr,WBregomem;


always@(posedge clk)
begin
	WBregwr<=nWBregwr;
	WBregomem<=nWBregomem;
	readDATA<=nreadDATA;
	ALUout<=nALUout;
	writeREG<=nwriteREG;
end

endmodule

