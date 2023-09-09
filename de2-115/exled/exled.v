// blink external led using GPIO
// we only use GND pin and gpio[1] pin
// but assign all gpio for no reason
module exled
(
	input wire         clk50,
	output wire [35:0] gpio
);
	localparam FREQ = 50_000_000;

	reg [31:0] cnt;
	reg [35:0] tog;

	initial begin
		cnt <= 0;
		tog <= 0;
	end
	
	always @ (posedge clk50) begin
		if (cnt == FREQ) begin
			cnt <= 0;
			tog <= ~tog;
		end
		else
			cnt <= cnt + 1;
	end

	assign gpio = tog;
endmodule