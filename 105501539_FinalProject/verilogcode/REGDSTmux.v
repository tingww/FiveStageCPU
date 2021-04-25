`timescale 1ns / 1ps
/////////////////////
module REGDSTmux(writeREG2,writeREG3,REGdst,writeREG);
input [2:0]writeREG2,writeREG3;
input REGdst;
output reg [2:0]writeREG;

always@(*)
begin
	if(REGdst) writeREG=writeREG3;
	else writeREG=writeREG2;
end


endmodule
