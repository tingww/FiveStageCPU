`timescale 1ns / 1ps
module PCadder(currentPC,plus4PC);
input [7:0]currentPC;
output reg [7:0]plus4PC;
reg [7:0]test;


always@(*)
plus4PC=currentPC+4'd1;

endmodule

