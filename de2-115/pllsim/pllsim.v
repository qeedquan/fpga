module pllsim
(
	input wire rst,
	input wire clk
);
	wire c0, c1, c2, c3, c4;

	atpll a(rst, clk, c0, c1, c2, c3, c4);
endmodule

`timescale 1ns/1ns
module pllsim_test();
	reg clk, rst;
	
	initial begin
		clk = 0;
		rst = 1;
	end
	
	always begin
		#10 clk = ~clk;
		    rst = 0;
	end
	
	pllsim p(rst, clk);
endmodule