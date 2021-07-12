// based on https://people.ece.cornell.edu/land/courses/ece5760/DE2/indexVGA.html
// dla simulation
module vgadla
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
	output wire [7:0] vga_b,
	
	output wire [8:0]  ledg,
	output wire [17:0] ledr
);	
	localparam INIT   = 0;
	localparam TEST1  = 1;
	localparam TEST2  = 2;
	localparam TEST3  = 3;
	localparam TEST4  = 4;
	localparam TEST5  = 5;
	localparam TEST6  = 6;
	localparam DRAW   = 7;
	localparam UPDATE = 8;
	localparam NEW    = 9;

	localparam FG = 16'hffff;

	wire       init;
	wire       rst;
	wire       vga_ctrl_clk;
	wire [7:0] r, g, b;
	wire [9:0] x, y;
	wire       xl, yl;
	reg [9:0]  xw, yw;
	reg [30:0] xr;
	reg [28:0] yr;
	reg [19:0] addr;
	reg [15:0] data;
	reg [3:0]  state;
	reg [3:0]  sum;
	reg [8:0]  ledg_;
	reg [17:0] ledr_;
	reg        lock;
	reg        we;

	assign sram_addr = addr;
	// hi byte select enabled
	assign sram_ub_n = 0;
	// low byte select enabled
	assign sram_lb_n = 0;
	// chip enable
	assign sram_ce_n = 0;
	// output enable is overriden by WE
	assign sram_oe_n = 0;
	assign sram_we_n = we;
	assign sram_dq = (we) ? 16'hzzzz : data;
	
	// assign color based on contents of sram
	assign r = {sram_dq[15:12], 4'b0};
	assign g = {sram_dq[11:8], 4'b0};
	assign b = {sram_dq[7:4], 4'b0};
	
	assign xl = xr[27] ^ xr[30];
	assign yl = yr[26] ^ yr[28];
	
	assign init = ~key[0];
	
	assign ledg = ledg_;
	assign ledr = ledr_;
	
	always @ (posedge vga_ctrl_clk) begin
		if (init) begin
			addr <= {x, y};
			we <= 1'b0;
			data <= 16'b0;
			xr <= 31'h55555555;
			yr <= 29'h55555555;
			xw <= 10'd155;
			yw <= 10'd120;
			state <= INIT;
		end
		else if ((~vga_vs | ~vga_hs) & key[1]) begin
			case (state)
				// white dot at center of screen
				INIT: begin
					addr <= {10'd160,10'd120};
					we <= 1'b0;
					data <= FG;
					state <= TEST1;
				end
				
				// read left neighbor
				TEST1: begin
					lock <= 1'b1;
					sum <= 0;
					we <= 1'b1;
					addr <= {xw - 10'd1, yw};
					state <= TEST2;
				end
				
				// check left and read right neighbor
				TEST2: begin
					we <= 1'b1;
					sum <= sum + {3'b0, sram_dq[15]};
					addr <= {xw + 10'd1, yw};
					state <= TEST3;
				end
				
				// check right and read top neighbor
				TEST3: begin
					we <= 1'b1; 
					sum <= sum + {3'b0, sram_dq[15]};
					addr <= {xw, yw - 10'd1};
					state <= TEST4;
				end
				
				// check top and read bottom neighbor
				TEST4: begin
					we <= 1'b1;
					sum <= sum + {3'b0, sram_dq[15]};
					addr <= {xw, yw + 10'd1};
					state <= TEST5;
				end

				// read bottom neighbor
				TEST5: begin
					we <= 1'b1; 
					sum <= sum + {3'b0, sram_dq[15]};
					state <= TEST6;
				end
				
				// if there is a neighbor draw, otherwise
				// just update
				TEST6: begin
					if (lock & sum > 0) begin
						ledr_ <= {4'b0, xw[9:0], sum[3:0]};
						ledg_ <= {yw[8:0]};
						state <= DRAW;
					end
					else begin
						ledr_ <= 18'b0;
						ledg_ <= 9'b0;
						state <= UPDATE; 
					end
				end
				
				// draw white dot at that location
				DRAW: begin
					we <= 1'b0;
					addr <= {xw, yw};
					data <= FG;
					state <= NEW;
				end
				
				// update walker and random
				UPDATE: begin
					we <= 1'b1;
					if (xw < 10'd318 & xr[30] == 1)
						xw <= xw + 1;
					else if (xw > 10'd2 & xr[30] == 0)
						xw <= xw - 1;
					
					if (yw < 10'd237 & yr[28] == 1)
						yw <= yw + 1;
					else if (yw > 10'd2 & yr[28] == 0)
						yw <= yw - 1;

					xr <= {xr[29:0], xl} ;
					yr <= {yr[27:0], yl} ;
					state <= TEST1;
				end
				
				// begin a new phase
				// init random walker
				// and update random value
				NEW: begin
					we <= 1'b1;
					if (xr[30])
						xw <= 10'd318;
					else
						xw <= 10'd2;

					if (yr[28])
						yw <= 10'd238;
					else
						yw <= 10'd2;

					xr <= {xr[29:0], xl} ;
					yr <= {yr[27:0], yl} ;
					state <= TEST1;
				end

			endcase
		end
		else begin
			// not drawing lock writes
			// and read from current x and y
			// for color
			lock <= 1'b0;
			addr <= {x, y};
			we <= 1'b1;
		end
	end
	
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

`timescale 1ns/1ns
module vgadla_test();
	reg        clk50;
	reg [3:0]  key;
	reg [17:0] sw;
	
	wire [15:0]  sram_dq;
	wire [19:0]  sram_addr;
	wire         sram_ub_n;
	wire         sram_lb_n;
	wire         sram_we_n;
	wire         sram_ce_n;
	wire         sram_oe_n;
	
	wire       vga_clk;
	wire       vga_hs;
	wire       vga_vs;
	wire       vga_blank;
	wire       vga_sync;
	wire [7:0] vga_r;
	wire [7:0] vga_g;
	wire [7:0] vga_b;
	
	wire [8:0]  ledg;
	wire [17:0] ledr;
	
	initial begin
		clk50 = 0;
		key = 'hf;
		sw = 0;

		#5     key[0] = 0;
		#12000 key[0] = 1;
	end
	
	always begin
		#20 clk50 = ~clk50;
		$monitor("t %d st %d we %d dq %d da %d s %d xw %d yw %d xr %x yr %x",
			$time, v.state, v.we, v.sram_dq, v.data, v.sum, v.xw, v.yw, v.xr, v.yr);
	end
	
	vgadla v(
		.clk50(clk50),
		.key(key),
		.sw(sw),
		.sram_dq(sram_dq),
		.sram_addr(sram_addr),
		.sram_ub_n(sram_ub_n),
		.sram_lb_n(sram_lb_n),
		.sram_we_n(sram_we_n),
		.sram_ce_n(sram_ce_n),
		.sram_oe_n(sram_oe_n),
		.vga_clk(vga_clk),
		.vga_hs(vga_hs),
		.vga_vs(vga_vs),
		.vga_blank(vga_blank),
		.vga_sync(vga_sync),
		.vga_r(vga_r),
		.vga_g(vga_g),
		.vga_b(vga_b),
		.ledg(ledg),
		.ledr(ledr)
	);
endmodule