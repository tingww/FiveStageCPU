`timescale 1ns / 1ps

module WBmux(memDATA,aluDATA,sel,writebackDATA);
input [7:0]memDATA,aluDATA;
input sel;
output reg [7:0]writebackDATA;

always@(*)
begin
	if(sel) writebackDATA=aluDATA;
	else writebackDATA=memDATA;
end
endmodule

