module reset_delay
(
	input wire  clk,
	output reg  rst
);
	reg [19:0] cnt;
	
	initial begin
		cnt <= 0;
	end
	
	always @ (posedge clk) begin
		if (cnt <= 'hFFFF) begin
			cnt <= cnt + 1;
			rst <= 0;
		end
		else
			rst <= 1;
	end

endmodule