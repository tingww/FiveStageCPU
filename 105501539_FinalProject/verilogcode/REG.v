`timescale 1ns / 1ps
module REG(readREG1,readREG2,writeREG,writeCTRL,writeDATA,readDATA1,readDATA2,clk);
input [2:0]readREG1,readREG2,writeREG;
input [7:0]writeDATA;
input clk,writeCTRL;
output [7:0]readDATA1,readDATA2;
reg [7:0]regi[7:0];
integer i;
initial 
begin 
	for(i=0;i<=7;i=i+1)
		regi[i]=8'b0;
end

assign readDATA1=regi[readREG1],
		 readDATA2=regi[readREG2];

always@(negedge clk)
if(writeCTRL) regi[writeREG]<=writeDATA;

endmodule

