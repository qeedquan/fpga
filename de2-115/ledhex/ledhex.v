// board has 8 LED segment for display numbers
// print out the current tick which increments
// every number of second based on the clock
// use 4 button switch for reset and toggle of the
// step value. 18 LEDR is used for displaying the
// current step
`define NSEG  8
`define NLEDR 18

module ledhex
(
	input wire [3:0]         key,
	input wire               clk,
	output reg [`NLEDR-1:0]  ledr,
	output reg [`NSEG*7-1:0] hex
);	
	task clear();
		integer i;
		for (i = 0; i < `NSEG*7; i = i + 1) begin
			hex[i] = 1;
		end
	endtask
	
	task digit(input integer hp, input integer n);
		reg     [7:0] v;
		integer       i;
		
		begin
			case (n)
				0:       v = 7'b1000000;
				1:       v = 7'b1111001;
				2:       v = 7'b0100100;
				3:       v = 7'b0110000;
				4:       v = 7'b0011001;
				5:       v = 7'b0010010;
				6:       v = 7'b0000010;
				7:       v = 7'b1111000;
				8:       v = 7'b0000000;
				9:       v = 7'b0010000;
				default: v = 7'b1111111;
			endcase

			hp = hp*7;
			for (i = 0; i < 7; i = i + 1) begin
				hex[hp+i] = v[i];
			end
		end
	endtask
	
	task print(input integer n);
		integer i;
		
		begin
			clear();
			for (i = 0; i < `NSEG; i = i + 1) begin
				digit(i, n % 10); 
				n = n / 10;
			end
		end
	endtask

	parameter CLK_FREQ = 50_000_000;
	parameter EV_MAX   = CLK_FREQ / 25;
	parameter CNT_MAX  = CLK_FREQ;
	parameter MAX_NUM  = 100_000_000;
	
	reg [31:0] cnt, ev, val, step;
	integer    i;
	
	initial begin
		cnt = 0;
		ev = 0;
		val = 0;
		step = 1;
	end

	always @ (posedge clk) begin
		if (cnt >= CNT_MAX) begin
			cnt = 0;
			val = (val + step) % MAX_NUM;
		end
		else
			cnt = cnt + 1;
		
		if (ev >= EV_MAX) begin	
			ev = 0;
			if (key[0] == 1'b0)
				val = 0;
			if (key[1] == 1'b0)
				step = 1;
			if (key[2] == 1'b0)
				step = (step + 1) % MAX_NUM;
			if (key[3] == 1'b0 && step > 0)
				step = step - 1;
		end
		else
			ev = ev + 1;

		for (i = 0; i < `NLEDR; i = i + 1)
			ledr[i] = (step >> i) & 1;

		print(val);
	end
endmodule
