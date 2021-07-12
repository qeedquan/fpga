module hello_world
(
	input clock
);
	initial begin
		$display("Hello World!");
		#100 $finish;
	end
endmodule

module test_hello_world();
	reg clock;

	initial begin
		clock = 1;
	end

	always begin
		#5 clock = ~clock;
	end

	hello_world test_hello(
		clock
	);
endmodule

