`timescale 1ns / 1ps
module IF_ID(nPC,PC,INS,clk,readREG1,readREG2,constant,writeREG3,CTRL,IFstall,IFflush);
input [7:0]nPC;
input [20:0]INS;
input clk,IFstall,IFflush;
output reg [2:0]readREG1,readREG2;
output reg [7:0]constant,PC;
output reg [2:0] writeREG3;
output reg [3:0]CTRL;

always@(posedge clk)
begin
	if(IFstall)
	begin
		CTRL<=CTRL;
		readREG1<=readREG1;
		readREG2<=readREG2;
		writeREG3<=writeREG3;
		constant<=constant;
		PC<=PC;
	end
	else if(IFflush)
	begin
		CTRL<=4'b1010;
		readREG1<=1'b0;
		readREG2<=1'b0;
		writeREG3<=1'b0;
		constant<=1'b0;
		PC<=1'b0;
	end else
	begin
	CTRL<=INS[20:17];
	readREG1<=INS[16:14];
	readREG2<=INS[13:11];
	writeREG3<=INS[10:8];
	constant<=INS[7:0];
	PC<=nPC;
	end
end

endmodule
