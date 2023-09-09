module counter
(
	input            clock,
	input            reset,
	output reg [3:0] count
);
	always @(posedge clock)
	begin
		if (reset == 1'b1)
			count <= #1 4'b0000;
		else
			count <= #1 count + 1;
	end

endmodule

module test_counter();
	reg        clock, reset;
	wire [3:0] count;

	initial begin
		clock = 1;
		reset = 1;
		#5 reset = 0;
		#1000 $finish;
	end
	
	always begin
		#5 clock = ~clock;
	end
	
	counter cnt(
		clock, 
		reset, 
		count
	);
endmodule

