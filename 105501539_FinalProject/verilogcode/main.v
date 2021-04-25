`timescale 1ns / 1ps
//////////////////////////////////////////////
module main(clk);
input clk;





wire [7:0]plus4PC,jumpPC,nextPC,PCout,constant,writeDATA,
				ID_EX_readDATA1,ID_EX_readDATA2,ID_EX_constant,
				ALUin2,ALUout,EX_MEM_readDATA2,memreadDATA,WB_readDATA,
				WB_ALUout,WB_DATA,readDATA1,readDATA2,EX_MEM_constant,EX_MEM_ALUout,
				ALUin1,ALUmux2in,IF_ID_PC;
wire [20:0]INSout;
wire [2:0]readREG1,readREG2,writeREG3,ID_EX_writeREG3,ID_EX_writeREG2,
				EXaluctrl,ID_EX_EXaluctrl,writeREG,EX_MEM_writeREG,WB_writeREG,
				ID_EX_readREG1,ID_EX_readREG2;
wire [3:0]CTRL;
wire WBregwr,WBregomem,MEMwr,EXalusrc,REGdst,ID_EX_WBregwr,ID_EX_WBregomem
		,ID_EX_MEMwr,ID_EX_EXalusrc,WB_regwr,WB_regomem,ID_EX_REGdst,ID_EXE_MEMread,
		PCstall,IF_IDstall,CTRLmux,IFflush,PCsrc,MEMread;
wire [1:0]ALUmux1sel,ALUmux2sel;


PCmux PCmux1(.plus4PC(plus4PC),.jumpPC(jumpPC),.sel(PCsrc),.nextPC(nextPC));
PC PC1(.PCin(nextPC),.PCout(PCout),.clk(clk),.PCstall(PCstall));
PCadder PCadder1(.currentPC(PCout),.plus4PC(plus4PC));
INS INS1(.addrINS(PCout),.INSout(INSout));
IF_ID IF_ID1(.nPC(plus4PC),.INS(INSout),.clk(clk),
	.readREG1(readREG1),.readREG2(readREG2),.constant(constant),
	.writeREG3(writeREG3),.CTRL(CTRL),.IFstall(IF_IDstall),.IFflush(IFflush),.PC(IF_ID_PC));




HDU HDU1(.ID_EX_writeREG2(ID_EX_writeREG2),.ID_EXE_MEMread(ID_EXE_MEMread),
	.readREG1(readREG1),.readREG2(readREG2),.PCstall(PCstall),
	.IF_IDstall(IF_IDstall),.CTRLmux(CTRLmux));	
CONTROL CONTROL1(.CTRL(CTRL),.WBregwr(WBregwr),.WBregomem(WBregomem),
	.MEMwr(MEMwr),.EXalusrc(EXalusrc),.EXaluctrl(EXaluctrl),.REGdst(REGdst),
	.IFflush(IFflush),.PCsrc(PCsrc),.CTRLmux(CTRLmux),.MEMread(MEMread),
	.readDATA1(readDATA1),.readDATA2(readDATA2));
BRJMP BRJMP1(.CTRL(CTRL),.IF_ID_PC(IF_ID_PC),.constant(constant),.jumpPC(jumpPC));
REG REG1(.readREG1(readREG1),.readREG2(readREG2),.writeREG(WB_writeREG),
	.writeCTRL(WB_regwr),.writeDATA(WB_DATA),.readDATA1(readDATA1),
	.readDATA2(readDATA2),.clk(clk));
ID_EX ID_EX1(.nWBregwr(WBregwr),.nWBregomem(WBregomem),
	.nMEMwr(MEMwr),.nEXalusrc(EXalusrc),
	.nEXaluctrl(EXaluctrl), .nreadDATA1(readDATA1),.nreadDATA2(readDATA2), 
	.nconstant(constant),.nwriteREG3(writeREG3),.WBregwr(ID_EX_WBregwr),
	.WBregomem(ID_EX_WBregomem),.MEMwr(ID_EX_MEMwr),
	.EXalusrc(ID_EX_EXalusrc),.EXaluctrl(ID_EX_EXaluctrl),
	.readDATA1(ID_EX_readDATA1),.readDATA2(ID_EX_readDATA2),
	.constant(ID_EX_constant),.writeREG3(ID_EX_writeREG3),.clk(clk),
	.nwriteREG2(readREG2),.writeREG2(ID_EX_writeREG2),.REGdst(ID_EX_REGdst),
	.nREGdst(REGdst),.nMEMread(MEMread),.MEMread(ID_EXE_MEMread),
	.nID_EX_readREG1(readREG1),.ID_EX_readREG1(ID_EX_readREG1),
	.nID_EX_readREG2(readREG2),.ID_EX_readREG2(ID_EX_readREG2));





ALUmux ALUmux0(.constantDATA(ID_EX_constant),.regDATA(ALUmux2in),
	.sel(ID_EX_EXalusrc),.ALUin2(ALUin2));
ALUmux2 ALUmux22(.MUXin0(ID_EX_readDATA2),.MUXin1(WB_DATA),.MUXin2(EX_MEM_ALUout),
	.MUX2sel(ALUmux2sel),.ALUin2(ALUmux2in));

ALU ALU1(.ALUin1(ALUin1),.ALUin2(ALUin2),.ALUcontrol(ID_EX_EXaluctrl),
	.ALUout(ALUout));
REGDSTmux REGDSTmux1(.writeREG2(ID_EX_writeREG2),.writeREG3(ID_EX_writeREG3),
	.REGdst(ID_EX_REGdst),.writeREG(writeREG));
	
FU FU1(.ID_EX_readREG1(ID_EX_readREG1), .ID_EX_readREG2(ID_EX_readREG2),
	.MEM_WB_writeREG(WB_writeREG),.EX_MEM_writeREG(EX_MEM_writeREG),
	.EX_MEM_WBregwr(EX_MEM_WBregwr),.MEM_WBregwr(WB_regwr),
	.ALUmux1sel(ALUmux1sel),.ALUmux2sel(ALUmux2sel));
ALUmux1 ALUmux11(.MUXin0(ID_EX_readDATA1),.MUXin1(WB_DATA),.MUXin2(EX_MEM_ALUout),
	.MUX1sel(ALUmux1sel),.ALUin1(ALUin1));

EX_MEM EX_MEM1(.nWBregwr(ID_EX_WBregwr),.nWBregomem(ID_EX_WBregomem),
	.nMEMwr(ID_EX_MEMwr),.nconstant(ID_EX_constant),
	.nwriteREG(writeREG),.nALUout(ALUout),.clk(clk),
	.WBregwr(EX_MEM_WBregwr),.WBregomem(EX_MEM_WBregomem),.MEMwr(EX_MEM_MEMwr),
	.constant(EX_MEM_constant),.writeREG(EX_MEM_writeREG), .ALUout(EX_MEM_ALUout),
	.nreadDATA2(ALUmux2in),.readDATA2(EX_MEM_readDATA2));





MEM MEM1(.addrMEM(EX_MEM_ALUout),.writeCTRL(EX_MEM_MEMwr),
	.writeDATA(EX_MEM_readDATA2),.readDATA(memreadDATA),.clk(clk));
MEM_WB MEM_WB1(.nWBregwr(EX_MEM_WBregwr),.nWBregomem(EX_MEM_WBregomem),
	.nreadDATA(memreadDATA), .nALUout(EX_MEM_ALUout),.nwriteREG(EX_MEM_writeREG),
	.clk(clk),.WBregwr(WB_regwr),.WBregomem(WB_regomem), .readDATA(WB_readDATA),
	.ALUout(WB_ALUout) ,.writeREG(WB_writeREG));
WBmux WBmux1(.memDATA(WB_readDATA),.aluDATA(WB_ALUout),.sel(WB_regomem),
	.writebackDATA(WB_DATA));	
	 


endmodule
