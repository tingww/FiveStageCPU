`timescale 1ns / 1ps
module ALUmux1(MUXin0,MUXin1,MUXin2,MUX1sel,ALUin1);
input [7:0] MUXin0,MUXin1,MUXin2;
input[1:0] MUX1sel;
output reg [7:0]ALUin1;

always@(*)
begin
	case(MUX1sel)
	2'b00:ALUin1=MUXin0;
	2'b01:ALUin1=MUXin1;
	2'b10:ALUin1=MUXin2;
	default:ALUin1=MUXin0;
	endcase
end

endmodule
