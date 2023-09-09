// based on https://people.ece.cornell.edu/land/courses/ece5760/DE2/indexVGA.html
// read sram or switch and output color to screen
module vgaram
(
	input wire        clk50,

	input wire [3:0]  key,
	input wire [17:0] sw,
	
	inout wire [15:0]  sram_dq,
	output wire [19:0] sram_addr,
	output wire        sram_ub_n,
	output wire        sram_lb_n,
	output wire        sram_we_n,
	output wire        sram_ce_n,
	output wire        sram_oe_n,

	output wire       vga_clk,
	output wire       vga_hs,
	output wire       vga_vs,
	output wire       vga_blank,
	output wire       vga_sync,
	output wire [7:0] vga_r,
	output wire [7:0] vga_g,
	output wire [7:0] vga_b
);	
	wire       rst;
	wire       vga_ctrl_clk;
	wire [7:0] r, g, b;
	wire [9:0] x, y;

	assign sram_addr = {x[9:0], y[9:0]};
	// hi byte select enabled
	assign sram_ub_n = 0;
	// low byte select enabled
	assign sram_lb_n = 0;
	// chip enable
	assign sram_ce_n = 0;
	// output enable is overriden by WE
	assign sram_oe_n = 0;
	// if key 1 is not pressed then float, otherwise
	// drive it with data from sw to be stored in SRAM
	assign sram_we_n = {key[0] ? 1 : 0};
	assign sram_dq = (key[0] ? 16'hzzzz :
    					  (key[1] ? {x[8:5], y[8:5] & ~{4{x[9]}}, y[8:5] & {4{x[9]}}, 4'b0} :
         							sw[15:0]));
	
	// assign color based on contents of sram
	assign r = {sram_dq[15:12], 4'b0};
	assign g = {sram_dq[11:8], 4'b0};
	assign b = {sram_dq[7:4], 4'b0};
	
	// delay a little before resetting the device for board to power up
	reset_delay r0(
		.clk(clk50),
		.rst(rst)
	);
	
	// vga needs ~25 mhz for 640x480 at 60 hz
	// c0 is the rate at which we update the vga signals at
	// c1 is a phase delay of 90 degree which we output to the vga clock
	// meaning vga clock gets clocked and updated a little later than we
	// update the internal vga signals like sync rgb data
	pll p0(
		.areset(~rst),
		.inclk0(clk50),
		.c0(vga_ctrl_clk),
		.c1(vga_clk)
	);

	// vga controller that gets color from r, g, b
	vga v0(
		.clk(vga_ctrl_clk), 
		.rst(rst),
		.r(r),
		.g(g),
		.b(b),
		.x(x),
		.y(y),
		.vga_hs(vga_hs),
		.vga_vs(vga_vs),
		.vga_blank(vga_blank),
		.vga_sync(vga_sync),
		.vga_r(vga_r),
		.vga_g(vga_g),
		.vga_b(vga_b)
	);
endmodule
