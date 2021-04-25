`timescale 1ns / 1ps
module ALUmux(constantDATA,regDATA,sel,ALUin2);
input [7:0]constantDATA,regDATA;
input sel;
output reg [7:0]ALUin2;

always@(*)
begin
	if(sel) ALUin2=constantDATA;
	else ALUin2=regDATA;
end

endmodule

