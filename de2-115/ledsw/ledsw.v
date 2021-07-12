// 18 switches on the board, wire it to the 18 red leds
// it turns on based on the switch position
module ledsw
(
    input  wire [17:0] sw,
    output reg  [17:0] ledr
);
	generate
		genvar i;
		for (i = 0; i <= 17; i=i+1)
		begin: loop
			always @* begin
				ledr[i] <= sw[i];
			end
		end
	endgenerate
	 
endmodule
