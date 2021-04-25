`timescale 1ns / 1ps
module MEM(addrMEM,writeCTRL,writeDATA,readDATA,clk);
input [7:0]addrMEM,writeDATA;
input writeCTRL,clk;
output [7:0]readDATA;
reg [7:0]mem[255:0];
integer i;
initial 
begin
	for(i=0;i<=255;i=i+1)
		mem[i]=8'b0;
		
	mem[32]=8'hFF;
end

assign readDATA=mem[addrMEM];

always@(negedge clk)
if(writeCTRL) mem[addrMEM]<= writeDATA;

endmodule

