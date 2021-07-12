// debounce debounces signals to prevent oscillation by providing
// a hold time threshold such that if the signal oscillates too quickly
// it will get ignored, the signal has to be stable before the debouncer
// will allow it to transition to a new level
module debounce
(
	input wire  clk,
	input wire  sw,
	output reg  db_level,
	output reg  db_tick
);
	localparam N = 21; // filter of 2^N * 20ns = 40ms
	
	localparam ZERO  = 0;
	localparam WAIT1 = 1;
	localparam ONE   = 2;
	localparam WAIT0 = 3;
	
	reg [1:0]   state_reg, state_next;
	reg [N-1:0] q_reg, q_next;
	
	always @ (posedge clk) begin
		state_reg <= state_next;
		q_reg <= q_next;
	end
	
	// state machine outputs level and edge trigger changes
	// it outputs the same level as long as the input signal
	// changes too quickly or not changing at all. If it changes
	// to quickly, it will fail the threshold value for the counter
	// and get resetted back to the original level state that it
	// was in.
	always @ (state_reg, q_reg, sw, q_next) begin
		state_next <= state_reg;
		q_next <= q_reg;
		db_tick <= 0;
		
		case (state_reg)
			ZERO: begin
				db_level <= 0;
				if (sw) begin
					state_next <= WAIT1;
					q_next <= ~0;
				end
			end
			
			WAIT1: begin
				db_level <= 0;
				if (sw) begin
					q_next <= q_reg - 1;
					if (q_next == 0) begin
						state_next <= ONE;
						db_tick <= 1;
					end
				end
				else
					state_next <= ZERO;
			end
			
			ONE: begin
				db_level <= 1;
				if (!sw) begin
					state_next <= WAIT0;
					q_next <= ~0;
				end
			end
			
			WAIT0: begin
				db_level <= 1;
				if (!sw) begin
					q_next <= q_reg - 1;
					if (q_next == 0)
						state_next <= ZERO;
				end
				else
					state_next <= ONE;
			end
		endcase
	end
	
endmodule