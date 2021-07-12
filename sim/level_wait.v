// http://www.asic-world.com/code/verilog_tutorial/wait_example.v
// but fix to work in simulation

module level_wait
(
	output reg [7:0] data
);

	reg mem_read, data_ready;
	reg [7:0] data_bus;

	// wait until any one of the signals become ready
	always @ (mem_read or data_bus or data_ready)
	begin
		data = 0;
		// #1 is very important to avoid infinite loop
		// wait for data_ready, then we set it for a brief instant
		// then the data will become 0 again
		wait (data_ready == 1) #1 data = data_bus;
	end

	initial begin
		$monitor("TIME = %g READ = %b READY = %b DATA = %b", 
					$time, mem_read, data_ready, data);
		data_bus = 0;
		mem_read = 0;
		data_ready = 0;
		#10 data_bus = 8'hDE;
		#10 mem_read = 1;
		#20 data_ready = 1;
		#1  mem_read = 1;
		#1  data_ready = 0;
		#10 data_bus = 8'hAD;
		#10 mem_read = 1;
		#20 data_ready = 1;
		#1  mem_read = 1;
		#1  data_ready = 0;
		#10 $finish;
	end

endmodule

