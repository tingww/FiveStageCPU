`timescale 1ns / 1ps
module PCmux(plus4PC,jumpPC,sel,nextPC);
input [7:0]plus4PC,jumpPC;
input sel;
output reg [7:0]nextPC;

always@(*)begin
	if(sel) nextPC=jumpPC;
	else nextPC=plus4PC;
end

endmodule
