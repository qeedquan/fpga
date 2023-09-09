`timescale 1ns/1ps

module testbench;
	reg clk;
	reg rst;
	
	reg  [31:0] x;
	wire [31:0] y;
	wire        valid;

	initial begin
		clk = 0;
		forever clk = #1 ~clk;
	end
	
	initial begin
		rst = 1;
		#100 rst = 0;
	end
	
	always @(posedge clk)
	begin
		if (rst == 1)
			x <= 0;
		else
			x <= x + 1;
	end
	
	cordic_0 sqrt(
		.s_axis_cartesian_tdata(x),
		.s_axis_cartesian_tvalid(~rst),
		.m_axis_dout_tdata(y),
		.m_axis_dout_tvalid(valid)
	);
endmodule
