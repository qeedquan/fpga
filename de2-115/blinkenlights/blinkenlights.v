// blink LED lights based on a clock running at fixed
// frequency per second
module blinkenlights
(
	input         clk,
	output [17:0] ledr,
	output [7:0]  ledg
);
	parameter CLK_FREQ   = 50_000_000;
	parameter BLINK_FREQ = 1;
	parameter CNT_MAX    = CLK_FREQ/BLINK_FREQ/2 - 1;

	reg [31:0] cnt;
	reg        blink;

	always @ (posedge clk)
	begin
		if (cnt == CNT_MAX)
		begin
			cnt <= 0;
			blink <= !blink;
		end
		else
			cnt <= cnt + 1;
	end
	
	generate
		genvar i;
		for (i = 0; i <= 17; i = i+1)
		begin : ledr_loop
			assign ledr[i] = blink;
		end
		for (i = 0; i <= 7; i = i+1)
		begin : ledg_loop
			assign ledg[i] = !blink;
		end
	endgenerate

endmodule
