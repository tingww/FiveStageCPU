`timescale 1ns / 1ps
module ALUmux2(MUXin0,MUXin1,MUXin2,MUX2sel,ALUin2);
input [7:0] MUXin0,MUXin1,MUXin2;
input[1:0] MUX2sel;
output reg [7:0]ALUin2;

always@(*)
begin
	case(MUX2sel)
	2'b00:ALUin2=MUXin0;
	2'b01:ALUin2=MUXin1;
	2'b10:ALUin2=MUXin2;
	default:ALUin2=MUXin0;
	endcase
end

endmodule
