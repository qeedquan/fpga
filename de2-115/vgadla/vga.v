module vga
(
	input wire        clk,
	input wire        rst,
	input wire  [7:0] r,
	input wire  [7:0] g,
	input wire  [7:0] b,
	output reg  [9:0] x,
	output reg  [9:0] y,
	output wire [7:0] vga_r,
	output wire [7:0] vga_g,
	output wire [7:0] vga_b,
	output reg        vga_hs,
	output reg        vga_vs,
	output wire       vga_sync,
	output wire       vga_blank
);
	//	Horizontal Parameter	( Pixel )
	parameter	H_SYNC_CYC	 = 96;
	parameter	H_SYNC_BACK	 = 45+3;
	parameter	H_SYNC_ACT	 = 640;	//	640
	parameter	H_SYNC_FRONT = 13+3;
	parameter	H_SYNC_TOTAL = 800;
	
	//	Vertical Parameter		( Line )
	parameter	V_SYNC_CYC	 = 2;
	parameter	V_SYNC_BACK	 = 30+2;
	parameter	V_SYNC_ACT	 = 480;	//	484
	parameter	V_SYNC_FRONT = 9+2;
	parameter	V_SYNC_TOTAL = 525;
	
	//	Start Offset
	parameter	X_START = H_SYNC_CYC+H_SYNC_BACK+4;
	parameter	Y_START = V_SYNC_CYC+V_SYNC_BACK;

	reg [9:0] h_cnt;
	reg [9:0] v_cnt;
	
	assign vga_blank = vga_hs && vga_vs;
	assign vga_sync = 0;
	
	assign vga_r = (h_cnt >= X_START+9 && h_cnt < X_START+H_SYNC_ACT+9 &&
						 v_cnt >= Y_START   && v_cnt < Y_START+V_SYNC_ACT)
						 ? r : 0;
	assign vga_g = (h_cnt >= X_START+9 && h_cnt < X_START+H_SYNC_ACT+9 &&
						 v_cnt >= Y_START   && v_cnt < Y_START+V_SYNC_ACT)
						 ?	g : 0;
	assign vga_b = (h_cnt >= X_START+9 && h_cnt < X_START+H_SYNC_ACT+9 &&
						 v_cnt >=Y_START    && v_cnt < Y_START+V_SYNC_ACT)
						 ?	b : 0;
	
	// pixel address
	always @ (posedge clk or negedge rst) begin
		if (!rst) begin
			x <= 0;
			y <= 0;
		end
		else begin
			if (h_cnt >= X_START && h_cnt < X_START+H_SYNC_ACT && 
				v_cnt >= Y_START && v_cnt < Y_START+V_SYNC_ACT) begin
				x <= h_cnt - X_START;
				y <= v_cnt - Y_START;
			end
		end
	end
	
	// hsync
	always @ (posedge clk or negedge rst) begin
		if (!rst) begin
			h_cnt <= 0;
			vga_hs <= 0;
		end
		else begin
			if (h_cnt < H_SYNC_TOTAL)
				h_cnt <= h_cnt + 1;
			else
				h_cnt <= 0;
			
			if (h_cnt < H_SYNC_CYC)
				vga_hs <= 0;
			else
				vga_hs <= 1;
		end
	end
	
	// vsync
	always @ (posedge clk or negedge rst) begin
		if (!rst) begin
			v_cnt <= 0;
			vga_vs <= 0;
		end
		else begin
			if (h_cnt == 0) begin
				if (v_cnt < V_SYNC_TOTAL)
					v_cnt <= v_cnt + 1;
				else
					v_cnt <= 0;

				if (v_cnt < V_SYNC_CYC)
					vga_vs <= 0;
				else
					vga_vs <= 1;
			end
		end
	end
	
endmodule
