`timescale 1ns / 1ps
module INS(addrINS,INSout);
input [7:0]addrINS;
output reg [20:0 ]INSout;
reg [20:0]INSmemory[255:0];
integer i;

initial
begin

	for (i=0;i<=255;i=i+1)
		INSmemory[i]=21'b1_0100_0000_0000_0000_0000;
		
		
		
	INSmemory[0]=21'b1_0100_0000_0000_0000_0000;
	INSmemory[5]=21'b0011_001_000_001_0000_0001;
	INSmemory[6]=21'b0011_001_000_010_0000_0101;
	INSmemory[7]=21'b0111_001_010_011_0000_0000;
	INSmemory[8]=21'b0001_010_010_000_0000_0000;
	INSmemory[9]=21'b0100_010_001_010_0000_0000;
	INSmemory[10]=21'b1000_001_011_000_1111_1100;
	INSmemory[11]=21'b0011_010_000_010_0000_0010;
	INSmemory[12]=21'b0000_010_100_000_0000_0011;
	INSmemory[13]=21'b0101_100_010_101_0000_0000;
	INSmemory[14]=21'b0110_010_100_110_0000_0000;
	INSmemory[15]=21'b1001_000_000_000_0000_1011;
	
end

always@(*)
INSout=INSmemory[addrINS];

endmodule
