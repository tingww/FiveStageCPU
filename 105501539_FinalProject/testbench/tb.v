`timescale 1ns / 1ps


module tb;

	// Inputs
	reg clk;

	//Instantiate the Unit Under Test (UUT)
	main uut (
		.clk(clk)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
	end

always
	#50 clk=~clk;
      
endmodule

