`timescale 1ns / 1ps
module BRJMP(CTRL,IF_ID_PC,constant,jumpPC);
input [3:0]CTRL;
input [7:0]IF_ID_PC,constant;
output reg [7:0]jumpPC;

always@(*)
begin
	if(CTRL==4'b1001)
	jumpPC=constant;
	else
	jumpPC=IF_ID_PC+constant;
end

endmodule

