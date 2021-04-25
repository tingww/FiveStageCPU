`timescale 1ns / 1ps
module PC(PCin,PCout,clk,PCstall);
input  [7:0]PCin;
input clk,PCstall;
output reg [7:0]PCout;

initial PCout=8'b0;

always@(posedge clk )
begin
	if(PCstall)
	PCout<=PCout;
	else
	PCout<=PCin;
end
endmodule

