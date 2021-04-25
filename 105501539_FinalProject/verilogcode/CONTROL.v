`timescale 1ns / 1ps
module CONTROL(CTRL,WBregwr,WBregomem,MEMwr,EXalusrc,EXaluctrl,REGdst,MEMread,
	readDATA1,readDATA2,IFflush,PCsrc,CTRLmux);
input [3:0]CTRL;
output reg WBregwr,WBregomem,MEMwr,EXalusrc,REGdst,MEMread;
output reg [2:0]EXaluctrl;
input [7:0]readDATA1,readDATA2;
output reg IFflush,PCsrc;
input CTRLmux;



always@(*)
begin
	if(CTRLmux==1'b1)
	begin IFflush=1'b0; PCsrc=1'b0;WBregwr=1'b0;WBregomem=1'b0;MEMwr=1'b0;EXalusrc=1'b0;EXaluctrl=3'd0;MEMread=1'b0;REGdst=1'b0;end
	else begin
		case (CTRL)
		4'd0:begin IFflush=1'b0; PCsrc=1'b0;WBregwr=1'b1;WBregomem=1'b0;MEMwr=1'b0;EXalusrc=1'b1;EXaluctrl=3'd0;REGdst=1'b0;MEMread=1'b1; end
		4'd1:begin IFflush=1'b0; PCsrc=1'b0;WBregwr=1'b0;WBregomem=1'b1;MEMwr=1'b1;EXalusrc=1'b1;EXaluctrl=3'd0;REGdst=1'b0;MEMread=1'b0; end
		4'd2:begin IFflush=1'b0; PCsrc=1'b0;WBregwr=1'b1;WBregomem=1'b1;MEMwr=1'b0;EXalusrc=1'b0;EXaluctrl=3'd0;REGdst=1'b1;MEMread=1'b0; end
		4'd3:begin IFflush=1'b0; PCsrc=1'b0;WBregwr=1'b1;WBregomem=1'b1;MEMwr=1'b0;EXalusrc=1'b1;EXaluctrl=3'd0;REGdst=1'b1;MEMread=1'b0; end
		4'd4:begin IFflush=1'b0; PCsrc=1'b0;WBregwr=1'b1;WBregomem=1'b1;MEMwr=1'b0;EXalusrc=1'b0;EXaluctrl=3'd1;REGdst=1'b1;MEMread=1'b0; end
		4'd5:begin IFflush=1'b0; PCsrc=1'b0;WBregwr=1'b1;WBregomem=1'b1;MEMwr=1'b0;EXalusrc=1'b0;EXaluctrl=3'd2;REGdst=1'b1;MEMread=1'b0; end
		4'd6:begin IFflush=1'b0; PCsrc=1'b0;WBregwr=1'b1;WBregomem=1'b1;MEMwr=1'b0;EXalusrc=1'b0;EXaluctrl=3'd3;REGdst=1'b1;MEMread=1'b0; end
		4'd7:begin IFflush=1'b0; PCsrc=1'b0;WBregwr=1'b1;WBregomem=1'b1;MEMwr=1'b0;EXalusrc=1'b0;EXaluctrl=3'd4;REGdst=1'b1;MEMread=1'b0; end
		4'd8:begin
				if(readDATA1==readDATA2) 
				begin IFflush=1'b1; PCsrc=1'b1; end
				else
				begin IFflush=1'b0; PCsrc=1'b0; end
				
				WBregwr=1'b0;WBregomem=1'b0;MEMwr=1'b0;EXalusrc=1'b0;EXaluctrl=3'd0;REGdst=1'b0;MEMread=1'b0; end
		4'd9:begin IFflush=1'b1; PCsrc=1'b1;WBregwr=1'b0;WBregomem=1'b0;MEMwr=1'b0;EXalusrc=1'b0;EXaluctrl=3'd0;REGdst=1'b0;MEMread=1'b0; end
		default:begin IFflush=1'b0; PCsrc=1'b0;WBregwr=1'b0;WBregomem=1'b0;MEMwr=1'b0;EXalusrc=1'b0;EXaluctrl=3'd0;MEMread=1'b0;REGdst=1'b0;end
		endcase
	end
end


endmodule

