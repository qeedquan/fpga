module mod_m_counter
(
	input wire          clk,
	input wire          reset,
	output wire         max_tick,
	output wire [N-1:0] q
);
	parameter N = 4;  // number of bits
	parameter M = 10; // mod-M
	
	reg [N-1:0]  r_reg;
	wire [N-1:0] r_next;
	
	always @ (posedge clk, posedge reset) begin
		if (reset)
			r_reg <= 0;
		else
			r_reg <= r_next;
	end
	
	assign r_next = (r_reg == M-1) ? 0 : r_reg + 1;
	assign q = r_reg;
	assign max_tick = (r_reg == M-1) ? 1 : 0;
endmodule
