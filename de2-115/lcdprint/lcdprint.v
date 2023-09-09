// print me the alphabet soup!
module lcdprint
(
	input wire        clk,
	output wire [4:0] lcdctl,
	output wire [7:0] lcddata
);
	lcd l(clk, lcdctl, lcddata);
endmodule
