module vgaxor
(
	input         clk50,
	output        vga_clk,
	output        vga_blank_n,
	output        vga_hs,
	output        vga_sync_n,
	output        vga_vs,
	output [23:0] vga_rgb
);
	wire rst, clk25;

	reset_delay rd(clk50, rst);

	pll pl(~rst, clk50, clk25);

	assign vga_clk = clk25;
	vga vg(rst, clk25, vga_blank_n, vga_hs, 
				vga_sync_n, vga_vs, vga_rgb);

endmodule