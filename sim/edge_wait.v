module G();
	reg enable, clock;
endmodule

module edge_wait
(
	output reg [1:0] trigger
);
	always @ (posedge G.enable)
	begin
		trigger <= 0;
		repeat (2) begin
			@ (posedge G.clock);
		end	
		trigger <= 1;
	end

endmodule

module edge_wait_test();
	wire [1:0] trigger;
	
	initial begin
		$monitor("TIME : %d CLK : %b ENABLE : %b TRIGGER : %b",
					$time, G.clock, G.enable, trigger);
		G.clock = 0;
		G.enable = 0;

		#5  G.enable = 1;
		#10 G.enable = 0;
		#15 G.enable = 1;
		#20 G.enable = 0;
		#25 G.enable = 1;
		#30 G.enable = 0;
		#35 $finish;
	end
	
	always begin
		#1 G.clock = ~G.clock;
	end
	
	edge_wait ew(trigger);
endmodule
