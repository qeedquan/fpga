module lcd
(
	input wire       clk,
	output reg [4:0] ctl,
	output reg [7:0] data
);
	localparam RW   = 0;
	localparam RS   = 1;
	localparam ON   = 2;
	localparam EN   = 3;
	localparam BLON = 4;

	localparam INITIAL = 0;
	localparam LINE1   = 5;
	localparam CHLINE  = LINE1 + 16;
	localparam LINE2   = CHLINE + 1;
	localparam SIZE    = LINE2 + 16;

	reg [8:0]  chr[SIZE];
	reg [63:0] cnt;
	integer    pos, state, i;
	
	initial begin
		for (i = 0; i < SIZE; i = i + 1)
			chr[i] = 9'h141 - LINE1 + i;
		chr[CHLINE] = 9'h0C0;
		chr[INITIAL+0] = 9'h038;
		chr[INITIAL+1] = 9'h00C;
		chr[INITIAL+2] = 9'h001;
		chr[INITIAL+3] = 9'h006;
		chr[INITIAL+4] = 9'h080;

		cnt <= 0;
		pos <= 0;
		state <= 0;
	end
	
	always @* begin
		ctl[RW] <= 0;
		ctl[ON] <= 1;
		ctl[BLON] <= 1;
	end
	
	always @ (posedge clk) begin
		if (pos < SIZE) begin
			case (state)
				0: begin
					ctl[EN] <= 1;
					ctl[RS] <= chr[pos][8];
					data <= chr[pos][7:0];
					cnt <= 0;
					state <= 1;
				end

				1: begin
					if (cnt < 16)
						cnt <= cnt + 1;
					else begin
						ctl[EN] <= 0;
						cnt <= 0;
						state <= 2;
					end
				end
			
				2: begin
					if (cnt < 'h3FFFE)
						cnt <= cnt + 1;
					else begin
						pos <= pos + 1;
						state <= 0;
					end
				end
				
			endcase			
		end
	end

endmodule
