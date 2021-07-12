module fsmcnt
(
	input wire            clk,
	output wire [8*7-1:0] hex
);
	task inc(input integer n, input reg [2:0] s);
		begin
			if (cnt == 0) begin
				v[n] = v[n] + 1;
				state = s;
			end
		end
	endtask
	
	parameter CLK_FREQ = 50_000_000;
	parameter CNT_MAX  = CLK_FREQ;

	reg [4:0]  v[3:0];
	reg [31:0] cnt;
	reg [2:0]  state;

	initial begin
		v[0] = 0;
		v[1] = 0;
		v[2] = 0;
		v[3] = 0;
		cnt = 1;
		state = 0;
	end
	
	always @ (posedge clk) begin
		if (cnt >= CNT_MAX)
			cnt <= 0;
		else
			cnt <= cnt + 1;
	end

	always @ (posedge clk) begin
		case (state)
			0: inc(0, 1);
			1: inc(2, 2);
			2: inc(3, 3);
			3: inc(1, 0);
		endcase
	end
	
	generate
		genvar i;
		for (i = 7*4; i < 8*7; i = i + 1) begin: loop
			assign hex[i] = 0;
		end
	endgenerate
	
	hexdigit h1(v[0], hex[7*1-1:7*0]);
	hexdigit h2(v[1], hex[7*2-1:7*1]);
	hexdigit h3(v[2], hex[7*3-1:7*2]);
	hexdigit h4(v[3], hex[7*4-1:7*3]);

endmodule
