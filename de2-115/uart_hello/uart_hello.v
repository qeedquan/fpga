// spam messages at 9600 baud over UART
module uart_hello
(
	input wire  clk50,
	input wire  uart_rts,
	input wire  uart_rxd,
	output wire uart_cts,
	output wire uart_txd
);
	`define LEN 14

	reg [8*`LEN:0] text = "Hello World!\r\n";
	reg [7:0]      data;
	wire           rst;
	wire           nextch;
	integer        idx, i;
	
	initial begin
		idx <= 0;
	end
	
	always @ (posedge clk50) begin
		for (i = 0; i < 8; i = i + 1)
			data[i] = text[8*(`LEN-1-idx) + i];

		if (nextch)
			idx = (idx + 1) % `LEN;
	end
	
	assign uart_cts = 0;
	
	reset_delay r0(
		.clk(clk50),
		.rst(rst)
	);
	
	uart_transmitter t0(
		.clk(clk50), 
		.rst(rst),
		.data(data),
		.nextch(nextch),
		.txd(uart_txd)
	);
endmodule

`timescale 1ns/1ns
module uart_hello_test();
	reg  clk50;
	wire uart_rts;
	wire uart_rxd;
	wire uart_cts;
	wire uart_txd;
	
	initial begin
		clk50 = 0;
	end
	
	always begin
		#20 clk50 = ~clk50;
	end
	
	uart_hello u0(
		.clk50(clk50),
		.uart_rts(uart_rts),
		.uart_rxd(uart_rxd),
		.uart_cts(uart_cts),
		.uart_txd(uart_txd)
	);
endmodule
