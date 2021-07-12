/*
--VGA Timing
--Horizontal :
--                ______________                 _____________
--               |              |               |
--_______________|  VIDEO       |_______________|  VIDEO (next line)

--___________   _____________________   ______________________
--           |_|                     |_|
--            B <-C-><----D----><-E->
--           <------------A--------->
--The Unit used below are pixels;  
--  B->Sync_cycle                   :H_sync_cycle
--  C->Back_porch                   :hori_back
--  D->Visable Area
--  E->Front porch                  :hori_front
--  A->horizontal line total length :hori_line
--Vertical :
--               ______________                 _____________
--              |              |               |          
--______________|  VIDEO       |_______________|  VIDEO (next frame)
--
--__________   _____________________   ______________________
--          |_|                     |_|
--           P <-Q-><----R----><-S->
--          <-----------O---------->
--The Unit used below are horizontal lines;  
--  P->Sync_cycle                   :V_sync_cycle
--  Q->Back_porch                   :vert_back
--  R->Visable Area
--  S->Front porch                  :vert_front
--  O->vertical line total length :vert_line
*/

module vsg
(
	input wire rst,
	input wire clk,
	output reg blank_n,
	output reg hs,
	output reg vs
);
	// 640x480 visible resolution
	parameter hori_line    = 800;                           
	parameter hori_back    = 144;
	parameter hori_front   = 16;
	parameter vert_line    = 525;
	parameter vert_back    = 34;
	parameter vert_front   = 11;
	parameter H_sync_cycle = 96;
	parameter V_sync_cycle = 2;

	reg  [10:0] h_cnt;
	reg  [9:0]  v_cnt;
	wire        c_hd, c_vd, c_blank_n;
	wire        h_valid, v_valid;

	always @ (negedge clk, posedge rst) begin
		if (rst) begin
			h_cnt <= 0;
			v_cnt <= 0;
		end
		else begin
			if (h_cnt == hori_line - 1) begin 
				h_cnt <= 0;
				if (v_cnt == vert_line - 1)
					v_cnt <= 0;
				else
					v_cnt <= v_cnt + 1;
			end
			else
				h_cnt <= h_cnt + 1;
		end
	end

	assign c_hd = (h_cnt < H_sync_cycle) ? 0 : 1;
	assign c_vd = (v_cnt < V_sync_cycle) ? 0 : 1;

	assign h_valid = (h_cnt < (hori_line-hori_front) && h_cnt >= hori_back) ? 1 : 0;
	assign v_valid = (v_cnt < (vert_line-vert_front) && v_cnt >= vert_back) ? 1 : 0;

	assign c_blank_n = h_valid && v_valid;

	always @ (negedge clk) begin
		hs <= c_hd;
		vs <= c_vd;
		blank_n <= c_blank_n;
	end

endmodule