// output contents of RAM which is 4 bits in word size
module memhex
(
	input wire            clk,
	output wire [8*7-1:0] hex
);

	wire [3:0] o1, o2, o3, o4, o5, o6, o7, o8;

	ram r1(0, clk, 0, 1'b0, o1);
	ram r2(1, clk, 0, 1'b0, o2);
	ram r3(2, clk, 0, 1'b0, o3);
	ram r4(3, clk, 0, 1'b0, o4);
	ram r5(4, clk, 0, 1'b0, o5);
	ram r6(5, clk, 0, 1'b0, o6);
	ram r7(6, clk, 0, 1'b0, o7);
	ram r8(7, clk, 0, 1'b0, o8);

	hexdigit d1(o1, hex[7*1-1:7*0]);
	hexdigit d2(o2, hex[7*2-1:7*1]);
	hexdigit d3(o3, hex[7*3-1:7*2]);
	hexdigit d4(o4, hex[7*4-1:7*3]);
	hexdigit d5(o5, hex[7*5-1:7*4]);
	hexdigit d6(o6, hex[7*6-1:7*5]);
	hexdigit d7(o7, hex[7*7-1:7*6]);
	hexdigit d8(o8, hex[7*8-1:7*7]);

endmodule
