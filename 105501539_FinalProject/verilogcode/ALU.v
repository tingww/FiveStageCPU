`timescale 1ns / 1ps
module ALU(ALUin1,ALUin2,ALUcontrol,ALUout);
input [7:0]ALUin1,ALUin2;
input [2:0]ALUcontrol;
output reg[7:0]ALUout;

always@(*)
begin
	case(ALUcontrol)
	3'd1:ALUout=ALUin1-ALUin2;
	3'd2:ALUout=ALUin1&ALUin2;
	3'd3:ALUout=ALUin1|ALUin2;
	3'd4:begin 
			if((ALUin2-ALUin1)>0) ALUout=8'b1;
			else ALUout=8'b0;
		  end
	default:ALUout=ALUin1+ALUin2;
	endcase
end

endmodule

