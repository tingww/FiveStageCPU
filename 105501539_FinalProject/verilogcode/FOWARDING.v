`timescale 1ns / 1ps
module FU(ID_EX_readREG1, ID_EX_readREG2,MEM_WB_writeREG,EX_MEM_writeREG,
EX_MEM_WBregwr,MEM_WBregwr,ALUmux1sel,ALUmux2sel);
input [2:0] ID_EX_readREG1, ID_EX_readREG2, EX_MEM_writeREG, MEM_WB_writeREG;
input EX_MEM_WBregwr,MEM_WBregwr;
output reg [1:0] ALUmux1sel,ALUmux2sel;

always@(*)
begin
	if(EX_MEM_WBregwr && (EX_MEM_writeREG==ID_EX_readREG1) && (EX_MEM_writeREG!=0))
	ALUmux1sel=2'b10;
	else if(MEM_WBregwr && (MEM_WB_writeREG==ID_EX_readREG1) && (MEM_WB_writeREG!=0))
	ALUmux1sel=2'b01;
	else
	ALUmux1sel=2'b00;
	
	
	if(EX_MEM_WBregwr && (EX_MEM_writeREG==ID_EX_readREG2) && (EX_MEM_writeREG!=0))
	ALUmux2sel=2'b10;
	else if(MEM_WBregwr && (MEM_WB_writeREG==ID_EX_readREG2) && (MEM_WB_writeREG!=0))
	ALUmux2sel=2'b01;
	else
	ALUmux2sel=2'b00;
end


endmodule
