module vga
(
	input wire         rst,
	input wire         clk,
	output reg         blank_n,
	output reg         hs,
	output reg         sync_n,
	output reg         vs,
	output wire [23:0] rgb
);
	reg [31:0] x, y;
	wire       l_hs, l_vs, l_blank_n;

	always @ (posedge clk, negedge rst) begin
		if (!rst) begin
			x <= 0;
			y <= 0;
		end
		else if (l_hs == 0 && l_vs == 0) begin
			x <= 0;
			y <= 0;
		end
		else if (l_blank_n == 1) begin
			x = x + 1;
			if (x == 640) begin
				x = 0;
				y = y + 1;
			end
		end
	end
		
	always @ (negedge clk) begin
		hs <= l_hs;
		vs <= l_vs;
		blank_n <= l_blank_n;
	end
	
	assign rgb = (x^y)<<16 | (x+y)<<8;
	
	vsg vg(~rst, clk, l_blank_n, l_hs, l_vs);

endmodule